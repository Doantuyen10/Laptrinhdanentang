import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'heavy_tasks.dart';

void main() {
  runApp(const ComputeDemoApp());
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

enum TaskType { loop, json }

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
  TaskType _taskType = TaskType.loop;
  String _status = 'Chọn một nút để bắt đầu thử nghiệm.';
  Duration? _mainThreadTime;
  Duration? _isolateTime;
  int? _mainThreadResult;
  int? _isolateResult;
  String? _mainThreadWorkload;
  String? _isolateWorkload;

  String get _currentWorkload => _taskType == TaskType.loop
      ? '${_millions.round()} triệu vòng lặp'
      : '${_millions.round() * 5} nghìn phần tử JSON';

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
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;

      final bool isLoop = _taskType == TaskType.loop;
      final int size =
          isLoop ? _millions.round() * 1000000 : _millions.round() * 5000;
      final String workload = _currentWorkload;
      final stopwatch = Stopwatch()..start();

      final int result;
      if (usingIsolate) {
        if (isLoop) {
          result = await compute(heavyCalculation, size);
        } else {
          result = await compute(jsonTask, size);
        }
      } else {
        result = isLoop ? heavyCalculation(size) : jsonTask(size);
      }

      stopwatch.stop();
      if (!mounted) return;

      setState(() {
        if (usingIsolate) {
          _isolateTime = stopwatch.elapsed;
          _isolateResult = result;
          _isolateWorkload = workload;
        } else {
          _mainThreadTime = stopwatch.elapsed;
          _mainThreadResult = result;
          _mainThreadWorkload = workload;
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
    String title,
    Duration? duration,
    int? result,
    String? workload,
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
            Text('Khối lượng: ${workload ?? "—"}'),
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
              SegmentedButton<TaskType>(
                segments: const [
                  ButtonSegment(
                    value: TaskType.loop,
                    label: Text('Vòng lặp lớn'),
                    icon: Icon(Icons.loop),
                  ),
                  ButtonSegment(
                    value: TaskType.json,
                    label: Text('Parse JSON dài'),
                    icon: Icon(Icons.data_object),
                  ),
                ],
                selected: {_taskType},
                onSelectionChanged: _isRunning
                    ? null
                    : (selection) =>
                        setState(() => _taskType = selection.first),
              ),
              const SizedBox(height: 16),
              Text(
                'Khối lượng: $_currentWorkload',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _millions,
                min: 10,
                max: 80,
                divisions: 14,
                label: _currentWorkload,
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
                _mainThreadWorkload,
              ),
              _resultTile(
                'Isolate (compute)',
                _isolateTime,
                _isolateResult,
                _isolateWorkload,
              ),
            ],
          ),
        ),
      ),
    );
  }
}