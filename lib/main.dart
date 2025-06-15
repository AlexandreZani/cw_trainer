import 'package:cw_trainer/audio.dart';
import 'package:cw_trainer/exercises.dart';
import 'package:cw_trainer/practice_page.dart';
import 'package:cw_trainer/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cw_trainer/config.dart';
import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

late AudioHandler _audioHandler;

extension CwTrainerAudioHandler on AudioHandler {
  Future<void> setExerciseType(ExerciseType exerciseType) async {
    _audioHandler
        .customAction('setExerciseType', {'exerciseType': exerciseType});
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

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
        home: const MyHomePage(currentPage: Pages.practice),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  late AppConfig appConfig;
  final log = Logger('MyAppState');

  MyAppState() : super() {
    SharedPreferences.getInstance().then(
      (prefs) {
        appConfig = AppConfig.buildFromShared(prefs);
        appConfig.addListener(notifyListeners);
      },
    );
    log.finest('MyAppState constructed');
  }
}

enum Pages {
  practice,
  settings,
}

class MyHomePage extends StatelessWidget {
  final Pages currentPage;
  const MyHomePage({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var navBarIndex = switch (currentPage) {
      Pages.practice => 0,
      Pages.settings => 1,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('CW Trainer')),
      bottomNavigationBar: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: navBarIndex,
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(Icons.school), label: "Practice"),
            NavigationDestination(
                icon: Icon(Icons.settings), label: "Settings"),
          ],
          onDestinationSelected: (int selectedIndex) {
            switch (selectedIndex) {
              case 0:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MyHomePage(currentPage: Pages.practice)));
              case 1:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MyHomePage(currentPage: Pages.settings)));
            }
          }),
      body: switch (currentPage) {
        Pages.practice =>
          PracticePage(appState: appState, audioHandler: _audioHandler),
        Pages.settings => SettingsPage(appState: appState),
      },
    );
  }
}
