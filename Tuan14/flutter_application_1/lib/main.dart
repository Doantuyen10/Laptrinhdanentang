// Demo Chủ đề 9: Điều hướng và quản lý luồng màn hình (Flutter >= 3.22)
//
// Luồng: Splash -> Đăng nhập -> Trang chủ -> Chi tiết / Giỏ hàng -> Thành công
// Kỹ thuật minh họa:
//  1. Navigator.push + MaterialPageRoute, truyền dữ liệu qua constructor
//  2. Trả kết quả về màn hình trước bằng Navigator.pop(context, result)
//  3. Named routes + onGenerateRoute, truyền dữ liệu qua arguments
//  4. pushReplacementNamed, pushNamedAndRemoveUntil, popUntil
//  5. PopScope: chặn / xác nhận khi người dùng bấm Back
//  6. NavigatorObserver: theo dõi ngăn xếp Route theo thời gian thực
//  7. Hero + hiệu ứng chuyển trang tùy chỉnh (PageRouteBuilder)

import 'package:flutter/material.dart';

void main() => runApp(const NavDemoApp());

// ---------------------------------------------------------------------------
// Tên route tập trung
// ---------------------------------------------------------------------------
class Routes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const detail = '/detail';
  static const checkout = '/checkout';
  static const success = '/success';
  static const log = '/log';
}

// ---------------------------------------------------------------------------
// Dữ liệu và trạng thái dùng chung
// ---------------------------------------------------------------------------
class Product {
  final int id;
  final String name;
  final int price;
  final String desc;
  final String emoji;
  final Color color;
  const Product(this.id, this.name, this.price, this.desc, this.emoji, this.color);
}

const kProducts = <Product>[
  Product(1, 'Cà phê muối', 29000, 'Cà phê pha cùng lớp kem muối béo nhẹ, vị đậm và hậu ngọt.', '☕', Color(0xFFF3D9C4)),
  Product(2, 'Trà đào cam sả', 35000, 'Trà đào thanh mát, thơm sả, thêm vài miếng đào giòn.', '🍑', Color(0xFFFFD9CC)),
  Product(3, 'Bánh mì que', 15000, 'Bánh mì giòn rụm, nhân pate cay, ăn nóng là hợp nhất.', '🥖', Color(0xFFF7E7B4)),
  Product(4, 'Sinh tố bơ', 39000, 'Sinh tố bơ sánh mịn, ít đường, thêm chút sữa đặc.', '🥑', Color(0xFFD9EBC3)),
];

String vnd(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${b}đ';
}

/// Kết quả Chi tiết trả về cho Trang chủ khi pop.
class DetailResult {
  final int rating;
  final bool inCart;
  const DetailResult(this.rating, this.inCart);
}

class AppState extends ChangeNotifier {
  AppState._();
  static final instance = AppState._();

  final Map<int, int> ratings = {};
  final Set<int> cart = {};

  List<Product> get cartItems =>
      kProducts.where((p) => cart.contains(p.id)).toList();

