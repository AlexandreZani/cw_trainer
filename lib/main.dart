import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_session/audio_session.dart';
import 'package:cw_trainer/cw.dart';
import 'package:cw_trainer/wav.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

late AudioHandler _audioHandler;

extension CwTrainerAudioHandler on AudioHandler {
  Future<void> setMorseParameters(int wpm, int ewpm, int frequency) async {
    await _audioHandler.customAction('setMorseParameters', {
      'wpm': wpm,
      'ewpm': ewpm,
      'frequency': frequency,
    });
  }

  Future<void> appendAudioItems(List<AudioItem> items) async {
    _audioHandler.customAction('appendAudioItems', {'items': items});
  }

  Future<void> appendAudioItem(AudioItem item) async {
    _audioHandler.appendAudioItems([item]);
  }

  Future<void> clearAudioItems() async {
    _audioHandler.customAction('clearAudioItems');
  }

  Future<void> setOnQueueCompleted(Function onQueueCompleted) async {
    _audioHandler.customAction(
        'setOnQueueCompleted', {'onQueueCompleted': onQueueCompleted});
  }
}

void main() async {
  _audioHandler = await AudioService.init(
    builder: () => MorseAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'io.zfc.cw_trainer',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(const MyApp());
}

enum AudioItemType {
  morse,
  text,
}

class AudioItem {
  final String value;
  final AudioItemType type;

  AudioItem(this.value, this.type);
}

class MorseAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  Function _onQueueCompleted = () {};

  int _wpm = 12;
  int _ewpm = 12;
  int _frequency = 500;

  final Queue<AudioItem> _queue = Queue<AudioItem>();
  AudioItem? _current;
  bool _playing = false;

  MorseAudioHandler() {
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.playbackEventStream.listen((PlaybackEvent event) {
      if (event.processingState == ProcessingState.completed) {
        _onCompleted();
      }
    });
    _flutterTts.setCompletionHandler(_onCompleted);
  }

  @override
  Future<dynamic> customAction(String name,
      [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'appendAudioItems':
        _queue.addAll(extras!['items']);
        return null;

      case 'clearAudioItems':
        _queue.clear();
        return null;

      case 'setMorseParameters':
        _setMorseParameters(
            extras!['wpm'], extras['ewpm'], extras['frequency']);
        return null;

      case 'setOnQueueCompleted':
        _onQueueCompleted = extras!['onQueueCompleted'];
    }
    return super.customAction(name, extras);
  }

  void _setMorseParameters(int wpm, int ewpm, int frequency) {
    _wpm = wpm;
    _ewpm = ewpm;
    _frequency = frequency;
  }

  MorseGenerator _getMorseGenerator() {
    return MorseGenerator.fromEwpm(_wpm, _ewpm, sampleRate, _frequency);
  }

  Future<void> _onCompleted() async {
    print('AudioPlayerHandler completed');
    _playing = false;
    _current = null;
    if (_queue.isNotEmpty) {
      play();
    } else {
      _onQueueCompleted();
    }
  }

  @override
  Future<void> play() async {
    print('AudioPlayerHandler play');
    if (_playing) {
      return;
    }

    _playing = true;
    if (_current == null) {
      _readyNext();
    }

    final session = await AudioSession.instance;
    await session.setActive(true);

    switch (_current!.type) {
      case AudioItemType.morse:
        return _player.play();

      case AudioItemType.text:
        print('playing tts');
        _flutterTts.setVolume(1.0);
        
        _flutterTts.speak(_current!.value);
        return;
    }
  }

  @override
  Future<void> pause() async {
    print('AudioPlayerHandler pause');
    switch (_current!.type) {
      case AudioItemType.morse:
        return _player.pause();

      case AudioItemType.text:
        print('pausing tts');
        return;
    }
  }

  @override
  Future<void> stop() async {
    print('AudioPlayerHandler stop');
    if (_current == null) {
      return;
    }
    var type = _current!.type;
    _current = null;
    _queue.clear();
    switch (type) {
      case AudioItemType.morse:
        return _player.stop();

      case AudioItemType.text:
        print('stopping tts');
        _flutterTts.stop();
        return;
    }
  }

  void _readyNext() {
    print('_readyNext');
    _current = _queue.removeFirst();

    switch (_current!.type) {
      case AudioItemType.morse:
        _readyMorse(_current!.value);
        print('_readyNext morse done');
        return;

      case AudioItemType.text:
        print('tts beep boop readying: ${_current!.value}');
        return;
    }
  }

  void _readyMorse(String s) async {
    var generator = _getMorseGenerator();
    var frames = generator.stringToPcm(s);
    _player.setAudioSource(WavSource(frames));
  }

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'CW Trainer',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

const sampleRate = 44100;

class MyAppState extends ChangeNotifier {
  MyAppState() : super() {
    print('MyAppState constructed');
  }

  int wpm = 20;
  int ewpm = 20;
  int frequency = 500;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: PlaybackPage(appState: appState),
    );
  }
}

class PlaybackPage extends StatelessWidget {
  PlaybackPage({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                print('play');
                await _audioHandler
                    .appendAudioItem(AudioItem("SOS", AudioItemType.morse));
                await _audioHandler
                    .appendAudioItem(AudioItem("SOS", AudioItemType.text));
                await _audioHandler.play();
              },
              icon: const Icon(Icons.play_arrow),
            ),
            IconButton(
              onPressed: () {
                print('stop');
                _audioHandler.stop();
              },
              icon: const Icon(Icons.stop),
            ),
          ],
        )
      ],
    );
  }
}

void writeToFile(List<int> frames) async {
  final Directory directory = await getApplicationCacheDirectory();
  // final Directory directory = (await getDownloadsDirectory())!;
  String filepath = '/storage/emulated/0/Download/cw.wav';// '${directory.path}/my_file.wav';
  print(filepath);
  final File file = File(filepath);
  var sink = file.openWrite();
  file.writeAsBytes(frames);
  await sink.flush();

/*
  for (var f in frames) {
    sink.write('${f.toString()},\n');
    await sink.flush();
  }
*/
  await sink.close();
}

class WavSource extends StreamAudioSource {
  // Assumes pcm was sampled at 44.1kHz in 16 bits.
  final Uint8List _wav;
  WavSource(List<int> frames) : _wav = pcmToWav(frames, sampleRate);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    print('AudioStream requested');
    var r = StreamAudioResponse(
      sourceLength: _wav.length,
      contentLength: _wav.length,
      offset: 0,
      stream: Stream.value(_wav),
      contentType: 'audio/wav',
      rangeRequestsSupported: false,
    );
    writeToFile(_wav);
    print('Made response ${_wav.length}');
    return r;
  }
}
