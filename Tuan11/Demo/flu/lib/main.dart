import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ComputeDemoApp());
}

// Cùng một hàm xử lý CPU được dùng cho cả hai cách chạy.
// Đặt ngoài class để compute() có thể gọi an toàn trong isolate.
int heavyCalculation(int iterations) {
  int checksum = 0;
  for (int i = 0; i < iterations; i++) {
    checksum = (checksum + (i * 31) % 97) % 1000000007;
  }
  return checksum;
}
class ComputeDemoApp extends StatelessWidget {
  const ComputeDemoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Main Thread vs Isolate',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      home: const ComputeDemoPage(),
    );
  }
}
class ComputeDemoPage extends StatefulWidget {
  const ComputeDemoPage({super.key});
  @override
  State<ComputeDemoPage> createState() => _ComputeDemoPageState();
}
class _ComputeDemoPageState extends State<ComputeDemoPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  bool _isRunning = false;
  double _millions = 40;
  String _status = 'Chọn một nút để bắt đầu thử nghiệm.';
  Duration? _mainThreadTime;
  Duration? _isolateTime;
  int? _mainThreadResult;
  int? _isolateResult;
  int? _mainThreadIterations;
  int? _isolateIterations;
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }
  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }
  Future<void> _runTask({required bool usingIsolate}) async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _status = usingIsolate
          ? 'Đang tính bằng Isolate (compute)...'
          : 'Đang tính trên Main Thread...';
    });
    try {
      // Cho giao diện có thời gian hiển thị trạng thái trước khi tính.
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;

      final int iterations = _millions.round() * 1000000;
      final stopwatch = Stopwatch()..start();

      final int result;
      if (usingIsolate) {
        // CPU chạy trong isolate khác, không chặn animation của UI.
        result = await compute<int, int>(heavyCalculation, iterations);
      } else {
        // CPU chạy ngay trên main isolate, chặn việc vẽ frame UI.
        result = heavyCalculation(iterations);
      }
      stopwatch.stop();
      if (!mounted) return;
      setState(() {
        if (usingIsolate) {
          _isolateTime = stopwatch.elapsed;
          _isolateResult = result;
          _isolateIterations = iterations;
        } else {
          _mainThreadTime = stopwatch.elapsed;
          _mainThreadResult = result;
          _mainThreadIterations = iterations;
        }
        _status = usingIsolate
            ? 'Hoàn tất bằng Isolate: hiệu ứng vẫn có thể chạy mượt.'
            : 'Hoàn tất trên Main Thread: hiệu ứng bị khựng khi tính.';
      });
    } catch (error) {
      if (mounted) {
        setState(() => _status = 'Có lỗi: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isRunning = false);
      }
    }
  }
  Widget _resultTile(
    String title, Duration? duration, int? result, int? iterations,
  ) {
    final time = duration == null
        ? 'Chưa chạy'
        : '${(duration.inMicroseconds / 1000000).toStringAsFixed(2)} giây';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Số vòng lặp: ${iterations == null ? "—" : "${iterations ~/ 1000000} triệu"}'),
            Text('Thời gian: $time'),
            Text('Kết quả: ${result ?? "—"}'),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Main Thread và Isolate')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'So sánh hiệu ứng khi tính toán nặng',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quan sát biểu tượng xoay liên tục khi bấm từng nút.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Center(
                child: SizedBox(
                  width: 118,
                  height: 118,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 112,
                        height: 112,
                        child: CircularProgressIndicator(strokeWidth: 5),
                      ),
                      RotationTransition(
                        turns: _rotationController,
                        child: Icon(
                          Icons.autorenew_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              Text(
                'Khối lượng: ${_millions.round()} triệu vòng lặp',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _millions,
                min: 10,
                max: 80,
                divisions: 14,
                label: '${_millions.round()} triệu',
                onChanged: _isRunning
                    ? null
                    : (value) => setState(() => _millions = value),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isRunning
                    ? null
                    : () => _runTask(usingIsolate: false),
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('1. Chạy trên Main Thread'),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: _isRunning
                    ? null
                    : () => _runTask(usingIsolate: true),
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('2. Chạy bằng Isolate (compute)'),
              ),
              const SizedBox(height: 22),
              const Text(
                'Kết quả đo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _resultTile(
                'Main Thread',
                _mainThreadTime,
                _mainThreadResult,
                _mainThreadIterations,
              ),
              _resultTile(
                'Isolate (compute)',
                _isolateTime,
                _isolateResult,
                _isolateIterations,
              ),
              const SizedBox(height: 12),
              const Text(
                'Lưu ý: compute() trên Flutter Web vẫn chạy trên luồng chính. '
                'Hãy thử trên Android, iOS hoặc desktop để thấy rõ khác biệt.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}