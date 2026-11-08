import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Chủ đề 5',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách, lưới và cuộn'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'SingleChild'),
              Tab(text: 'ListView.builder'),
              Tab(text: 'GridView'),
              Tab(text: 'Cuộn lồng nhau'),
              Tab(text: 'Danh sách rỗng'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SingleChildDemo(),
            LazyListDemo(),
            GridDemo(),
            NestedScrollDemo(),
            EmptyStateDemo(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// 1. SingleChildScrollView: phù hợp nội dung ngắn, ít phần tử.
//    Toàn bộ widget con được build cùng lúc (không lazy).
// ---------------------------------------------------------------
class SingleChildDemo extends StatelessWidget {
  const SingleChildDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thông tin sinh viên',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          for (int i = 1; i <= 12; i++)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('$i')),
                title: Text('Mục thông tin số $i'),
                subtitle: const Text('Dùng Column + SingleChildScrollView'),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Lưu ý: với danh sách dài, KHÔNG nên dùng cách này vì tất cả '
            'phần tử đều được dựng ngay → tốn bộ nhớ, giật lag.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// 2. ListView.builder + lazy loading + tải thêm khi cuộn tới cuối.
//    Các phần tử có kích thước khác nhau (độ dài văn bản khác nhau).
// ---------------------------------------------------------------
class LazyListDemo extends StatefulWidget {
  const LazyListDemo({super.key});

  @override
  State<LazyListDemo> createState() => _LazyListDemoState();
}

class _LazyListDemoState extends State<LazyListDemo> {
  final ScrollController _controller = ScrollController();
  final List<int> _items = List.generate(20, (i) => i);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    // Còn cách đáy 200px thì tải thêm
    if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 200 &&
        !_isLoading) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // giả lập gọi API
    if (!mounted) return;
    setState(() {
      final start = _items.length;
      _items.addAll(List.generate(20, (i) => start + i));
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      // +1 để hiển thị vòng tròn loading ở cuối danh sách
      itemCount: _items.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final n = _items[index];
        // Độ dài nội dung khác nhau → chiều cao phần tử khác nhau
        final repeat = (n % 4) + 1;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(child: Text('${n + 1}')),
            title: Text('Phần tử #${n + 1}'),
            subtitle: Text('Nội dung mô tả. ' * repeat),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------
// 3. GridView.builder: hiển thị dữ liệu dạng lưới
// ---------------------------------------------------------------
class GridDemo extends StatelessWidget {
  const GridDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Colors.primaries;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 60,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 cột
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1, // tỉ lệ rộng/cao
      ),
      itemBuilder: (context, index) {
        final color = colors[index % colors.length];
        return InkWell(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bạn chọn ô số ${index + 1}'),
              duration: const Duration(milliseconds: 800),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image, color: Colors.white, size: 32),
                const SizedBox(height: 4),
                Text('Ô ${index + 1}',
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------
// 4. Cuộn lồng nhau: ListView ngang nằm trong cuộn dọc,
//    và ListView dọc nằm trong SingleChildScrollView.
// ---------------------------------------------------------------
class NestedScrollDemo extends StatelessWidget {
  const NestedScrollDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Danh sách cuộn ngang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          // Cuộn ngang: bắt buộc phải bọc trong SizedBox có chiều cao cố định
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 15,
              itemBuilder: (context, i) => Container(
                width: 110,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text('Thẻ ${i + 1}')),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Danh sách cuộn dọc lồng bên trong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          // ListView lồng trong cuộn dọc:
          //  - shrinkWrap: true  → ListView co theo nội dung
          //  - NeverScrollableScrollPhysics → để cha xử lý cuộn
          // (Cẩn thận hiệu năng: shrinkWrap sẽ build toàn bộ phần tử.
          //  Với dữ liệu lớn nên dùng CustomScrollView + Slivers.)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 15,
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.list),
              title: Text('Dòng lồng nhau ${i + 1}'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// 5. Xử lý trạng thái danh sách rỗng (tìm kiếm không có kết quả)
// ---------------------------------------------------------------
class EmptyStateDemo extends StatefulWidget {
  const EmptyStateDemo({super.key});

  @override
  State<EmptyStateDemo> createState() => _EmptyStateDemoState();
}

class _EmptyStateDemoState extends State<EmptyStateDemo> {
  final List<String> _all = [
    'Flutter', 'Dart', 'Widget', 'ListView', 'GridView',
    'Scroll', 'State', 'Provider', 'Material', 'Navigator',
  ];
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _all
        .where((e) => e.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm kiếm... (thử gõ "xyz")',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Không tìm thấy kết quả',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) => ListTile(
                    title: Text(filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }
}