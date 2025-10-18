import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'استراحة البرق نت',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  bool _isLoading = true;
  double _progress = 0;
  
  // إعدادات السيرفر - اضبطها حسب سيرفرك
  final TextEditingController _ipController = TextEditingController(text: '192.168.21.90');
  final TextEditingController _portController = TextEditingController(text: '80');
  final TextEditingController _pathController = TextEditingController(text: '');
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _loadServer();
  }

  void _loadServer() {
    String ip = _ipController.text.trim();
    String port = _portController.text.trim();
    String path = _pathController.text.trim();
    
    if (ip.isEmpty) return;
    
    String url = 'http://$ip';
    if (port.isNotEmpty && port != '80') {
      url += ':$port';
    }
    if (path.isNotEmpty) {
      if (!path.startsWith('/')) path = '/$path';
      url += path;
    }
    
    setState(() {
      _currentUrl = url;
      _isLoading = true;
    });
    
    _controller.future.then((controller) {
      controller.loadUrl(url);
    });
  }

  void _showServerSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.computer, color: Colors.indigo),
              SizedBox(width: 10),
              Text('إعدادات السيرفر'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: 'IP السيرفر',
                    hintText: '192.168.21.90',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'المنفذ',
                    hintText: '80',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _pathController,
                  decoration: const InputDecoration(
                    labelText: 'المسار',
                    hintText: '/admin أو /dashboard',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadServer();
              },
              child: const Text('اتصل'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌩️ استراحة البرق نت'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showServerSettings(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadServer,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading && _progress > 0)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          
          Expanded(
            child: WebView(
              initialUrl: _currentUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController controller) {
                _controller.complete(controller);
              },
              onProgress: (int progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
              onPageStarted: (String url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
