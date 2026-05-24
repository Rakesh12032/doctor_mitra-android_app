import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageLayer {
  static const _stateKey = 'doctor_mitra_role_mvp_state_v1';

  Future<Map<String, dynamic>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_stateKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> write(Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stateKey, jsonEncode(value));
  }
}
