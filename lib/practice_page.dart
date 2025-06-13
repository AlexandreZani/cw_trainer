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

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              )
            ],
          );
        });
  }
}
