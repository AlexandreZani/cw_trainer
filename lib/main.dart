import 'package:cw_trainer/audio.dart';
import 'package:cw_trainer/exercises.dart';
import 'package:cw_trainer/practice_page.dart';
import 'package:cw_trainer/settings_page.dart';
import 'package:cw_trainer/info_pages.dart';
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
  runApp(MyApp(
    appConfig: config,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appConfig});

  final AppConfig appConfig;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(appConfig),
      child: MaterialApp(
        title: 'CW Trainer',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromRGBO(0x34, 0xde, 0xeb, 1.0)),
        ),
        home: const MyHomePage(currentPage: Pages.practice),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final AppConfig appConfig;
  final log = Logger('MyAppState');

  MyAppState(this.appConfig) : super() {
    appConfig.addListener(notifyListeners);
    log.finest('MyAppState constructed');
  }
}

enum Pages {
  practice,
  settings,
  license,
  about,
}

class MyHomePage extends StatelessWidget {
  final Pages currentPage;
  const MyHomePage({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var licenseAccepted = appState.appConfig.misc.licenseAccepted;

    AppBar appBar = AppBar(
      title: const Text('CW Trainer'),
      backgroundColor: const Color.fromRGBO(0x34, 0xde, 0xeb, 0.2),
    );

    if (!licenseAccepted) {
      return LicenseConsentPage(appBar: appBar, appState: appState);
    }

    var navBarIndex = switch (currentPage) {
      Pages.practice => 0,
      Pages.settings => 1,
      Pages.license => 1,
      Pages.about => 1,
    };

    return Scaffold(
      appBar: appBar,
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
        Pages.license => LicenseDisplayPage(),
        Pages.about => AboutPage(),
      },
    );
  }
}