  void apply(int id, DetailResult r) {
    if (r.rating > 0) ratings[id] = r.rating;
    r.inCart ? cart.add(id) : cart.remove(id);
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// NavigatorObserver: ghi lại sự kiện và ngăn xếp Route
// ---------------------------------------------------------------------------
class NavLogger extends NavigatorObserver {
  static final events = ValueNotifier<List<String>>([]);
  static final stack = ValueNotifier<List<String>>([]);

  static String _n(Route<dynamic>? r) => r?.settings.name ?? 'hộp thoại';

  static void _log(String e) => events.value = [e, ...events.value];

  static void _removeLast(String n) {
    final s = [...stack.value];
    final i = s.lastIndexOf(n);
    if (i >= 0) s.removeAt(i);
    stack.value = s;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    stack.value = [...stack.value, _n(route)];
    _log('push  → ${_n(route)}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _removeLast(_n(route));
    _log('pop   ← ${_n(route)}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _removeLast(_n(route));
    _log('remove ✕ ${_n(route)}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final s = [...stack.value];
    final i = s.lastIndexOf(_n(oldRoute));
    if (i >= 0) s[i] = _n(newRoute);
    stack.value = s;
    _log('replace ${_n(oldRoute)} → ${_n(newRoute)}');
  }
}

// ---------------------------------------------------------------------------
// Ứng dụng, giao diện và bảng route (onGenerateRoute)
// ---------------------------------------------------------------------------
const kCream = Color(0xFFFBF6F0);
const kDark = Color(0xFF3E2A1C);

class NavDemoApp extends StatelessWidget {
  const NavDemoApp({super.key});

  Route<dynamic> _route(RouteSettings s, Widget w) =>
      MaterialPageRoute(settings: s, builder: (_) => w);

  /// Hiệu ứng chuyển trang tùy chỉnh: trượt từ dưới lên.
  Route<dynamic> _slideUp(RouteSettings s, Widget w) => PageRouteBuilder(
        settings: s,
        pageBuilder: (_, __, ___) => w,
        transitionDuration: const Duration(milliseconds: 380),
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF6F4E37));
    return MaterialApp(
      title: 'Nav Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: kCream,
        appBarTheme: const AppBarTheme(
          backgroundColor: kCream,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: kDark),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
      initialRoute: Routes.splash,
      navigatorObservers: [NavLogger()],
      onGenerateRoute: (s) {
        switch (s.name) {
          case Routes.splash:
            return _route(s, const SplashScreen());
          case Routes.login:
            return _route(s, const LoginScreen());
          case Routes.home:
            return _route(s, const HomeScreen());
          case Routes.checkout:
            return _route(s, const CheckoutScreen());
          case Routes.success:
            return _slideUp(s, const SuccessScreen());
          case Routes.log:
            return _slideUp(s, const LogScreen());
          default:
            return _route(s, const NotFoundScreen());
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Thành phần giao diện dùng chung
// ---------------------------------------------------------------------------
class TechNote extends StatelessWidget {
  final String text;
  const TechNote(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.alt_route, size: 20, color: scheme.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KỸ THUẬT',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer)),
                const SizedBox(height: 4),
                Text(text, style: TextStyle(color: scheme.onPrimaryContainer)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const WhiteCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: child,
      );
}

/// Ô emoji của sản phẩm, dùng Hero để chuyển mượt giữa Trang chủ và Chi tiết.
class ProductTile extends StatelessWidget {
  final Product product;
  final double emojiSize;
  const ProductTile(this.product, {super.key, this.emojiSize = 56});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'product-${product.id}',
      child: Material(
        color: product.color,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(product.emoji, style: TextStyle(fontSize: emojiSize)),
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration gradientBg() => const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8B5E3C), kDark],
      ),
    );

// ---------------------------------------------------------------------------
// 1. Splash -> pushReplacementNamed
// ---------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: gradientBg(),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutBack,
                    builder: (_, v, child) => Opacity(
                      opacity: v.clamp(0, 1),
                      child: Transform.scale(scale: 0.6 + 0.4 * v, child: child),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('☕', style: TextStyle(fontSize: 84)),
                        SizedBox(height: 12),
                        Text('Nav Cafe',
                            style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        SizedBox(height: 6),
                        Text('Demo điều hướng Flutter',
                            style: TextStyle(color: Color(0xCCFFFFFF))),
                      ],
                    ),
                  ),
                ),
              ),
              const TechNote(
                  'pushReplacementNamed: Splash bị thay bằng Đăng nhập, bấm Back sẽ không quay lại Splash.'),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Đăng nhập -> pushNamedAndRemoveUntil, truyền tên qua arguments
// ---------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _login() {
    final name = _name.text.trim().isEmpty ? 'Khách' : _name.text.trim();
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.home,
      (route) => false, // xóa toàn bộ ngăn xếp cũ
      arguments: name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: gradientBg(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('☕', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 8),
                  const Text('Chào mừng đến Nav Cafe',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 24),
                  WhiteCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _name,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                          decoration: const InputDecoration(
                            labelText: 'Tên của bạn',
                            prefixIcon: Icon(Icons.person_outline),
                            fillColor: Color(0xFFF5EFE8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                            onPressed: _login, child: const Text('Vào cửa hàng')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const TechNote(
                      'pushNamedAndRemoveUntil: xóa hết màn hình cũ, tên người dùng đi theo arguments. Vào Trang chủ rồi bấm Back sẽ không quay về Đăng nhập.'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Trang chủ -> push (constructor), nhận kết quả pop, pushNamed (arguments)
// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openDetail(BuildContext context, Product p) async {
    // Truyền dữ liệu qua constructor, nhận kết quả khi màn hình đích pop.
    final result = await Navigator.push<DetailResult>(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: Routes.detail),
        builder: (_) => DetailScreen(product: p),
      ),
    );
    if (result != null) AppState.instance.apply(p.id, result);
  }

  void _openCheckout(BuildContext context) {
    // Named route, truyền dữ liệu qua arguments.
    Navigator.pushNamed(context, Routes.checkout,
        arguments: AppState.instance.cartItems);
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)?.settings.arguments as String? ?? 'Khách';
    final top = MediaQuery.of(context).padding.top;

    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final items = s.cartItems;
        final total = items.fold<int>(0, (sum, p) => sum + p.price);
        return Scaffold(
          bottomNavigationBar: items.isEmpty
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: FilledButton.icon(
                      onPressed: () => _openCheckout(context),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: Text('Xem giỏ hàng · ${items.length} món · ${vnd(total)}'),
                    ),
                  ),
                ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, top + 16, 12, 28),
                  decoration: gradientBg().copyWith(
                    borderRadius:
                        const BorderRadius.vertical(bottom: Radius.circular(28)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Text(user.characters.first.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: kDark)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Xin chào,',
                                style: TextStyle(color: Color(0xCCFFFFFF))),
                            Text(user,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Nhật ký điều hướng',
                        color: Colors.white,
                        icon: const Icon(Icons.layers_outlined),
                        onPressed: () => Navigator.pushNamed(context, Routes.log),
                      ),
                      IconButton(
                        tooltip: 'Đăng xuất',
                        color: Colors.white,
                        icon: const Icon(Icons.logout),
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context, Routes.login, (route) => false),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TechNote(
                      'Chạm vào món: push + constructor, nhận đánh giá và trạng thái giỏ qua pop(result). Nút giỏ hàng: pushNamed + arguments.'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final p = kProducts[i];
                      final rating = s.ratings[p.id];
                      final inCart = s.cart.contains(p.id);
                      return GestureDetector(
                        onTap: () => _openDetail(context, p),
                        child: WhiteCard(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SizedBox.expand(child: ProductTile(p)),
                              ),
                              const SizedBox(height: 10),
                              Text(p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 15)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(vnd(p.price),
                                        style: const TextStyle(
                                            color: Color(0xFF8B5E3C),
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  if (rating != null) ...[
                                    const Icon(Icons.star,
                                        size: 16, color: Colors.amber),
                                    Text('$rating'),
                                  ],
                                  if (inCart)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 6),
                                      child: Icon(Icons.check_circle,
                                          size: 18, color: Color(0xFF3F8F5B)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: kProducts.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Chi tiết -> nhận qua constructor, trả kết quả qua pop, PopScope
// ---------------------------------------------------------------------------
class DetailScreen extends StatefulWidget {
  final Product product;
  const DetailScreen({super.key, required this.product});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int _rating = AppState.instance.ratings[widget.product.id] ?? 0;
  late bool _inCart = AppState.instance.cart.contains(widget.product.id);

  void _close() => Navigator.pop(context, DetailResult(_rating, _inCart));

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return PopScope(
      canPop: false, // tự xử lý để Back hệ thống cũng trả kết quả
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết món'),
          leading: BackButton(onPressed: _close),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            SizedBox(height: 220, child: ProductTile(p, emojiSize: 96)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(p.name,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800, color: kDark)),
                ),
                Text(vnd(p.price),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B5E3C))),
              ],
            ),
            const SizedBox(height: 8),
            Text(p.desc, style: const TextStyle(height: 1.5, color: Colors.black87)),
            const SizedBox(height: 20),
            WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Đánh giá của bạn',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Row(
                    children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          iconSize: 32,
                          color: Colors.amber,
                          icon: Icon(i <= _rating ? Icons.star : Icons.star_border),
                          onPressed: () => setState(() => _rating = i),
                        ),
                    ],
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Thêm vào giỏ hàng'),
                    value: _inCart,
                    onChanged: (v) => setState(() => _inCart = v),
                  ),
                ],
              ),
            ),
            const TechNote(
                'Dữ liệu vào bằng constructor, kết quả ra bằng pop(context, DetailResult). PopScope giúp nút Back hệ thống cũng trả kết quả. Hero làm ô emoji bay mượt từ Trang chủ.'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Giỏ hàng -> nhận arguments, PopScope xác nhận thoát
// ---------------------------------------------------------------------------
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addr = TextEditingController();
  bool _dirty = false;

  @override
  void dispose() {
    _addr.dispose();
    super.dispose();
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Thoát khỏi đơn hàng?'),
        content: const Text('Địa chỉ đã nhập sẽ bị mất.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Ở lại')),
          FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Thoát')),
        ],
      ),
    );
    if (leave == true && context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final items = ModalRoute.of(context)!.settings.arguments as List<Product>;
    final total = items.fold<int>(0, (sum, p) => sum + p.price);
    return PopScope(
      canPop: !_dirty, // đã nhập dữ liệu thì chặn Back và hỏi lại
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave(context);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Xác nhận đơn hàng')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            WhiteCard(
              child: Column(
                children: [
                  for (final p in items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: p.color,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(p.emoji, style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(p.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600))),
                          Text(vnd(p.price)),
                        ],
                      ),
                    ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Expanded(
                          child: Text('Tổng cộng',
                              style: TextStyle(fontWeight: FontWeight.w700))),
                      Text(vnd(total),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF8B5E3C))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addr,
              onChanged: (v) => setState(() => _dirty = v.trim().isNotEmpty),
              decoration: const InputDecoration(
                labelText: 'Địa chỉ giao hàng',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _dirty
                  ? () {
                      setState(() => _dirty = false);
                      AppState.instance.clearCart();
                      Navigator.pushNamed(context, Routes.success, arguments: total);
                    }
                  : null,
              child: const Text('Đặt hàng'),
            ),
            const TechNote(
                'Danh sách món nhận qua arguments. Nhập địa chỉ rồi bấm Back: PopScope chặn và hiện hộp thoại xác nhận.'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Thành công -> popUntil về Trang chủ
// ---------------------------------------------------------------------------
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  void _goHome(BuildContext context) =>
      Navigator.popUntil(context, ModalRoute.withName(Routes.home));

  @override
  Widget build(BuildContext context) {
    final total = ModalRoute.of(context)!.settings.arguments as int;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.elasticOut,
                          builder: (_, v, child) =>
                              Transform.scale(scale: v, child: child),
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: const BoxDecoration(
                                color: Color(0xFF3F8F5B), shape: BoxShape.circle),
                            child: const Icon(Icons.check, size: 64, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Đặt hàng thành công',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800, color: kDark)),
                        const SizedBox(height: 8),
                        Text('Đã thanh toán ${vnd(total)}'),
                      ],
                    ),
                  ),
                ),
                FilledButton(
                    onPressed: () => _goHome(context),
                    child: const Text('Về trang chủ')),
                const TechNote(
                    'popUntil(withName(home)): gỡ cùng lúc Thành công và Giỏ hàng. Back cũng về Trang chủ nhờ PopScope. Trang này dùng hiệu ứng trượt lên từ PageRouteBuilder.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Nhật ký điều hướng: hiển thị ngăn xếp Route và sự kiện
// ---------------------------------------------------------------------------
class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  IconData _iconFor(String e) {
    if (e.startsWith('push')) return Icons.south_east;
    if (e.startsWith('pop')) return Icons.north_west;
    if (e.startsWith('replace')) return Icons.swap_horiz;
    return Icons.close;
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text(t,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: kDark)),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Nhật ký điều hướng')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _title('Ngăn xếp hiện tại'),
          ValueListenableBuilder<List<String>>(
            valueListenable: NavLogger.stack,
            builder: (context, stack, _) {
              final rev = stack.reversed.toList();
              return Column(
                children: [
                  for (var i = 0; i < rev.length; i++)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: i == 0 ? scheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE6DACD)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(rev[i],
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: i == 0 ? Colors.white : kDark)),
                          ),
                          if (i == 0)
                            const Text('đang hiển thị',
                                style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          _title('Sự kiện (mới nhất ở đầu)'),
          ValueListenableBuilder<List<String>>(
            valueListenable: NavLogger.events,
            builder: (context, events, _) => WhiteCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  for (final e in events)
                    ListTile(
                      dense: true,
                      leading: Icon(_iconFor(e), color: scheme.primary),
                      title: Text(e,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Route không tồn tại
// ---------------------------------------------------------------------------
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Không tìm thấy')),
        body: const Center(child: Text('Route không tồn tại.')),
      );
}