import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tv_device.dart';

class StorageService {
  static const String _deviceKey = 'saved_device';

  Future<void> saveDevice(TvDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceKey, jsonEncode(device.toJson()));
  }

  Future<TvDevice?> loadDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_deviceKey);
    if (json != null) {
      return TvDevice.fromJson(jsonDecode(json));
    }
    return null;
  }

  Future<void> clearDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceKey);
  }
}
