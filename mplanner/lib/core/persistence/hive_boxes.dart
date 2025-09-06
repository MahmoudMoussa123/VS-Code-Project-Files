import 'package:hive/hive.dart';

const String kProductsBox = 'products_box';
const String kScanHistoryBox = 'scan_history_box';
const String kPreferencesBox = 'preferences_box';

Future<void> openCoreHiveBoxes() async {
  await Future.wait([
    Hive.openBox<Map>(kProductsBox),
    Hive.openBox<Map>(kScanHistoryBox),
    Hive.openBox<Map>(kPreferencesBox),
  ]);
}