import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/tv_device.dart';
import '../services/app_settings.dart';
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

  Future<void> _startPairing() async {
    final l10n = AppLocalizations.of(context);
    if (_ipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.get('pleaseEnterIpFirst'))),
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
          SnackBar(
            content: Text(l10n.get('checkTvPin')),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.get('failedStartPairing')),
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

  Future<void> _completePairing() async {
    final l10n = AppLocalizations.of(context);
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.get('enterPin'))),
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
          SnackBar(
            content: Text(l10n.get('pairedSuccessfully')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.get('wrongPin')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context);
    if (_ipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.get('pleaseEnterIpFirst'))),
      );
      return;
    }

    if (_pskController.text.isEmpty && (_authCookie == null || _authCookie!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.get('pleasePairOrPsk'))),
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
          content: Text(success ? l10n.get('connectedSuccessfully') : l10n.get('connectionFailed')),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      if (_pskController.text.isEmpty && (_authCookie == null || _authCookie!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.get('pleasePairFirst'))),
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
    final l10n = AppLocalizations.of(context);
    final settings = Provider.of<AppSettings>(context);
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('tvSettings')),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(l10n.get('save')),
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
                // Setup instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withAlpha(100)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.link, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            l10n.get('easySetup'),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.grey[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.get('setupInstructions'),
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Auto discovery
                ElevatedButton.icon(
                  onPressed: _openDiscovery,
                  icon: const Icon(Icons.search),
                  label: Text(l10n.get('autoDiscover')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),

                const SizedBox(height: 16),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.get('tvName'),
                    prefixIcon: const Icon(Icons.tv),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? l10n.get('pleaseEnterName') : null,
                ),

                const SizedBox(height: 16),

                // IP field - Fixed keyboard type for proper input
                TextFormField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    labelText: l10n.get('tvIpAddress'),
                    prefixIcon: const Icon(Icons.router),
                    hintText: '192.168.1.100',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value?.isEmpty == true) return l10n.get('pleaseEnterIp');
                    final ipRegex = RegExp(
                        r'^((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$');
                    if (!ipRegex.hasMatch(value!)) {
                      return l10n.get('invalidIpFormat');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // PIN Pairing Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                              _authCookie != null ? l10n.get('paired') : l10n.get('pinPairing'),
                              style: const TextStyle(
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
                            label: Text(_authCookie != null ? l10n.get('rePair') : l10n.get('pairWithPin')),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ] else ...[
                          // PIN input
                          TextField(
                            controller: _pinController,
                            style: const TextStyle(
                              fontSize: 24,
                              letterSpacing: 8,
                            ),
                            decoration: InputDecoration(
                              hintText: '0000',
                              counterText: '',
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            textAlign: TextAlign.center,
                            autofocus: true,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _showPinInput = false),
                                  child: Text(l10n.get('cancel')),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isPairing ? null : _completePairing,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: _isPairing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Text(l10n.get('confirm')),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // OR divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.get('or'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 16),

                // PSK Section (Advanced)
                ExpansionTile(
                  title: Text(l10n.get('usePsk')),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.get('pskInstructions'),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _pskController,
                            decoration: InputDecoration(
                              labelText: l10n.get('preSharedKey'),
                              prefixIcon: const Icon(Icons.key),
                            ),
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
                  label: Text(_isTesting ? l10n.get('testing') : l10n.get('testConnection')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: _connectionStatus == null
                          ? Colors.grey
                          : _connectionStatus!
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save button
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.get('saveSettings'),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Find IP help
                ExpansionTile(
                  title: Text(l10n.get('howToFindIp')),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.get('findIpInstructions'),
                        style: TextStyle(color: Colors.grey[600]),
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
}
