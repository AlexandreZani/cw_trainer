import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:cw_trainer/audio_item_type.dart';
import 'package:cw_trainer/cw.dart';
import 'package:cw_trainer/exercises.dart';
import 'package:cw_trainer/wav.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

class CwAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();

  Exercise? _currentExercise;
  // final Queue<AudioItem> _queue = Queue<AudioItem>();
  AudioItem? _currentAudioItem;
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
      case 'startExercise':
        _currentExercise = extras!['exercise'];
        play();
    }
    return super.customAction(name, extras);
  }

  MorseGenerator _getMorseGenerator() {
    return MorseGenerator.fromEwpm(
      _currentExercise!.appConfig.cw.wpm,
      _currentExercise!.appConfig.cw.ewpm,
      _currentExercise!.appConfig.cw.sampleRate,
      _currentExercise!.appConfig.cw.frequency,
    );
  }

  Future<void> _onCompleted() async {
    print('AudioPlayerHandler completed');
    _playing = false;
    _currentAudioItem = null;

    if (playbackState.isPaused) {
      return;
    }

    if (_currentExercise!.complete) {
      stop();
    }
    play();
  }

  @override
  Future<void> play() async {
    print('AudioPlayerHandler play');
    if (_playing) {
      return;
    }

    _playing = true;
    if (_currentAudioItem == null) {
      _readyNext();
    }

    final session = await AudioSession.instance;
    await session.setActive(true);

    switch (_currentAudioItem!.type) {
      case AudioItemType.morse:
        return _player.play();

      case AudioItemType.silence:
        return Future.delayed(
          Duration(milliseconds: _currentAudioItem!.milliseconds),
          () {
            _onCompleted();
          },
        );

      case AudioItemType.text:
        print('playing tts');
        _flutterTts.setVolume(_currentExercise!.appConfig.tts.volume);
        _flutterTts.setPitch(_currentExercise!.appConfig.tts.pitch);
        _flutterTts.setSpeechRate(_currentExercise!.appConfig.tts.rate);

        _flutterTts.speak(_currentAudioItem!.text);
        return;
    }
  }

  @override
  Future<void> pause() async {
    _playing = false;
    print('AudioPlayerHandler pause');
    switch (_currentAudioItem!.type) {
      case AudioItemType.morse:
        return _player.pause();

      case AudioItemType.silence:
        return;

      case AudioItemType.text:
        print('pausing tts');
        return;
    }
  }

  @override
  Future<void> stop() async {
    print('AudioPlayerHandler stop');
    _playing = false;
    if (_currentAudioItem == null) {
      return;
    }
    var type = _currentAudioItem!.type;
    _currentAudioItem = null;
    _currentExercise = null;
    switch (type) {
      case AudioItemType.morse:
      case AudioItemType.silence:
        return _player.stop();

      case AudioItemType.text:
        print('stopping tts');
        _flutterTts.stop();
        return;
    }
  }

  void _readyNext() {
    print('_readyNext');
    _currentAudioItem = _currentExercise?.getNextAudioItem();
    if (_currentAudioItem == null) {
      stop();
      return;
    }

    switch (_currentAudioItem!.type) {
      case AudioItemType.morse:
        _readyMorse(_currentAudioItem!.text);
        print('_readyNext morse done');
        return;

      case AudioItemType.silence:
        _readySilence(_currentAudioItem!.milliseconds);
        print('_readyNext silence done');
        return;

      case AudioItemType.text:
        print('tts beep boop readying: ${_currentAudioItem!.text}');
        return;
    }
  }

  void _readyMorse(String s) async {
    var generator = _getMorseGenerator();
    var frames = generator.stringToPcm(s);
    await _player.stop();
    await _player.setAudioSource(
        WavSource(frames, _currentExercise!.appConfig.cw.sampleRate));
  }

  void _readySilence(int ms) async {
    int numFrames = (_currentExercise!.appConfig.cw.sampleRate * ms) ~/ 1000;
    var frames = List.filled(numFrames, 128);
    await _player.stop();
    await _player.setAudioSource(WavSource(
        Uint8List.fromList(frames), _currentExercise!.appConfig.cw.sampleRate));
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
  // Assumes pcm was sampled at 44.1kHz in 8 bits.
  final Uint8List _wav;
  WavSource(List<int> frames, int sampleRate)
      : _wav = pcmToWav(frames, sampleRate);

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
