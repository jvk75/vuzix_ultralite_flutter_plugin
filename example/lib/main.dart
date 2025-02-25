import 'package:flutter/material.dart';
import 'package:vuzix_ultralite_flutter_plugin/vuzix_ultralite_flutter_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;
  bool _isConnected = false;
  String _deviceInfo = 'Not connected';
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePlugin();
  }

  Future<void> _initializePlugin() async {
    try {
      final initialized = await VuzixUltralitePlugin.initialize();
      setState(() {
        _isInitialized = initialized;
      });

      if (initialized) {
        VuzixUltralitePlugin.connectionState.listen((state) {
          setState(() {
            _isConnected = state == 'connected';
          });
        });
      }
    } catch (e) {
      debugPrint('Error initializing plugin: $e');
    }
  }

  Future<void> _connect() async {
    try {
      final connected = await VuzixUltralitePlugin.connect();
      if (connected) {
        final deviceInfo = await VuzixUltralitePlugin.getDeviceInfo();
        setState(() {
          _deviceInfo = deviceInfo.toString();
        });
      }
    } catch (e) {
      debugPrint('Error connecting: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      await VuzixUltralitePlugin.disconnect();
      setState(() {
        _deviceInfo = 'Not connected';
      });
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }

  Future<void> _sendText() async {
    if (_textController.text.isEmpty) return;
    try {
      await VuzixUltralitePlugin.sendText(_textController.text);
    } catch (e) {
      debugPrint('Error sending text: $e');
    }
  }

  Future<void> _clearDisplay() async {
    try {
      await VuzixUltralitePlugin.clearDisplay();
    } catch (e) {
      debugPrint('Error clearing display: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Vuzix Ultralite Plugin Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Initialized: $_isInitialized'),
              Text('Connected: $_isConnected'),
              Text('Device Info: $_deviceInfo'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized && !_isConnected ? _connect : null,
                child: const Text('Connect'),
              ),
              ElevatedButton(
                onPressed: _isConnected ? _disconnect : null,
                child: const Text('Disconnect'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Text to display',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isConnected ? _sendText : null,
                child: const Text('Send Text'),
              ),
              ElevatedButton(
                onPressed: _isConnected ? _clearDisplay : null,
                child: const Text('Clear Display'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
