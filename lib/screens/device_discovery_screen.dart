import 'package:flutter/material.dart';
import '../services/discovery_service.dart';

class DeviceDiscoveryScreen extends StatefulWidget {
  const DeviceDiscoveryScreen({super.key});

  @override
  State<DeviceDiscoveryScreen> createState() => _DeviceDiscoveryScreenState();
}

class _DeviceDiscoveryScreenState extends State<DeviceDiscoveryScreen> {
  final DiscoveryService _service = DiscoveryService();
  bool _isScanning = false;
  String? _error;
  List<DiscoveredDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _isScanning = true;
      _error = null;
      _devices = [];
    });

    try {
      final results = await _service.discover();
      if (!mounted) return;
      setState(() {
        _devices = results;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Scan failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Auto Discover'),
        backgroundColor: Colors.grey[850],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scan,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[900]?.withAlpha(77),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[700]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Make sure your phone and TV are on the same Wi-Fi.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isScanning) ...[
                const Center(
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Scanning for BRAVIA TVs...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ] else if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _scan,
                  child: const Text('Try Again'),
                ),
              ] else if (_devices.isEmpty) ...[
                const Text(
                  'No devices found.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _scan,
                  child: const Text('Rescan'),
                ),
              ] else ...[
                Expanded(
                  child: ListView.separated(
                    itemCount: _devices.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.white12),
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        title: Text(
                          device.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          device.model == null
                              ? device.ip
                              : '${device.model} · ${device.ip}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: const Icon(Icons.chevron_right,
                            color: Colors.white54),
                        onTap: () => Navigator.pop(context, device),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
