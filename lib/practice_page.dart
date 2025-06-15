import 'package:audio_service/audio_service.dart';
import 'package:cw_trainer/main.dart';
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),
        Spacer(),
        Spacer(),
        PlayControls(audioHandler: audioHandler, log: log),
        Spacer(),
        PracticeSettings(appState: appState),
        Spacer(),
      ],
    );
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
    var letters = appState.appConfig.farnsworth.letters;
    var curChar = appState.appConfig.farnsworth.level;
    var i = letters.indexOf(curChar);

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
            iconSize: 48,
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              if (i <= 0) {
                return;
              }

              var nc = appState.appConfig.farnsworth.letters[i - 1];
              appState.appConfig.farnsworth.level = nc;
            }),
        Text(curChar),
        IconButton(
            iconSize: 48,
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              if (i >= letters.length - 1) {
                return;
              }

              var nc = appState.appConfig.farnsworth.letters[i + 1];
              appState.appConfig.farnsworth.level = nc;
            })
      ])
    ]);
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
