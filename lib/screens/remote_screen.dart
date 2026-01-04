import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tv_device.dart';
import '../services/bravia_api.dart';
import '../widgets/remote_button.dart';
import '../widgets/dpad_widget.dart';
import 'text_input_screen.dart';
import 'settings_screen.dart';

class RemoteScreen extends StatefulWidget {
  final TvDevice device;

  const RemoteScreen({super.key, required this.device});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  late BraviaApi _api;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _api = BraviaApi(widget.device);
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final connected = await _api.testConnection();
    if (!mounted) return;
    setState(() => _isConnected = connected);
    if (!connected && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot connect to TV. Check IP and PSK.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendCommand(Future<bool> Function() command) async {
    HapticFeedback.lightImpact();
    final success = await command();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Command failed'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(widget.device.name),
        backgroundColor: Colors.grey[850],
        actions: [
          IconButton(
            icon: Icon(
              Icons.circle,
              color: _isConnected ? Colors.green : Colors.red,
              size: 12,
            ),
            onPressed: _checkConnection,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TextInputScreen(api: _api),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push<TvDevice?>(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(device: widget.device),
                ),
              );
              if (result != null) {
                setState(() {
                  _api = BraviaApi(result);
                });
                _checkConnection();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Power and Input row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RemoteButton(
                    icon: Icons.power_settings_new,
                    onPressed: () =>
                        _sendCommand(() => _api.sendIrcc(IrccCodes.power)),
                    color: Colors.red[700],
                    size: 60,
                  ),
                  RemoteButton(
                    icon: Icons.input,
                    onPressed: () =>
                        _sendCommand(() => _api.sendIrcc(IrccCodes.input)),
                    size: 50,
                  ),
                  RemoteButton(
                    icon: Icons.home,
                    onPressed: () =>
                        _sendCommand(() => _api.sendIrcc(IrccCodes.home)),
                    size: 50,
                  ),
                  RemoteButton(
                    icon: Icons.arrow_back,
                    onPressed: () =>
                        _sendCommand(() => _api.sendIrcc(IrccCodes.back)),
                    size: 50,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // D-Pad
              DpadWidget(
                onUp: () => _sendCommand(() => _api.sendIrcc(IrccCodes.up)),
                onDown: () => _sendCommand(() => _api.sendIrcc(IrccCodes.down)),
                onLeft: () => _sendCommand(() => _api.sendIrcc(IrccCodes.left)),
                onRight: () =>
                    _sendCommand(() => _api.sendIrcc(IrccCodes.right)),
                onCenter: () =>
                    _sendCommand(() => _api.sendIrcc(IrccCodes.confirm)),
              ),

              const SizedBox(height: 30),

              // Volume and Channel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Volume controls
                  Column(
                    children: [
                      const Text('VOL',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      RemoteButton(
                        icon: Icons.add,
                        onPressed: () => _sendCommand(
                            () => _api.sendIrcc(IrccCodes.volumeUp)),
                        size: 50,
                      ),
                      const SizedBox(height: 8),
                      RemoteButton(
                        icon: Icons.volume_off,
                        onPressed: () =>
                            _sendCommand(() => _api.sendIrcc(IrccCodes.mute)),
                        size: 40,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(height: 8),
                      RemoteButton(
                        icon: Icons.remove,
                        onPressed: () => _sendCommand(
                            () => _api.sendIrcc(IrccCodes.volumeDown)),
                        size: 50,
                      ),
                    ],
                  ),
                  // Playback controls
                  Column(
                    children: [
                      Row(
                        children: [
                          RemoteButton(
                            icon: Icons.fast_rewind,
                            onPressed: () => _sendCommand(
                                () => _api.sendIrcc(IrccCodes.rewind)),
                            size: 45,
                          ),
                          const SizedBox(width: 8),
                          RemoteButton(
                            icon: Icons.play_arrow,
                            onPressed: () => _sendCommand(
                                () => _api.sendIrcc(IrccCodes.play)),
                            size: 50,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 8),
                          RemoteButton(
                            icon: Icons.fast_forward,
                            onPressed: () => _sendCommand(
                                () => _api.sendIrcc(IrccCodes.forward)),
                            size: 45,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          RemoteButton(
                            icon: Icons.pause,
                            onPressed: () => _sendCommand(
                                () => _api.sendIrcc(IrccCodes.pause)),
                            size: 45,
                          ),
                          const SizedBox(width: 8),
                          RemoteButton(
                            icon: Icons.stop,
                            onPressed: () => _sendCommand(
                                () => _api.sendIrcc(IrccCodes.stop)),
                            size: 45,
                            color: Colors.red[600],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Channel controls
                  Column(
                    children: [
                      const Text('CH',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      RemoteButton(
                        icon: Icons.keyboard_arrow_up,
                        onPressed: () => _sendCommand(
                            () => _api.sendIrcc(IrccCodes.channelUp)),
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      RemoteButton(
                        icon: Icons.keyboard_arrow_down,
                        onPressed: () => _sendCommand(
                            () => _api.sendIrcc(IrccCodes.channelDown)),
                        size: 50,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Number pad
              _buildNumberPad(),

              const SizedBox(height: 20),

              // Quick Apps
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAppButton('Netflix', Colors.red, IrccCodes.netflix),
                  _buildAppButton('YouTube', Colors.red[900]!, IrccCodes.youtube),
                  RemoteButton(
                    icon: Icons.menu,
                    onPressed: () =>
                        _sendCommand(() => _api.sendIrcc(IrccCodes.options)),
                    size: 45,
                  ),
                  RemoteButton(
                    icon: Icons.tv,
                    onPressed: () =>
                        _sendCommand(() => _api.sendIrcc(IrccCodes.guide)),
                    size: 45,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Color buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RemoteButton(
                    text: '',
                    onPressed: () =>
                        _sendCommand(() => _api.sendIrcc(IrccCodes.red)),
                    size: 40,
                    color: Colors.red,
                  ),
                  RemoteButton(
                    text: '',
                    onPressed: () =>
                        _sendCommand(() => _api.sendIrcc(IrccCodes.green)),
                    size: 40,
                    color: Colors.green,
                  ),
                  RemoteButton(
                    text: '',
                    onPressed: () =>
                        _sendCommand(() => _api.sendIrcc(IrccCodes.yellow)),
                    size: 40,
                    color: Colors.yellow[700],
                  ),
                  RemoteButton(
                    text: '',
                    onPressed: () =>
                        _sendCommand(() => _api.sendIrcc(IrccCodes.blue)),
                    size: 40,
                    color: Colors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Text Input Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TextInputScreen(api: _api),
                      ),
                    );
                  },
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Text Input'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    final numbers = [
      ['1', IrccCodes.num1],
      ['2', IrccCodes.num2],
      ['3', IrccCodes.num3],
      ['4', IrccCodes.num4],
      ['5', IrccCodes.num5],
      ['6', IrccCodes.num6],
      ['7', IrccCodes.num7],
      ['8', IrccCodes.num8],
      ['9', IrccCodes.num9],
      ['', ''],
      ['0', IrccCodes.num0],
      ['', ''],
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: numbers.map((item) {
        if (item[0].isEmpty) {
          return const SizedBox(width: 50, height: 50);
        }
        return RemoteButton(
          text: item[0],
          onPressed: () => _sendCommand(() => _api.sendIrcc(item[1])),
          size: 50,
          isCircle: false,
        );
      }).toList(),
    );
  }

  Widget _buildAppButton(String name, Color color, String irccCode) {
    return SizedBox(
      width: 70,
      height: 40,
      child: ElevatedButton(
        onPressed: () => _sendCommand(() => _api.sendIrcc(irccCode)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.zero,
        ),
        child: Text(
          name,
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  }
}
