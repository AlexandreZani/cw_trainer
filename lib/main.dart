import 'package:cw_trainer/audio.dart';
import 'package:cw_trainer/exercises.dart';
import 'package:cw_trainer/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cw_trainer/config.dart';
import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

late AudioHandler _audioHandler;

extension CwTrainerAudioHandler on AudioHandler {
  Future<void> setExerciseType(ExerciseType exerciseType) async {
    _audioHandler.customAction('setExerciseType', {'exerciseType': exerciseType});
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var prefs = await SharedPreferences.getInstance();
  AppConfig config = AppConfig.buildFromShared(prefs);

  _audioHandler = await AudioService.init(
    builder: () => CwAudioHandler(config),
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
