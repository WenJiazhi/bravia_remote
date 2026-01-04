import 'package:flutter/material.dart';
import '../models/tv_device.dart';
import '../services/storage_service.dart';
import 'remote_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevice();
  }

  Future<void> _loadDevice() async {
    final device = await _storage.loadDevice();
    if (!mounted) return;

    if (device != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RemoteScreen(device: device),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[900]?.withAlpha(77),
                ),
                child: const Icon(
                  Icons.tv,
                  size: 80,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Bravia Remote',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Control your Sony TV',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 48),

              // Setup button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final result = await navigator.push<TvDevice?>(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );

                    if (result != null && mounted) {
                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => RemoteScreen(device: result),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Connect to TV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Features
              _buildFeature(Icons.gamepad, 'Full Remote Control'),
              const SizedBox(height: 16),
              _buildFeature(Icons.keyboard, 'Text Input for Search'),
              const SizedBox(height: 16),
              _buildFeature(Icons.apps, 'Quick App Launch'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
