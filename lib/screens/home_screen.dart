import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/tv_device.dart';
import '../services/app_settings.dart';
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
    final l10n = AppLocalizations.of(context);
    final settings = Provider.of<AppSettings>(context);
    final isDark = settings.isDarkMode;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('appTitle')),
        actions: [
          // Language toggle
          IconButton(
            icon: Text(
              settings.locale.languageCode == 'zh' ? 'EN' : '中',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            onPressed: () => settings.toggleLocale(),
            tooltip: l10n.get('language'),
          ),
          // Theme toggle
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => settings.toggleTheme(),
            tooltip: isDark ? l10n.get('lightTheme') : l10n.get('darkTheme'),
          ),
        ],
      ),
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
                  color: Colors.blue.withAlpha(30),
                ),
                child: const Icon(
                  Icons.tv,
                  size: 80,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                l10n.get('appTitle'),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey[900],
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                l10n.get('tapToConnect'),
                style: TextStyle(
                  color: Colors.grey[600],
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
                  label: Text(l10n.get('connectToTv')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Features
              _buildFeature(
                Icons.gamepad,
                settings.locale.languageCode == 'zh' ? '完整遥控功能' : 'Full Remote Control',
                isDark,
              ),
              const SizedBox(height: 16),
              _buildFeature(
                Icons.keyboard,
                settings.locale.languageCode == 'zh' ? '文本输入搜索' : 'Text Input for Search',
                isDark,
              ),
              const SizedBox(height: 16),
              _buildFeature(
                Icons.apps,
                settings.locale.languageCode == 'zh' ? '快捷应用启动' : 'Quick App Launch',
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
