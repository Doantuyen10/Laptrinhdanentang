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
      title: 'Demo Danh Sách & Lưới',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ProductListScreen(),
    );
  }
}

// Model dữ liệu mẫu (immutable)
@immutable
class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final Color color;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.color,
  });
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Dữ liệu tĩnh: chỉ tạo 1 lần, không tạo lại mỗi lần gọi hàm
  static final List<Color> _colors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.pink.shade100,
  ];

  static const List<String> _descriptions = [
    'Mô tả ngắn gọn.',
    'Sản phẩm này có mô tả dài hơn một chút để kiểm tra hiển thị.',
    'Mô tả rất chi tiết về sản phẩm: Chất liệu cao cấp, kiểu dáng hiện đại, độ bền vượt trội và phù hợp với nhiều mục đích sử dụng khác nhau.',
  ];

  static const int _initialCount = 10;
  static const int _loadMoreCount = 6;
  static const double _loadMoreThreshold = 200;

  final List<Product> _products = [];
  final ScrollController _scrollController = ScrollController();

  bool _isGridView = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  // Lắng nghe cuộn để Lazy Loading
  void _onScroll() {
    if (_isLoadingMore || _products.isEmpty) return;
    if (_scrollController.position.extentAfter < _loadMoreThreshold) {
      _loadMoreData();
    }
  }

  // Giả lập tải dữ liệu ban đầu
  void _loadInitialData() {
    setState(() {
      _isLoadingMore = false;
      _products
        ..clear()
        ..addAll(_generateMockData(startIndex: 1, count: _initialCount));
    });
  }

  // Giả lập tải thêm dữ liệu khi cuộn
  Future<void> _loadMoreData() async {
    setState(() => _isLoadingMore = true);

    await Future.delayed(const Duration(seconds: 1)); // Giả lập độ trễ mạng

    // Tránh setState khi widget đã bị dispose
    if (!mounted) return;

    final newItems = _generateMockData(
      startIndex: _products.length + 1,
      count: _loadMoreCount,
    );

    setState(() {
      _products.addAll(newItems);
      _isLoadingMore = false;
    });
  }

  List<Product> _generateMockData({
    required int startIndex,
    required int count,
  }) {
    return List.generate(count, (index) {
      final id = startIndex + index;
      return Product(
        id: id,
        title: 'Sản phẩm #$id',
        description: _descriptions[id % _descriptions.length],
        price: (id * 15.5) % 100 + 10,
        color: _colors[id % _colors.length],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách & Lưới Dữ liệu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Xóa dữ liệu (Test Empty State)',
            onPressed: () => setState(_products.clear),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: _loadInitialData,
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? 'Xem dạng Danh sách' : 'Xem dạng Lưới',
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadInitialData(),
        child: _products.isEmpty
            ? _buildEmptyState()
            // CustomScrollView + Slivers: các item chỉ được build khi lọt vào
            // viewport (lazy thật sự), thay cho SingleChildScrollView + shrinkWrap
            : CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Phần 1: Banner cuộn ngang
                  SliverToBoxAdapter(child: _buildFeaturedSection()),

                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Tất cả sản phẩm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Phần 2: List hoặc Grid
                  _isGridView ? _buildGridView() : _buildListView(),

                  // Phần 3: Indicator khi đang Lazy Load
                  if (_isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  // 1. Empty State
  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Danh sách hiện tại đang rỗng!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadInitialData,
                icon: const Icon(Icons.refresh),
                label: const Text('Tải lại dữ liệu'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Section cuộn ngang
  Widget _buildFeaturedSection() {
    return Container(
      height: 120,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemExtent: 216, // 200 (width) + 16 (margin): bỏ bước đo kích thước
        itemBuilder: (context, index) => _FeaturedBanner(index: index),
      ),
    );
  }

  // 3. Dạng danh sách (Sliver, không cần shrinkWrap)
  Widget _buildListView() {
    return SliverList.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _ProductListTile(key: ValueKey(product.id), product: product);
      },
    );
  }

  // 4. Dạng lưới (Sliver, không cần shrinkWrap)
  Widget _buildGridView() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _ProductGridTile(key: ValueKey(product.id), product: product);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Các widget con tách riêng: Flutter bỏ qua rebuild nếu widget không đổi
// ---------------------------------------------------------------------------

class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Banner Nổi bật ${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: product.color,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  product.price.toStringAsFixed(2),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Chiều cao tự thay đổi theo độ dài mô tả
            Text(product.description),
          ],
        ),
      ),
    );
  }
}

class _ProductGridTile extends StatelessWidget {
  const _ProductGridTile({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: product.color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Icon(Icons.shopping_bag, size: 40)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              product.price.toStringAsFixed(2),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
