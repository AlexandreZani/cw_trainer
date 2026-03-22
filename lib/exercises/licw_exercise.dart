import 'package:cw_trainer/config/config.dart';

final bc1Groups = ["TIN", "PSG", "LCD", "HOF", "UWB", "REA"];

String licwCharacters(LicwConfig config) {
  return bc1Groups.asMap().entries.fold("", (acc, e) {
    if (config.bc1GroupsSelected.contains(e.key)) {
      return acc + e.value;
    } else {
      return acc;
    }
  });
}
