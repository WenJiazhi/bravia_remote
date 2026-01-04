import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/tv_device.dart';

class BraviaApi {
  final TvDevice device;
  final Duration timeout;
  String? _authCookie;
  static const String _noCookieSentinel = '__paired__';

  BraviaApi(this.device, {this.timeout = const Duration(seconds: 5)}) {
    _authCookie = device.authCookie;
  }

  bool get _hasAuthCookie {
    final cookie = _authCookie;
    return cookie != null && cookie.isNotEmpty && cookie != _noCookieSentinel;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Use auth cookie if available (PIN pairing), otherwise use PSK
    if (_hasAuthCookie) {
      headers['Cookie'] = _authCookie!;
    } else if (device.psk.isNotEmpty) {
      headers['X-Auth-PSK'] = device.psk;
    }

    return headers;
  }

  String get _baseUrl => 'http://${device.ip}';

  String? get authCookie => _authCookie;

  // Start PIN pairing - TV will display a 4-digit PIN
  Future<bool> startPairing() async {
    try {
      final body = jsonEncode({
        'method': 'actRegister',
        'id': 8,
        'params': [
          {
            'clientid': 'BraviaRemote:${device.name}',
            'nickname': 'Bravia Remote (${device.name})',
            'level': 'private',
          },
          [{'value': 'yes', 'function': 'WOL'}]
        ],
        'version': '1.0',
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/sony/accessControl'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(timeout);

      // 401 means TV is showing PIN code
      return response.statusCode == 401 || response.statusCode == 200;
    } catch (e) {
      developer.log('Start pairing error: $e', name: 'BraviaApi');
      return false;
    }
  }

  // Complete PIN pairing with the 4-digit code shown on TV
  Future<String?> completePairing(String pin) async {
    try {
      final body = jsonEncode({
        'method': 'actRegister',
        'id': 8,
        'params': [
          {
            'clientid': 'BraviaRemote:${device.name}',
            'nickname': 'Bravia Remote (${device.name})',
            'level': 'private',
          },
          [{'value': 'yes', 'function': 'WOL'}]
        ],
        'version': '1.0',
      });

      // PIN is sent as Basic Auth with empty username
      final credentials = base64Encode(utf8.encode(':$pin'));

      final response = await http
          .post(
            Uri.parse('$_baseUrl/sony/accessControl'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Basic $credentials',
            },
            body: body,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        // Extract auth cookie from response
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null) {
          // Parse the auth cookie
          final cookieParts = setCookie.split(';');
          _authCookie = cookieParts.first;
          return _authCookie;
        }
        // Some TVs return success without cookie, treat as paired without auth
        _authCookie = _noCookieSentinel;
        return _authCookie;
      }
      return null;
    } catch (e) {
      developer.log('Complete pairing error: $e', name: 'BraviaApi');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _sendRequest(
    String endpoint,
    String method, {
    List<dynamic>? params,
    String version = '1.0',
    int id = 1,
  }) async {
    try {
      final body = jsonEncode({
        'method': method,
        'id': id,
        'params': params ?? [],
        'version': version,
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers,
            body: body,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      developer.log('Bravia API Error: $e', name: 'BraviaApi');
      return null;
    }
  }

  // Send IRCC command (remote button press)
  Future<bool> sendIrcc(String irccCode) async {
    try {
      final soapBody = '''<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:X_SendIRCC xmlns:u="urn:schemas-sony-com:service:IRCC:1">
      <IRCCCode>$irccCode</IRCCCode>
    </u:X_SendIRCC>
  </s:Body>
</s:Envelope>''';

      final irccHeaders = <String, String>{
        'Content-Type': 'text/xml; charset=UTF-8',
        'SOAPACTION': '"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC"',
      };

      // Add auth
      if (_hasAuthCookie) {
        irccHeaders['Cookie'] = _authCookie!;
      } else if (device.psk.isNotEmpty) {
        irccHeaders['X-Auth-PSK'] = device.psk;
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/sony/IRCC'),
            headers: irccHeaders,
            body: soapBody,
          )
          .timeout(timeout);

      return response.statusCode == 200;
    } catch (e) {
      developer.log('IRCC Error: $e', name: 'BraviaApi');
      return false;
    }
  }

  // Send text to TV (for keyboard input)
  Future<bool> sendText(String text) async {
    final result = await _sendRequest(
      '/sony/appControl',
      'setTextForm',
      params: [
        {'text': text}
      ],
      version: '1.0',
    );
    return result != null && result['error'] == null;
  }

  // Power control
  Future<bool> powerOff() async {
    final result = await _sendRequest('/sony/system', 'setPowerStatus', params: [
      {'status': false}
    ]);
    return result != null;
  }

  Future<bool> powerOn() async {
    final result = await _sendRequest('/sony/system', 'setPowerStatus', params: [
      {'status': true}
    ]);
    return result != null;
  }

  // Get system info
  Future<Map<String, dynamic>?> getSystemInfo() async {
    return await _sendRequest('/sony/system', 'getSystemInformation');
  }

  // Get power status
  Future<bool> getPowerStatus() async {
    final result = await _sendRequest('/sony/system', 'getPowerStatus');
    if (result != null && result['result'] != null) {
      return result['result'][0]['status'] == 'active';
    }
    return false;
  }

  // Volume control
  Future<bool> setVolume(int volume) async {
    final result = await _sendRequest('/sony/audio', 'setAudioVolume', params: [
      {'target': 'speaker', 'volume': volume.toString()}
    ]);
    return result != null;
  }

  Future<bool> volumeUp() async {
    final result = await _sendRequest('/sony/audio', 'setAudioVolume', params: [
      {'target': 'speaker', 'volume': '+1'}
    ]);
    return result != null;
  }

  Future<bool> volumeDown() async {
    final result = await _sendRequest('/sony/audio', 'setAudioVolume', params: [
      {'target': 'speaker', 'volume': '-1'}
    ]);
    return result != null;
  }

  Future<bool> setMute(bool mute) async {
    final result = await _sendRequest('/sony/audio', 'setAudioMute', params: [
      {'status': mute}
    ]);
    return result != null;
  }

  // Get app list
  Future<List<Map<String, dynamic>>> getAppList() async {
    final result = await _sendRequest('/sony/appControl', 'getApplicationList');
    if (result != null && result['result'] != null) {
      return List<Map<String, dynamic>>.from(result['result'][0]);
    }
    return [];
  }

  // Launch app
  Future<bool> launchApp(String uri) async {
    final result = await _sendRequest('/sony/appControl', 'setActiveApp', params: [
      {'uri': uri}
    ]);
    return result != null;
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      final result = await getSystemInfo();
      return result != null && result['result'] != null;
    } catch (e) {
      return false;
    }
  }
}

// IRCC Codes for common remote buttons
class IrccCodes {
  static const String power = 'AAAAAQAAAAEAAAAVAw==';
  static const String input = 'AAAAAQAAAAEAAAAlAw==';
  static const String syncMenu = 'AAAAAgAAABoAAABYAw==';
  static const String hdmi1 = 'AAAAAgAAABoAAABaAw==';
  static const String hdmi2 = 'AAAAAgAAABoAAABbAw==';
  static const String hdmi3 = 'AAAAAgAAABoAAABcAw==';
  static const String hdmi4 = 'AAAAAgAAABoAAABdAw==';

  // Numbers
  static const String num1 = 'AAAAAQAAAAEAAAAAAw==';
  static const String num2 = 'AAAAAQAAAAEAAAABAw==';
  static const String num3 = 'AAAAAQAAAAEAAAACAw==';
  static const String num4 = 'AAAAAQAAAAEAAAADAw==';
  static const String num5 = 'AAAAAQAAAAEAAAAEAw==';
  static const String num6 = 'AAAAAQAAAAEAAAAFAw==';
  static const String num7 = 'AAAAAQAAAAEAAAAGAw==';
  static const String num8 = 'AAAAAQAAAAEAAAAHAw==';
  static const String num9 = 'AAAAAQAAAAEAAAAIAw==';
  static const String num0 = 'AAAAAQAAAAEAAAAJAw==';

  // Navigation
  static const String up = 'AAAAAQAAAAEAAAB0Aw==';
  static const String down = 'AAAAAQAAAAEAAAB1Aw==';
  static const String left = 'AAAAAQAAAAEAAAA0Aw==';
  static const String right = 'AAAAAQAAAAEAAAAzAw==';
  static const String confirm = 'AAAAAQAAAAEAAABlAw==';
  static const String back = 'AAAAAgAAAJcAAAAjAw==';
  static const String home = 'AAAAAQAAAAEAAABgAw==';
  static const String options = 'AAAAAgAAAJcAAAA2Aw==';

  // Volume
  static const String volumeUp = 'AAAAAQAAAAEAAAASAw==';
  static const String volumeDown = 'AAAAAQAAAAEAAAATAw==';
  static const String mute = 'AAAAAQAAAAEAAAAUAw==';

  // Channel
  static const String channelUp = 'AAAAAQAAAAEAAAAQAw==';
  static const String channelDown = 'AAAAAQAAAAEAAAARAw==';

  // Playback
  static const String play = 'AAAAAgAAAJcAAAAaAw==';
  static const String pause = 'AAAAAgAAAJcAAAAZAw==';
  static const String stop = 'AAAAAgAAAJcAAAAYAw==';
  static const String forward = 'AAAAAgAAAJcAAAAcAw==';
  static const String rewind = 'AAAAAgAAAJcAAAAbAw==';
  static const String next = 'AAAAAgAAAJcAAAA9Aw==';
  static const String prev = 'AAAAAgAAAJcAAAA8Aw==';

  // Color buttons
  static const String red = 'AAAAAgAAAJcAAAAlAw==';
  static const String green = 'AAAAAgAAAJcAAAAmAw==';
  static const String yellow = 'AAAAAgAAAJcAAAAnAw==';
  static const String blue = 'AAAAAgAAAJcAAAAkAw==';

  // Other
  static const String actionMenu = 'AAAAAgAAAMQAAABLAw==';
  static const String guide = 'AAAAAgAAAKQAAABbAw==';
  static const String netflix = 'AAAAAgAAABoAAAB8Aw==';
  static const String youtube = 'AAAAAgAAAMQAAABHAw==';
}
