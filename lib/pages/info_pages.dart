import 'package:cw_trainer/main.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'package:url_launcher/link.dart';

class LicenseConsentPage extends StatelessWidget {
  final log = Logger('LicenseConsentPage');

  LicenseConsentPage({
    super.key,
    required this.appState,
    required this.appBar,
  });

  final MyAppState appState;
  final AppBar appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar,
        persistentFooterAlignment: AlignmentDirectional.center,
        persistentFooterButtons: [
          OutlinedButton(
              child: const Text("I Agree"),
              onPressed: () {
                log.info("License is accepted.");
                appState.appConfig.misc.acceptLicense();
              }),
          OutlinedButton(
              child: const Text("I Do Not Agree"),
              onPressed: () {
                log.info("License is rejected.");
                SystemNavigator.pop();
              }),
        ],
        body: const LicenseText());
  }
}

class LicenseText extends StatelessWidget {
  const LicenseText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DefaultAssetBundle.of(context).loadString("LICENSE"),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(snapshot.data!)),
                ),
              ],
            ),
          );
        });
  }
}

class LicenseDisplayPage extends StatelessWidget {
  final log = Logger('LicenseDisplayPage');

  LicenseDisplayPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const LicenseText();
  }
}

class AboutPage extends StatelessWidget {
  final log = Logger('AboutPage');

  AboutPage({
    super.key,
  });

  Future<({String version, String androidVersion, String phoneModel})>
      _pageData(BuildContext context) async {
    final pubspecS =
        await DefaultAssetBundle.of(context).loadString("pubspec.yaml");
    final pubspec = loadYaml(pubspecS);
    final version = pubspec['version'] as String;

    final deviceInfo = DeviceInfoPlugin();
    final android = await deviceInfo.androidInfo;

    return (
      version: version,
      androidVersion: android.version.release,
      phoneModel: android.model,
    );
  }

  Uri _userReportUri({
    required String appVersion,
    required String androidVersion,
    required String phoneModel,
  }) {
    return Uri.https(
      'github.com',
      '/AlexandreZani/cw_trainer/issues/new',
      {
        'template': 'user-report.yml',
        'version': appVersion,
        'android-version': androidVersion,
        'phone-model': phoneModel,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _pageData(context),
        builder: (context, asyncSnapshot) {
          if (!asyncSnapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final data = asyncSnapshot.data!;
          return ListView(
            children: [
              Column(
                children: [
                  AboutEntry(name: "Version", value: data.version),
                  const AboutEntry(name: "Author", value: "Alexandre Zani"),
                  const AboutEntry(
                    name: "Email",
                    value: "cw_trainer@zfc.io",
                    uri: "mailto:cw_trainer@zfc.io",
                  ),
                  const AboutEntry(name: "Call Sign", value: "K7ZFC"),
                  AboutEntry(
                      name: "Found a Bug?",
                      uri: _userReportUri(
                        appVersion: data.version,
                        androidVersion: data.androidVersion,
                        phoneModel: data.phoneModel,
                      ).toString(),
                      value: "Let Me Know"),
                  ListTile(
                    title: const Text("View App License"),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyHomePage(
                                  currentPage: Pages.license)));
                    },
                  ),
                  ListTile(
                    title: const Text("View Dependency Licenses"),
                    onTap: () {
                      showLicensePage(context: context);
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }
}

class AboutEntry extends StatelessWidget {
  const AboutEntry({
    super.key,
    required this.name,
    required this.value,
    this.uri,
  });

  final String name;
  final String value;
  final String? uri;

  Widget valueWidget() {
    if (uri == null) {
      return Text(value, textAlign: TextAlign.left);
    }

    return Link(
        uri: Uri.parse(uri!),
        builder: (context, followLink) {
          return TextButton(
              onPressed: followLink,
              child: Text(value,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue)));
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(name, textAlign: TextAlign.right),
          const Spacer(),
          valueWidget(),
        ],
      ),
    );
  }
}
