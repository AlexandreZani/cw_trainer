import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:cw_trainer/audio/audio_item_type.dart';
import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/audio/cw.dart';
import 'package:cw_trainer/exercises/exercises.dart';
import 'package:cw_trainer/audio/spelling.dart';
import 'package:cw_trainer/audio/wav.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

class CwAudioHandler extends BaseAudioHandler {
  final log = Logger('CwAudioHandler');
  final _player = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  bool _paused = false;

  final AppConfig _appConfig;
  ExerciseController _currentExercise;
  AudioItem? __currentAudioItem;

  AudioItem? get _currentAudioItem => __currentAudioItem;

  set _currentAudioItem(AudioItem? item) {
    __currentAudioItem = item;
    CustomAudioState state = customState.valueOrNull as CustomAudioState? ??
        CustomAudioState(audioItem: null);
    customState.add(state.copyWith(audioItem: item));
  }

  CwAudioHandler(this._appConfig)
      : _currentExercise = ExerciseController.getCurrent(_appConfig) {
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
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.play],
      playing: false,
      androidCompactActionIndices: [0],
    ));
  }

  MorseGenerator _getMorseGenerator() {
    return MorseGenerator.fromEwpm(
      _currentExercise.appConfig.cw.wpm,
      _currentExercise.appConfig.cw.ewpm,
      _currentExercise.appConfig.cw.sampleRate,
      _currentExercise.appConfig.cw.frequency,
    );
  }

  Future<void> _onCompleted() async {
    log.finest('AudioPlayerHandler completed');

    _currentAudioItem = null;

    if (_paused) {
      log.finest('isPaused');
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.play,
          MediaControl.stop,
        ],
        androidCompactActionIndices: [0, 1],
        playing: false,
      ));
      return;
    }

    if (!await _readyNext()) {
      log.finest('exercised is complete');
      _onExerciseFinished();
      return;
    }
    _beginPlayback();
  }

  Future<void> _onPlaying() async {
    log.finest('_onPlaying');
    if (_paused) {
      return;
    }
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.pause,
        MediaControl.stop,
      ],
      androidCompactActionIndices: [0, 1],
      playing: true,
    ));
  }

  void _resetExercise() {
    log.fine('_resetExercise');
    _currentExercise = ExerciseController.getCurrent(_appConfig);
  }

  Future<void> _onExerciseFinished() async {
    log.finest('_onExercisedFinished');
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.play],
      playing: false,
      androidCompactActionIndices: [0],
    ));
    _resetExercise();
    log.finest('_onExercisedFinished finished');
  }

  @override
  Future<void> play() async {
    log.finest('AudioPlayerHandler play');
    if (!_paused) {
      _resetExercise();
    }
    _paused = false;

    if (_currentAudioItem == null && !await _readyNext()) {
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
        log.finest('playing tts');
        _flutterTts.speak(_currentAudioItem!.textString);
        return;

      case AudioItemType.spell:
        String spoken;
        log.finest('spelling');
        if (_currentExercise.appConfig.tts.spellWithItu) {
          spoken = spellWithItu(_currentAudioItem!.textString);
        } else {
          spoken = spellWithoutItu(_currentAudioItem!.textString);
        }
        log.finest("spoken: $spoken");
        _flutterTts.speak(spoken);
    }
  }

  @override
  Future<void> pause() async {
    log.finest('AudioPlayerHandler pause');
    _paused = true;
  }

  @override
  Future<void> stop() async {
    log.finest('AudioPlayerHandler stop');
    if (_currentAudioItem != null) {
      _currentAudioItem = null;
      await _player.stop();
    }

    _onExerciseFinished();
  }

  Future<bool> _readyNext() async {
    log.finest('_readyNext');
    _currentAudioItem = _currentExercise.getNextAudioItem();
    if (_currentAudioItem == null) {
      return false;
    }

    switch (_currentAudioItem!.type) {
      case AudioItemType.morse:
        await _readyMorse(_currentAudioItem!.textString);
        log.finest('_readyNext morse done');
        return true;

      case AudioItemType.silence:
        await _readySilence(_currentAudioItem!.milliseconds);
        log.finest('_readyNext silence done');
        return true;

      case AudioItemType.text:
        log.finest('tts beep boop readying: ${_currentAudioItem!.textString}');
        _readyTts();
        return true;

      case AudioItemType.spell:
        log.finest(
            'tts beep boop readying to spell: ${_currentAudioItem!.textString}');
        _readyTts();
        return true;
    }
  }

  void _readyTts() async {
    _flutterTts.setVolume(_currentExercise.appConfig.tts.volume);
    _flutterTts.setPitch(_currentExercise.appConfig.tts.pitch);
    _flutterTts.setSpeechRate(_currentExercise.appConfig.tts.rate);
  }

  Future<void> _readyMorse(String s) async {
    final generator = _getMorseGenerator();
    final frames = generator.stringToPcm(s);
    await _writeAndLoadClip(pcmToWav(frames, _currentExercise.appConfig.cw.sampleRate));
  }

  Future<void> _readySilence(int ms) async {
    final sampleRate = _currentExercise.appConfig.cw.sampleRate;
    final numFrames = (sampleRate * ms) ~/ 1000;
    final frames = List.filled(numFrames, 128);
    await _writeAndLoadClip(pcmToWav(frames, sampleRate));
  }

  // just_audio's iOS StreamAudioSource (via local HTTP proxy) is rejected by
  // AVPlayer with error -11850, so write the clip to disk and load via path.
  Future<void> _writeAndLoadClip(Uint8List wav) async {
    final tmp = await getTemporaryDirectory();
    final wavFile = File('${tmp.path}/cw_clip.wav');
    await wavFile.writeAsBytes(wav, flush: true);
    await _player.stop();
    await _player.setFilePath(wavFile.path);
  }
}

class CustomAudioState {
  static const _fakeNull = Object();
  CustomAudioState({this.audioItem});

  final AudioItem? audioItem;

  CustomAudioState copyWith({Object? audioItem = _fakeNull}) {
    return CustomAudioState(
        audioItem:
            audioItem == _fakeNull ? this.audioItem : audioItem as AudioItem?);
  }
}
