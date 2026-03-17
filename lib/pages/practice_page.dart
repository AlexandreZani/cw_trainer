import 'package:audio_service/audio_service.dart';
import 'package:cw_trainer/audio/audio.dart';
import 'package:cw_trainer/exercises/exercises.dart';
import 'package:cw_trainer/main.dart';
import 'package:cw_trainer/pages/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class PracticePage extends StatelessWidget {
  final log = Logger('PracticePage');

  PracticePage({
    super.key,
    required this.appState,
    required this.audioHandler,
  });

  final MyAppState appState;
  final AudioHandler audioHandler;

  @override
  Widget build(BuildContext context) {
    log.finest('building playback page');

    return StreamBuilder(
        stream: audioHandler.playbackState,
        builder: (context, snapshot) {
          var topWidget = switch (
              (snapshot.data?.controls.contains(MediaControl.stop) ?? false)) {
            true =>
              CaptionDisplay(appState: appState, audioHandler: audioHandler),
            false =>
              ExerciseSelector(appState: appState, audioHandler: audioHandler)
          };
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              topWidget,
              const Spacer(),
              PlayControls(audioHandler: audioHandler, log: log),
              const Spacer(),
              PracticeSettings(appState: appState),
              const Spacer(),
            ],
          );
        });
  }
}

class CaptionDisplay extends StatelessWidget {
  const CaptionDisplay(
      {super.key, required this.appState, required this.audioHandler});

  final MyAppState appState;
  final AudioHandler audioHandler;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: audioHandler.customState,
        builder: (context, snapshot) {
          CustomAudioState? data = snapshot.data as CustomAudioState?;
          String caption = data?.audioItem?.caption ?? "";

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                caption,
                style: const TextStyle(fontSize: 18),
              )
            ],
          );
        });
  }
}

class ExerciseSelector extends StatelessWidget {
  ExerciseSelector(
      {super.key, required this.appState, required this.audioHandler})
      : currentCourse = appState.appConfig.sharedExercise.currentCourse,
        curExerciseType = appState.appConfig.sharedExercise.curExerciseType;

  final MyAppState appState;
  final AudioHandler audioHandler;
  final CourseType currentCourse;
  final ExerciseType curExerciseType;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Spacer(),
        ConfigEnumPicker(
            values: const [CourseType.legacy, CourseType.licwBc1],
            initialValue: currentCourse,
            onSelected: (v) {
              appState.appConfig.sharedExercise.currentCourse = v;
            }),
        const Spacer(),
        ConfigEnumPicker(
            values: currentCourse.supportedExercises,
            initialValue: curExerciseType,
            onSelected: (v) {
              appState.appConfig.sharedExercise.curExerciseType = v;
            }),
        const Spacer(),
      ],
    );
  }
}

class PlayControls extends StatelessWidget {
  const PlayControls({
    super.key,
    required this.audioHandler,
    required this.log,
  });

  final AudioHandler audioHandler;
  final Logger log;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
        stream: audioHandler.playbackState,
        builder: (context, snapshot) {
          List<Widget> children = [];

          if (snapshot.data?.controls.contains(MediaControl.play) ?? true) {
            log.finest("add play button");
            children.add(IconButton(
              onPressed: () async {
                log.finest('play');
                await audioHandler.play();
              },
              iconSize: 48,
              icon: const Icon(Icons.play_arrow),
            ));
          }

          if (snapshot.data?.controls.contains(MediaControl.pause) ?? false) {
            children.add(IconButton(
              onPressed: () async {
                log.finest('pause');
                await audioHandler.pause();
              },
              iconSize: 48,
              icon: const Icon(Icons.pause),
            ));
          }

          if (snapshot.data?.controls.contains(MediaControl.stop) ?? false) {
            children.add(IconButton(
              onPressed: () async {
                log.finest('stop');
                await audioHandler.stop();
              },
              iconSize: 48,
              icon: const Icon(Icons.stop),
            ));
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          );
        });
  }
}

class PracticeSettings extends StatelessWidget {
  const PracticeSettings({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      LevelSelectorForExercise(
        appState: appState,
        exerciseType: appState.appConfig.sharedExercise.curExerciseType,
      )
    ]);
  }
}
