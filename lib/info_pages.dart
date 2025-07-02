import 'package:cw_trainer/main.dart';
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

  Future<String> appVersion(BuildContext context) async {
    var pubspecS =
        await DefaultAssetBundle.of(context).loadString("pubspec.yaml");
    var pubspec = loadYaml(pubspecS);
    return pubspec['version'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: appVersion(context),
        builder: (context, asyncSnapshot) {
          if (!asyncSnapshot.hasData) {
            return const CircularProgressIndicator();
          }

          var version = asyncSnapshot.data!;
          return ListView(
            children: [
              Column(
                children: [
                  AboutEntry(name: "Version", value: version),
                  const AboutEntry(name: "Author", value: "Alexandre Zani"),
                  const AboutEntry(
                    name: "Email",
                    value: "cw_trainer@zfc.io",
                    uri: "mailto:cw_trainer@zfc.io",
                  ),
                  const AboutEntry(name: "Call Sign", value: "K7ZFC"),
                  const AboutEntry(
                      name: "Found a Bug?",
                      uri: 'https://github.com/AlexandreZani/cw_trainer/issues',
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
