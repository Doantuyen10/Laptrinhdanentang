import 'package:flutter/material.dart';

void main() {
  runApp(const LayoutDemoApp());
}

// StatelessWidget: cấu hình ứng dụng không cần quản lý trạng thái thay đổi.
class LayoutDemoApp extends StatelessWidget {
  const LayoutDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Layout Lab',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        scaffoldBackgroundColor: const Color(0xFFF5F7FC),
      ),
      home: const StudyDashboard(),
    );
  }
}

// StatefulWidget: lưu trạng thái đánh dấu công việc và tuỳ chỉnh bố cục.
class StudyDashboard extends StatefulWidget {
  const StudyDashboard({super.key});

  @override
  State<StudyDashboard> createState() => _StudyDashboardState();
}

class _StudyDashboardState extends State<StudyDashboard> {
  final List<String> _tasks = [
    'Tìm hiểu Widget Tree',
    'Phân biệt StatelessWidget và StatefulWidget',
    'Thực hành Row, Column và Padding',
  ];

  final List<bool> _completedTasks = [false, false, false];
  bool _largeSpacing = false;
  bool _centerHeading = false;

  int get _completedCount => _completedTasks.where((done) => done).length;
  double get _gap => _largeSpacing ? 24 : 12;

  void _setTaskCompleted(int index, bool? value) {
    setState(() {
      _completedTasks[index] = value ?? false;
    });
  }

  void _resetTasks() {
    setState(() {
      for (int i = 0; i < _completedTasks.length; i++) {
        _completedTasks[i] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Layout Lab'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Container + Padding + Row + Column + SizedBox.
                  Container(
                    padding: EdgeInsets.all(_largeSpacing ? 28 : 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: _centerHeading
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'BẢNG HỌC TẬP',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Demo các widget bố cục trong Flutter',
                                textAlign: _centerHeading
                                    ? TextAlign.center
                                    : TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFE0E7FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: _gap),

                  // Hai thẻ cùng sử dụng một widget tự định nghĩa.
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          label: 'Đã hoàn thành',
                          value: '$_completedCount/${_tasks.length}',
                          icon: Icons.task_alt_rounded,
                          color: const Color(0xFF059669),
                        ),
                      ),
                      SizedBox(width: _gap),
                      Expanded(
                        child: SummaryCard(
                          label: 'Tổng nhiệm vụ',
                          value: '${_tasks.length}',
                          icon: Icons.menu_book_rounded,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _gap),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Nhiệm vụ hôm nay',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _resetTasks,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Đặt lại'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        for (int index = 0; index < _tasks.length; index++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _tasks.length - 1 ? 0 : _gap,
                            ),
                            child: TaskCard(
                              title: _tasks[index],
                              completed: _completedTasks[index],
                              onChanged: (value) =>
                                  _setTaskCompleted(index, value),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: _gap),

                  // Các Switch tạo sự khác biệt trực quan khi thuyết trình.
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Điều chỉnh bố cục trực tiếp',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Tăng khoảng cách'),
                          subtitle: const Text(
                            'Thay đổi Padding và SizedBox: 12 → 24',
                          ),
                          value: _largeSpacing,
                          onChanged: (value) {
                            setState(() => _largeSpacing = value);
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Căn giữa tiêu đề'),
                          subtitle: const Text(
                            'Đổi CrossAxisAlignment trong Column',
                          ),
                          value: _centerHeading,
                          onChanged: (value) {
                            setState(() => _centerHeading = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hãy thử đánh dấu nhiệm vụ, tăng khoảng cách và đổi căn chỉnh '
                    'để quan sát giao diện được xây dựng lại.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// StatelessWidget tái sử dụng: dùng cho nhiều thẻ thống kê.
class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// StatelessWidget tái sử dụng: hiển thị dữ liệu do widget cha truyền xuống.
class TaskCard extends StatelessWidget {
  final String title;
  final bool completed;
  final ValueChanged<bool?> onChanged;

  const TaskCard({
    super.key,
    required this.title,
    required this.completed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Checkbox(value: completed, onChanged: onChanged),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                decoration: completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: completed
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF0F172A),
              ),
            ),
          ),
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            color: completed
                ? const Color(0xFF059669)
                : const Color(0xFFCBD5E1),
            size: 18,
          ),
        ],
      ),
    );
  }
}
