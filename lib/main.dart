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
  
  final List<String> _presetUrls = [
    'http://192.168.21.90',
    'http://localhost',
    'http://127.0.0.1',
    'asset://flutter_assets/assets/index.html',
  ];
  String _selectedUrl = 'http://192.168.21.90';
  bool _enableJavaScript = true;

  @override
  void initState() {
    super.initState();
    _loadInitialURL();
  }

  void _loadInitialURL() {
    _controller.future.then((controller) {
      controller.loadUrl(_selectedUrl);
    });
  }

  void _loadURL(String url) {
    setState(() {
      _selectedUrl = url;
      _isLoading = true;
    });
    _controller.future.then((controller) {
      controller.loadUrl(url);
    });
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.settings, color: Colors.indigo),
                  SizedBox(width: 10),
                  Text('إعدادات المتصفح'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'اختر الرابط:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    
                    ..._presetUrls.map((url) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            Icons.link,
                            color: _selectedUrl == url ? Colors.green : Colors.grey,
                          ),
                          title: Text(
                            url,
                            style: TextStyle(
                              fontSize: 12,
                              color: _selectedUrl == url ? Colors.green : Colors.black,
                              fontWeight: _selectedUrl == url ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: _selectedUrl == url 
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedUrl = url;
                            });
                            Navigator.pop(context);
                            _loadURL(url);
                          },
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 20),
                    
                    const Text(
                      'الإعدادات:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    
                    SwitchListTile(
                      title: const Text('تفعيل JavaScript'),
                      subtitle: const Text('للمواقع التفاعلية'),
                      value: _enableJavaScript,
                      onChanged: (value) {
                        setState(() {
                          _enableJavaScript = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadURL(_selectedUrl);
                  },
                  child: const Text('تطبيق'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌩️ استراحة البرق نت - محلي'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialURL,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Text(
              'الرابط: $_selectedUrl',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          if (_isLoading && _progress > 0)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          
          Expanded(
            child: RefreshIndicator(
              color: Colors.indigo,
              onRefresh: () async {
                final controller = await _controller.future;
                controller.reload();
              },
              child: WebView(
                initialUrl: _selectedUrl,
                javascriptMode: _enableJavaScript 
                    ? JavascriptMode.unrestricted 
                    : JavascriptMode.disabled,
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
                    _selectedUrl = url;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.computer),
              tooltip: 'الخادم المحلي',
              onPressed: () => _loadURL('http://192.168.21.90'),
            ),
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'الصفحة الرئيسية',
              onPressed: () => _loadURL('asset://flutter_assets/assets/index.html'),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'الإعدادات',
              onPressed: () => _showSettings(context),
            ),
          ],
        ),
      ),
    );
  }
}
