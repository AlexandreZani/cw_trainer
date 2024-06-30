import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cw_trainer/cw.dart';
import 'package:cw_trainer/wav.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

late AudioHandler _audioHandler;

extension CwTrainerAudioHandler on AudioHandler {
  Future<void> playString(String s) async {
    await _audioHandler.customAction('setString', {'s': s});
    await _audioHandler.play();
  }
}

void main() async {
  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'io.zfc.cw_trainer',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(const MyApp());
}

class AudioPlayerHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  String _s = "SOS ";
  MorseGenerator _generator = MorseGenerator.fromEwpm(12, 12, sampleRate, 500);

  AudioPlayerHandler() {
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.playbackEventStream.listen((PlaybackEvent event) {
      if (event.processingState == ProcessingState.completed) {
        _justAudioCompleted();
      }
    });
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) {
    switch (name) {
      case 'setString':
        _s = extras!['s'];
        break;
      case 'configureMorse':
        _generator = MorseGenerator.fromEwpm(
            extras!['wpm'], extras['ewpm'], sampleRate, extras['frequency']);
        break;
    }
    return super.customAction(name, extras);
  }

  @override
  Future<void> play() {
    List<int> frames;
    frames = _generator.stringToPcm(_s);

    // Load the player.
    _player.setAudioSource(WavSource(frames));
    print('AudioPlayerHandler play');
    return _player.play();
  }

  @override
  Future<void> pause() {
    print('AudioPlayerHandler pause');
    return _player.pause();
  }

  @override
  Future<void> stop() {
    print('AudioPlayerHandler stop');
    return _player.stop();
  }

  void _justAudioCompleted() {
    print('just_audio completed');
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
  const PlaybackPage({
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
              onPressed: () {
                print('play');
                _audioHandler.playString("MY STRING ");
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
  String filepath = '${directory.path}/my_file.csv';
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
  WavSource(List<int> frames) : _wav = pcmToWav(frames, sampleRate) {}

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
