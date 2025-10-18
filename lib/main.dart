import 'package:flutter/material.dart';

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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('🌩️ استراحة البرق نت'),
        ),
        body: const Center(
          child: Text(
            'مرحباً نايف! ⚡\nالتطبيق يعمل بنجاح',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
