import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InternetApiLayer {
  static const String baseUrl = String.fromEnvironment('DOCTOR_MITRA_API_URL');
  static bool get isConfiguredStatic => baseUrl.trim().isNotEmpty;
  bool get isConfigured => baseUrl.trim().isNotEmpty;

  Uri _uri(String path) =>
      Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}$path');

  Future<Map<String, dynamic>?> readState({String? token}) async {
    if (!isConfigured) return null;
    try {
      final response = await http.get(
        _uri('/api/state'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['success'] == true && decoded['data'] != null) {
        final data = decoded['data'] as Map<String, dynamic>;
        
        // Map backend schema keys to the legacy Flutter frontend keys:
        if (data.containsKey('appointments') && !data.containsKey('bookings')) {
          data['bookings'] = data['appointments'];
        }
        if (data.containsKey('healthRecords') && !data.containsKey('healthCards')) {
          data['healthCards'] = data['healthRecords'];
        }
        if (data.containsKey('profile')) {
          final profile = data['profile'];
          if (profile != null) {
            data['users'] = [profile, ...?(data['users'] as List?)];
            data['currentUserId'] = profile['id'] ?? profile['_id'];
          }
        }
        data['specialties'] ??= [
          'General Physician',
          'Gynecologist',
          'Cardiologist',
          'Dermatologist',
          'Neurologist',
          'Dentist'
        ];
        data['healthTips'] ??= [
          'Drink safe water and keep ORS at home.',
          'Book follow-ups early for chronic conditions.',
          'Use emergency number 102 for ambulance help.'
        ];
        data['ambulances'] ??= [];
        data['hospitals'] ??= [];
        
        return data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> writeState(Map<String, dynamic> value) async {
    // Monolithic state overwrite is deprecated in favor of granular actions.
    // Return true to avoid client-side error screens.
    return true;
  }

  Future<Map<String, dynamic>?> sendOtp(String mobile) async {
    if (!isConfigured) return null;
    try {
      final response = await http.post(
        _uri('/api/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile}),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyOtp(String mobile, String otp) async {
    if (!isConfigured) return null;
    try {
      final response = await http.post(
        _uri('/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile, 'otp': otp}),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> setupProfile({
    required String tempToken,
    required String name,
    required String district,
    required String emergencyContact,
  }) async {
    if (!isConfigured) return null;
    try {
      final response = await http.post(
        _uri('/api/auth/setup-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tempToken',
        },
        body: jsonEncode({
          'name': name,
          'district': district,
          'emergencyContact': emergencyContact,
        }),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> doctorLogin(String email, String password) async {
    if (!isConfigured) return null;
    try {
      final response = await http.post(
        _uri('/api/auth/doctor-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> doctorRegister(Map<String, dynamic> data) async {
    if (!isConfigured) return null;
    try {
      final response = await http.post(
        _uri('/api/doctors/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> adminLogin(String email, String password) async {
    if (!isConfigured) return null;
    try {
      final response = await http.post(
        _uri('/api/auth/admin-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> runAction(
    String type,
    Map<String, dynamic> payload, {
    String? token,
  }) async {
    if (!isConfigured) return null;
    try {
      final response = await http
          .post(
            _uri('/api/actions'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'type': type, 'payload': payload}),
          )
          .timeout(const Duration(seconds: 10));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return {'ok': false, 'error': decoded['error'] ?? 'Server error'};
      }
      return decoded;
    } catch (_) {
      return null;
    }
  }

  Future<bool> health() async {
    if (!isConfigured) return false;
    try {
      final response =
          await http.get(_uri('/health')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class SupabaseApiLayer {
  static const String projectUrl = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _stateId = 'singleton';

  static bool get isConfiguredStatic =>
      projectUrl.trim().isNotEmpty && anonKey.trim().isNotEmpty;
  bool get isConfigured => isConfiguredStatic;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = projectUrl.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  Map<String, String> get _headers => {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>?> readState() async {
    if (!isConfigured) return null;
    try {
      final response = await http
          .get(
            _uri('/rest/v1/doctor_mitra_state', {
              'id': 'eq.$_stateId',
              'select': 'state',
              'limit': '1',
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final rows = jsonDecode(response.body) as List<dynamic>;
      if (rows.isEmpty) return null;
      final state = (rows.first as Map<String, dynamic>)['state'];
      if (state is! Map<String, dynamic> || state['users'] is! List) {
        return null;
      }
      return state;
    } catch (_) {
      return null;
    }
  }

  Future<bool> writeState(Map<String, dynamic> value) async {
    if (!isConfigured) return false;
    try {
      final response = await http
          .post(
            _uri('/rest/v1/doctor_mitra_state', {'on_conflict': 'id'}),
            headers: {
              ..._headers,
              'Prefer': 'resolution=merge-duplicates,return=minimal',
            },
            body: jsonEncode({
              'id': _stateId,
              'state': value,
              'updated_at': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<bool> health() async {
    if (!isConfigured) return false;
    try {
      final response = await http
          .get(
            _uri('/rest/v1/doctor_mitra_state', {
              'select': 'id',
              'limit': '1',
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 6));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}

class SupabaseAuthLayer {
  static bool get isConfigured => SupabaseApiLayer.isConfiguredStatic;

  static Uri _uri(String path, [Map<String, String>? query]) {
    final base = SupabaseApiLayer.projectUrl.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  static Map<String, String> get _headers => {
        'apikey': SupabaseApiLayer.anonKey,
        'Authorization': 'Bearer ${SupabaseApiLayer.anonKey}',
        'Content-Type': 'application/json',
      };

  static String phoneForIndia(String mobile) {
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    final tenDigit =
        digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    return '+91$tenDigit';
  }

  static String _authError(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['msg'] as String? ??
          body['message'] as String? ??
          body['error_description'] as String? ??
          body['error'] as String? ??
          fallback;
    } catch (_) {
      return fallback;
    }
  }

  static Future<String?> sendPhoneOtp(String mobile) async {
    if (!isConfigured) return 'Supabase Auth is not configured';
    try {
      final response = await http
          .post(
            _uri('/auth/v1/otp'),
            headers: _headers,
            body: jsonEncode({
              'phone': phoneForIndia(mobile),
              'create_user': true,
              'data': {'role': 'patient'},
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) return null;
      return _authError(response, 'Could not send Supabase OTP');
    } catch (_) {
      return 'Supabase Auth unavailable. Demo OTP 123456 still works.';
    }
  }

  static Future<String?> verifyPhoneOtp({
    required String mobile,
    required String otp,
  }) async {
    if (!isConfigured) return 'Supabase Auth is not configured';
    try {
      final response = await http
          .post(
            _uri('/auth/v1/verify'),
            headers: _headers,
            body: jsonEncode({
              'phone': phoneForIndia(mobile),
              'token': otp.trim(),
              'type': 'sms',
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) return null;
      return _authError(response, 'Invalid Supabase OTP');
    } catch (_) {
      return 'Supabase Auth unavailable. Use demo OTP 123456.';
    }
  }

  static Future<String?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) return 'Supabase Auth is not configured';
    try {
      final response = await http
          .post(
            _uri('/auth/v1/token', {'grant_type': 'password'}),
            headers: _headers,
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) return null;
      return _authError(response, 'Invalid Supabase login credentials');
    } catch (_) {
      return 'Supabase Auth unavailable';
    }
  }

  static Future<String?> signUpWithPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    if (!isConfigured) return 'Supabase Auth is not configured';
    try {
      final response = await http
          .post(
            _uri('/auth/v1/signup'),
            headers: _headers,
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
              'data': {
                'name': name.trim(),
                'role': role,
              },
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) return null;
      return _authError(response, 'Could not create Supabase Auth user');
    } catch (_) {
      return 'Supabase Auth unavailable. Check internet and Supabase settings.';
    }
  }
}

class CloudApiLayer {
  final SupabaseApiLayer _supabase = SupabaseApiLayer();
  final InternetApiLayer _internet = InternetApiLayer();

  static bool get isConfigured =>
      SupabaseApiLayer.isConfiguredStatic ||
      InternetApiLayer.isConfiguredStatic;

  bool get isSupabase => _supabase.isConfigured;
  bool get isInternetActionApi => _internet.isConfigured;
  bool get isConfiguredInstance =>
      _supabase.isConfigured || _internet.isConfigured;

  String get syncLabel => isSupabase ? 'Supabase sync' : 'Internet sync';

  String get endpointLabel {
    if (isSupabase) return 'Supabase: ${SupabaseApiLayer.projectUrl}';
    if (_internet.isConfigured) return 'API: ${InternetApiLayer.baseUrl}';
    return 'No cloud configured. Use SUPABASE_URL + SUPABASE_ANON_KEY, or DOCTOR_MITRA_API_URL.';
  }

  Future<Map<String, dynamic>?> readState({String? token}) =>
      isSupabase ? _supabase.readState() : _internet.readState(token: token);

  Future<bool> writeState(Map<String, dynamic> value) =>
      isSupabase ? _supabase.writeState(value) : _internet.writeState(value);

  Future<bool> health() => isSupabase ? _supabase.health() : _internet.health();

  Future<Map<String, dynamic>?> runAction(
          String type, Map<String, dynamic> payload, {String? token}) =>
      _internet.runAction(type, payload, token: token);

  // Granular REST API Proxies
  Future<Map<String, dynamic>?> sendOtp(String mobile) => _internet.sendOtp(mobile);
  Future<Map<String, dynamic>?> verifyOtp(String mobile, String otp) => _internet.verifyOtp(mobile, otp);
  Future<Map<String, dynamic>?> setupProfile({
    required String tempToken,
    required String name,
    required String district,
    required String emergencyContact,
  }) => _internet.setupProfile(
    tempToken: tempToken,
    name: name,
    district: district,
    emergencyContact: emergencyContact,
  );
  Future<Map<String, dynamic>?> doctorLogin(String email, String password) => _internet.doctorLogin(email, password);
  Future<Map<String, dynamic>?> doctorRegister(Map<String, dynamic> data) => _internet.doctorRegister(data);
  Future<Map<String, dynamic>?> adminLogin(String email, String password) => _internet.adminLogin(email, password);
}
