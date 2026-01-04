import 'package:flutter/material.dart';
import '../models/tv_device.dart';
import '../services/bravia_api.dart';
import '../services/discovery_service.dart';
import '../services/storage_service.dart';
import 'device_discovery_screen.dart';

class SettingsScreen extends StatefulWidget {
  final TvDevice? device;

  const SettingsScreen({super.key, this.device});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ipController;
  late TextEditingController _pskController;
  late TextEditingController _pinController;
  bool _isTesting = false;
  bool _isPairing = false;
  bool _showPinInput = false;
  bool? _connectionStatus;
  String? _authCookie;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device?.name ?? 'Sony TV');
    _ipController = TextEditingController(text: widget.device?.ip ?? '');
    _pskController = TextEditingController(text: widget.device?.psk ?? '');
    _pinController = TextEditingController();
    _authCookie = widget.device?.authCookie;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _pskController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // Start PIN pairing process
  Future<void> _startPairing() async {
    if (_ipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter TV IP address first')),
      );
      return;
    }

    setState(() => _isPairing = true);

    final tempDevice = TvDevice(
      name: _nameController.text,
      ip: _ipController.text,
    );

    final api = BraviaApi(tempDevice);
    final started = await api.startPairing();

    setState(() => _isPairing = false);

    if (started) {
      setState(() => _showPinInput = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your TV! Enter the 4-digit PIN shown.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start pairing. Check TV IP and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openDiscovery() async {
    final result = await Navigator.push<DiscoveredDevice?>(
      context,
      MaterialPageRoute(
        builder: (context) => const DeviceDiscoveryScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _ipController.text = result.ip;
        if (_nameController.text.trim().isEmpty ||
            _nameController.text.trim() == 'Sony TV') {
          _nameController.text = result.name;
        }
        _pskController.clear();
        _authCookie = null;
        _showPinInput = false;
        _connectionStatus = null;
      });
    }
  }

  // Complete pairing with PIN
  Future<void> _completePairing() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 4-digit PIN')),
      );
      return;
    }

    setState(() => _isPairing = true);

    final tempDevice = TvDevice(
      name: _nameController.text,
      ip: _ipController.text,
    );

    final api = BraviaApi(tempDevice);
    final cookie = await api.completePairing(pin);

    setState(() => _isPairing = false);

    if (cookie != null) {
      setState(() {
        _authCookie = cookie;
        _showPinInput = false;
        _connectionStatus = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paired successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong PIN. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testConnection() async {
    if (_ipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter IP address first')),
      );
      return;
    }

    // Need either PSK or auth cookie
    if (_pskController.text.isEmpty && (_authCookie == null || _authCookie!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pair with PIN or enter PSK')),
      );
      return;
    }

    setState(() {
      _isTesting = true;
      _connectionStatus = null;
    });

    final testDevice = TvDevice(
      name: _nameController.text,
      ip: _ipController.text,
      psk: _pskController.text,
      authCookie: _authCookie,
    );

    final api = BraviaApi(testDevice);
    final success = await api.testConnection();

    setState(() {
      _isTesting = false;
      _connectionStatus = success;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Connected successfully!' : 'Connection failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      // Need either PSK or auth cookie
      if (_pskController.text.isEmpty && (_authCookie == null || _authCookie!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pair with PIN or enter PSK first')),
        );
        return;
      }

      final device = TvDevice(
        name: _nameController.text.trim(),
        ip: _ipController.text.trim(),
        psk: _pskController.text.trim(),
        authCookie: _authCookie,
      );

      await _storage.saveDevice(device);

      if (mounted) {
        Navigator.pop(context, device);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('TV Settings'),
        backgroundColor: Colors.grey[850],
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Setup instructions - Updated for PIN pairing
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[900]?.withAlpha(77),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[700]!),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.link, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Easy Setup (Recommended)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        '1. Make sure phone and TV are on same WiFi\n'
                        '2. Enter your TV\'s IP address\n'
                        '3. Tap "Pair with PIN"\n'
                        '4. Enter the 4-digit code shown on TV',
                        style: TextStyle(color: Colors.white70, height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Auto discovery
                ElevatedButton.icon(
                  onPressed: _openDiscovery,
                  icon: const Icon(Icons.search),
                  label: const Text('Auto Discover'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),

                const SizedBox(height: 16),

                // Name field
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('TV Name', Icons.tv),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter a name' : null,
                ),

                const SizedBox(height: 16),

                // IP field
                TextFormField(
                  controller: _ipController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('TV IP Address', Icons.router),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Please enter IP address';
                    final ipRegex = RegExp(
                        r'^((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$');
                    if (!ipRegex.hasMatch(value!)) {
                      return 'Invalid IP address format';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // PIN Pairing Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _authCookie != null ? Icons.check_circle : Icons.pin,
                            color: _authCookie != null ? Colors.green : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _authCookie != null ? 'Paired' : 'PIN Pairing',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (!_showPinInput) ...[
                        ElevatedButton.icon(
                          onPressed: _isPairing ? null : _startPairing,
                          icon: _isPairing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(_authCookie != null ? Icons.refresh : Icons.link),
                          label: Text(_authCookie != null ? 'Re-pair' : 'Pair with PIN'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ] else ...[
                        // PIN input
                        TextField(
                          controller: _pinController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            letterSpacing: 8,
                          ),
                          decoration: InputDecoration(
                            hintText: '0000',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() => _showPinInput = false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isPairing ? null : _completePairing,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                ),
                                child: _isPairing
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Confirm'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // OR divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[700])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: Colors.grey[600])),
                    ),
                    Expanded(child: Divider(color: Colors.grey[700])),
                  ],
                ),

                const SizedBox(height: 16),

                // PSK Section (Advanced)
                ExpansionTile(
                  title: const Text(
                    'Use Pre-Shared Key (Advanced)',
                    style: TextStyle(color: Colors.white70),
                  ),
                  collapsedIconColor: Colors.white54,
                  iconColor: Colors.white,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'If PIN pairing doesn\'t work, you can use PSK:\n'
                            '1. TV Settings > Network > IP Control\n'
                            '2. Set Authentication to "Pre-Shared Key"\n'
                            '3. Enter a password and use it below',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _pskController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Pre-Shared Key (PSK)', Icons.key),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Test connection button
                OutlinedButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _connectionStatus == null
                              ? Icons.wifi_find
                              : _connectionStatus!
                                  ? Icons.check_circle
                                  : Icons.error,
                          color: _connectionStatus == null
                              ? null
                              : _connectionStatus!
                                  ? Colors.green
                                  : Colors.red,
                        ),
                  label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: _connectionStatus == null
                          ? Colors.white54
                          : _connectionStatus!
                              ? Colors.green
                              : Colors.red,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 24),

                // Save button
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Settings',
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Find IP help
                ExpansionTile(
                  title: const Text(
                    'How to find TV IP address',
                    style: TextStyle(color: Colors.white70),
                  ),
                  collapsedIconColor: Colors.white54,
                  iconColor: Colors.white,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '1. Go to TV Settings\n'
                        '2. Select Network > Network Status\n'
                        '3. Look for "IP Address"\n\n'
                        'Common format: 192.168.x.x',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
