import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/bravia_api.dart';

class TextInputScreen extends StatefulWidget {
  final BraviaApi api;

  const TextInputScreen({super.key, required this.api});

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  final List<String> _history = [];
  String? _lastDebugInfo;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final result = await widget.api.sendTextWithDebug(text);
    final success = result['success'] as bool;
    _lastDebugInfo = result['debug'] as String?;

    if (!mounted) return;
    setState(() => _isSending = false);

    final l10n = AppLocalizations.of(context);
    if (success) {
      setState(() {
        if (!_history.contains(text)) {
          _history.insert(0, text);
          if (_history.length > 10) _history.removeLast();
        }
      });
      _controller.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.get('textSentSuccessfully')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      if (mounted) {
        _showDebugDialog(l10n);
      }
    }
  }

  void _showDebugDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(
          l10n.get('failedToSendText'),
          style: const TextStyle(color: Colors.red),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Debug Info:',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _lastDebugInfo ?? 'No debug info',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.get('confirm')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(l10n.get('textInput')),
        backgroundColor: Colors.grey[850],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[900]?.withAlpha(77),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[700]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          l10n.get('howToUse'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.get('textInputInstructions'),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Text input
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: l10n.get('enterTextToSend'),
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () {
                            _controller.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) => setState(() {}),
                onSubmitted: (_) => _sendText(),
                autofocus: true,
                textInputAction: TextInputAction.send,
              ),

              const SizedBox(height: 16),

              // Send button
              ElevatedButton(
                onPressed: _isSending ? null : _sendText,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send),
                          const SizedBox(width: 8),
                          Text(l10n.get('sendToTv'),
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // History
              if (_history.isNotEmpty) ...[
                Text(
                  l10n.get('recent'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      return Card(
                        color: Colors.grey[800],
                        child: ListTile(
                          title: Text(
                            item,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.send,
                                    color: Colors.blue, size: 20),
                                onPressed: () async {
                                  setState(() => _isSending = true);
                                  await widget.api.sendText(item);
                                  if (!mounted) return;
                                  setState(() => _isSending = false);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.content_copy,
                                    color: Colors.white54, size: 20),
                                onPressed: () {
                                  _controller.text = item;
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.get('sentTextsAppearHere'),
                      style: const TextStyle(color: Colors.white38),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
