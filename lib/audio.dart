import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:cw_trainer/audio_item_type.dart';
import 'package:cw_trainer/config.dart';
import 'package:cw_trainer/cw.dart';
import 'package:cw_trainer/wav.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

const sampleRate = 44100;

class CwAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  Function _onQueueCompleted = () {};

  late CwConfig _cwConfig;

  final Queue<AudioItem> _queue = Queue<AudioItem>();
  AudioItem? _current;
  bool _playing = false;

  CwAudioHandler() {
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

      case 'setOnQueueCompleted':
        _onQueueCompleted = extras!['onQueueCompleted'];

      case 'setAppConfig':
        AppConfig appConfig = extras!['appConfig'];
        _cwConfig = appConfig.cwConfig;
    }
    return super.customAction(name, extras);
  }

  MorseGenerator _getMorseGenerator() {
    return MorseGenerator.fromEwpm(
      _cwConfig.wpm,
      _cwConfig.ewpm,
      sampleRate,
      _cwConfig.frequency,
    );
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
    // writeToFile(_wav);
    print('Made response ${_wav.length}');
    return r;
  }
}

void writeToFile(List<int> frames) async {
  // final Directory directory = await getApplicationCacheDirectory();
  String filepath =
      '/storage/emulated/0/Download/cw.wav'; // '${directory.path}/my_file.wav';
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
