import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class DiscoveredDevice {
  final String name;
  final String ip;
  final String? model;
  final String? location;

  const DiscoveredDevice({
    required this.name,
    required this.ip,
    this.model,
    this.location,
  });

  DiscoveredDevice copyWith({
    String? name,
    String? ip,
    String? model,
    String? location,
  }) {
    return DiscoveredDevice(
      name: name ?? this.name,
      ip: ip ?? this.ip,
      model: model ?? this.model,
      location: location ?? this.location,
    );
  }
}

class DiscoveryService {
  static const String _multicastAddress = '239.255.255.250';
  static const int _multicastPort = 1900;
  static const String _stScalarWebApi =
      'urn:schemas-sony-com:service:ScalarWebAPI:1';

  Future<List<DiscoveredDevice>> discover({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
      reuseAddress: true,
      reusePort: true,
    );
    socket.broadcastEnabled = true;

    final devices = <String, DiscoveredDevice>{};
    final enrichTasks = <Future<void>>[];

    final subscription = socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final datagram = socket.receive();
      if (datagram == null) return;

      final response = utf8.decode(datagram.data, allowMalformed: true);
      final headers = _parseHeaders(response);
      if (!_isLikelyBravia(headers)) return;

      final ip = datagram.address.address;
      if (devices.containsKey(ip)) return;

      final location = headers['LOCATION'];
      final name = _inferName(headers) ?? 'Sony BRAVIA';

      final device = DiscoveredDevice(
        name: name,
        ip: ip,
        location: location,
      );
      devices[ip] = device;

      if (location != null && location.isNotEmpty) {
        enrichTasks.add(_enrichDevice(device).then((enriched) {
          devices[ip] = enriched;
        }));
      }
    });

    _sendSearch(socket, _stScalarWebApi);
    _sendSearch(socket, 'ssdp:all');
    await Future.delayed(timeout);
    await subscription.cancel();
    socket.close();

    if (enrichTasks.isNotEmpty) {
      try {
        await Future.wait(enrichTasks)
            .timeout(const Duration(seconds: 3));
      } catch (_) {}
    }

    final results = devices.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return results;
  }

  void _sendSearch(RawDatagramSocket socket, String st) {
    final request = StringBuffer()
      ..writeln('M-SEARCH * HTTP/1.1')
      ..writeln('HOST: $_multicastAddress:$_multicastPort')
      ..writeln('MAN: "ssdp:discover"')
      ..writeln('MX: 2')
      ..writeln('ST: $st')
      ..writeln();

    socket.send(
      utf8.encode(request.toString()),
      InternetAddress(_multicastAddress),
      _multicastPort,
    );
  }

  Map<String, String> _parseHeaders(String response) {
    final headers = <String, String>{};
    final lines = response.split(RegExp(r'\r?\n'));
    for (final line in lines) {
      final index = line.indexOf(':');
      if (index <= 0) continue;
      final key = line.substring(0, index).trim().toUpperCase();
      final value = line.substring(index + 1).trim();
      headers[key] = value;
    }
    return headers;
  }

  bool _isLikelyBravia(Map<String, String> headers) {
    final candidate = [
      headers['ST'],
      headers['SERVER'],
      headers['USN'],
      headers['LOCATION'],
    ].whereType<String>().join(' ').toLowerCase();

    return candidate.contains('sony') ||
        candidate.contains('bravia') ||
        candidate.contains('scalarwebapi');
  }

  String? _inferName(Map<String, String> headers) {
    final server = headers['SERVER'] ?? '';
    if (server.toLowerCase().contains('bravia')) {
      return 'BRAVIA TV';
    }
    return null;
  }

  Future<DiscoveredDevice> _enrichDevice(DiscoveredDevice device) async {
    final location = device.location;
    if (location == null || location.isEmpty) return device;

    try {
      final response = await http
          .get(Uri.parse(location))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode != 200) return device;

      final document = XmlDocument.parse(response.body);
      final friendlyName = _firstElementText(document, 'friendlyName');
      final modelName = _firstElementText(document, 'modelName');

      return device.copyWith(
        name: friendlyName ?? device.name,
        model: modelName ?? device.model,
      );
    } catch (_) {
      return device;
    }
  }

  String? _firstElementText(XmlDocument document, String tag) {
    final elements = document.findAllElements(tag);
    if (elements.isEmpty) return null;
    final text = elements.first.innerText.trim();
    return text.isEmpty ? null : text;
  }
}
