import 'dart:isolate';

// Required for Flutter Material widgets.
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainThreadDemoScreen(),
    );
  }
}

class MainThreadDemoScreen extends StatefulWidget {
  const MainThreadDemoScreen({super.key});

  @override
  State<MainThreadDemoScreen> createState() => _MainThreadDemoScreenState();
}

class _MainThreadDemoScreenState extends State<MainThreadDemoScreen> {
  String _status = 'Trạng thái: Đang rảnh rỗi';
  bool _isCalculating = false;

  int _calculateHugeSum(int limit) {
    int sum = 0;
    for (int i = 0; i < limit; i++) {
      sum += i;
    }
    return sum;
  }

  Future<void> _doHeavyWorkInBackground() async {
    if (_isCalculating) return;

    setState(() {
      _isCalculating = true;
      _status = 'Đang tính toán trên background isolate...';
    });

    try {
      final result = await Isolate.run(() => _calculateHugeSum(5_000_000_000));

      if (!mounted) return;
      setState(() {
        _status = 'Xong! Kết quả: $result';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Main Thread')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isCalculating) const CircularProgressIndicator(),
            if (!_isCalculating)
              const Icon(Icons.check_circle, size: 40, color: Colors.green),
            const SizedBox(height: 20),
            Text(_status, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isCalculating ? null : _doHeavyWorkInBackground,
              child: Text(
                _isCalculating
                    ? 'Đang xử lý...'
                    : 'Chạy việc nặng trên background',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
