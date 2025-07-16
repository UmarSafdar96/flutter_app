// core/storage/hive_manager.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class HiveManager {
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
   // final key = encrypt.Key.fromUtf8('32characterslongsecretkeyforhive!!');
    _box = await Hive.openBox('secureBox');
  }

  static Box get box {
    if (!Hive.isBoxOpen('secureBox')) {
      throw HiveError('Hive box not open. Call HiveManager.init() first.');
    }
    return _box;
  }
}
