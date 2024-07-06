import 'package:cw_trainer/audio.dart';
import 'package:cw_trainer/audio_item_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cw_trainer/config.dart';
import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  WidgetsFlutterBinding.ensureInitialized();
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
  late AppConfig appConfig;

  MyAppState() : super() {
    SharedPreferences.getInstance().then(
      (prefs) {
        appConfig = AppConfig.buildFromShared(prefs);
        appConfig.addListener(notifyListeners);
      },
    );
    print('MyAppState constructed');
  }
}

enum Pages {
  practice,
  settings,
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Pages currentPage = Pages.practice;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('CW Trainer')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                setState(() {
                  currentPage = Pages.settings;
                });

                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Visibility(
                  visible: false, child: Icon(Icons.chevron_right)),
              title: const Text('Practice'),
              onTap: () {
                setState(() {
                  currentPage = Pages.practice;
                });

                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
      body: switch (currentPage) {
        Pages.practice => PracticePage(appState: appState),
        Pages.settings => SettingsPage(appState: appState),
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    print('building settings page');
    return ListView(
      children: [
        const ListTile(title: Text('CW Settings')),
        const Divider(),
        ListTile(
          title: IntSetting(
            label: "WPM",
            initialValue: appState.appConfig.cwConfig.wpm,
            min: 5,
            max: 40,
            step: 1,
            onSelected: (int i) {
              appState.appConfig.cwConfig.wpm = i;
            },
          ),
        ),
        IntSetting(
          label: "EWPM",
          initialValue: appState.appConfig.cwConfig.ewpm,
          min: 5,
          max: 40,
          step: 1,
          onSelected: (int i) {
            appState.appConfig.cwConfig.ewpm = i;
          },
        ),

        IntSetting(
          label: "Frequency",
          initialValue: appState.appConfig.cwConfig.frequency,
          min: 400,
          max: 1000,
          step: 50,
          onSelected: (int i) {
            appState.appConfig.cwConfig.frequency = i;
          },
        )
      ],
    );
  }
}

class IntSetting extends StatelessWidget {
  const IntSetting({
    super.key,
    required this.initialValue,
    required this.label,
    required this.min,
    required this.max,
    required this.step,
    required this.onSelected,
  });

  final int initialValue;
  final int min;
  final int max;
  final int step;
  final String label;
  final Function onSelected;

  @override
  Widget build(BuildContext context) {
    int numEntries = 1 + (max - min) ~/ step;
    return ListTile(
      title: Row(children: [
        Text(label, textAlign: TextAlign.left),
        const Spacer(),
        DropdownMenu(
          onSelected: (int? i) {
            if (i != null) {
              onSelected(i);
            }
          },
          initialSelection: initialValue,
          dropdownMenuEntries: List.generate(
            numEntries,
            (int i) {
              int value = i * step + min;
              return DropdownMenuEntry(
                label: (value).toString(),
                value: value,
              );
            },
          ).toList(),
        ),
      ]),
    );
  }
}

class PracticePage extends StatelessWidget {
  const PracticePage({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    print('building playback page');
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
