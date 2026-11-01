import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// 1. MyApp (Root Widget)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. MaterialApp
    return MaterialApp(home: MyPage());
  }
}

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Scaffold
    return Scaffold(
      // 4a. AppBar chứa Text
      appBar: AppBar(title: const Text('Title')),
      // 4b. Body sử dụng Column chứa Container
      body: Column(children: [Container(child: const Text('Content'))]),
    );
  }
}
