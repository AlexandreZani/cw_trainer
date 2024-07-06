import 'package:cw_trainer/audio.dart';
import 'package:cw_trainer/audio_item_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cw_trainer/config.dart';
import 'package:audio_service/audio_service.dart';

late AudioHandler _audioHandler;

extension CwTrainerAudioHandler on AudioHandler {
  Future<void> setAppConfig(AppConfig appConfig) async {
    _audioHandler.customAction('setAppConfig', {'appConfig': appConfig});
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
    builder: () => CwAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'io.zfc.cw_trainer',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(const MyApp());
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
                var appConfig = await readAppConfigFromShared();
                await _audioHandler.setAppConfig(appConfig);
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
