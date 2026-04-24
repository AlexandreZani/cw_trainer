import 'package:cw_trainer/config/config.dart';
import 'package:cw_trainer/exercises/exercises.dart';

final bc1Groups = [
  "TIN",
  "PSG",
  "LCD",
  "HOF",
  "UWB",
  "REA",
];

final bc2Groups = [
  "KMY",
  "59,",
  "QXV",
  "73?",
  "16.",
  "ZJ/",
  "28\x03",
  "40",
  "\x04\x17\x02",
];

String licwSignsForCourse(LicwConfig config, CourseType course) {
  return switch (course) {
    CourseType.bc1 => getSelectedSigns(bc1Groups, config.bc1GroupsSelected),
    CourseType.bc2 => getSelectedSigns(bc2Groups, config.bc2GroupsSelected),
  };
}

String getSelectedSigns(List<String> groups, Set<int> selected) {
  return groups.asMap().entries.fold("", (acc, e) {
    if (selected.contains(e.key)) {
      return acc + e.value;
    } else {
      return acc;
    }
  });
}
