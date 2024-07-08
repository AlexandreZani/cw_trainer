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
  AudioItem? _currentAudioItem;

  CwAudioHandler() {
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    // _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.playbackEventStream.listen((PlaybackEvent event) {
      if (_player.playing) {
        _onPlaying();
      }
      if (event.processingState == ProcessingState.completed) {
        _onCompleted();
      }
    });
    _flutterTts.setCompletionHandler(_onCompleted);
    _flutterTts.setStartHandler(_onPlaying);
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

    _currentAudioItem = null;

    if (playbackState.isPaused) {
      print('isPaused');
      return;
    }

    if (!_readyNext()) {
      print('exercised is complete');
      _onExerciseFinished();
      return;
    }
    _beginPlayback();
  }

  Future<void> _onPlaying() async {
    print('_onPlaying');
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.pause,
        MediaControl.stop,
      ],
      androidCompactActionIndices: [0, 1],
      playing: true,
    ));
  }

  Future<void> _onExerciseFinished() async {
    print('_onExercisedFinished');
    playbackState.add(PlaybackState(
      playing: false,
    ));
  }

  @override
  Future<void> play() async {
    print('AudioPlayerHandler play');
    if (_currentExercise == null) {
      return;
    }

    if (_currentAudioItem == null && !_readyNext()) {
      return;
    }

    return _beginPlayback();
  }

  Future<void> _beginPlayback() async {
    if (_currentAudioItem == null) {
      return;
    }
    final session = await AudioSession.instance;
    await session.setActive(true);

    _onPlaying();
    switch (_currentAudioItem!.type) {
      case AudioItemType.morse:
        return _player.play();

      case AudioItemType.silence:
        return _player.play();

      case AudioItemType.text:
        print('playing tts');
        _flutterTts.speak(_currentAudioItem!.text);
        return;
    }
  }

  @override
  Future<void> pause() async {
    print('AudioPlayerHandler pause');

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.play,
        MediaControl.stop,
      ],
      androidCompactActionIndices: [0, 1],
      playing: false,
    ));
  }

  @override
  Future<void> stop() async {
    print('AudioPlayerHandler stop');
    if (_currentExercise == null) {
      return;
    }
    if (!playbackState.value.playing) {
      return;
    }

    var type = _currentAudioItem!.type;
    _currentAudioItem = null;
    _currentExercise = null;

    switch (type) {
      case AudioItemType.morse:
        await _player.stop();
        break;

      case AudioItemType.silence:
        break;

      case AudioItemType.text:
        await _flutterTts.stop();
        break;
    }

    _onExerciseFinished();
  }

  bool _readyNext() {
    print('_readyNext');
    _currentAudioItem = _currentExercise?.getNextAudioItem();
    if (_currentAudioItem == null) {
      stop();
      return false;
    }

    switch (_currentAudioItem!.type) {
      case AudioItemType.morse:
        _readyMorse(_currentAudioItem!.text);
        print('_readyNext morse done');
        return true;

      case AudioItemType.silence:
        _readySilence(_currentAudioItem!.milliseconds);
        print('_readyNext silence done');
        return true;

      case AudioItemType.text:
        print('tts beep boop readying: ${_currentAudioItem!.text}');
        _readyTts();
        return true;
    }
  }

  void _readyTts() async {
    _flutterTts.setVolume(_currentExercise!.appConfig.tts.volume);
    _flutterTts.setPitch(_currentExercise!.appConfig.tts.pitch);
    _flutterTts.setSpeechRate(_currentExercise!.appConfig.tts.rate);
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
