import 'dart:convert';

// Các hàm nặng đều đặt NGOÀI class (top-level)
// để compute() có thể chạy an toàn trong isolate khác.

/// Tác vụ nặng 1: vòng lặp lớn (thuần CPU).
/// Cùng một hàm được dùng cho cả hai cách chạy (Main Thread và compute).
int heavyCalculation(int iterations) {
  int checksum = 0;
  for (int i = 0; i < iterations; i++) {
    checksum = (checksum + (i * 31) % 97) % 1000000007;
  }
  return checksum;
}

/// Tác vụ nặng 2: sinh danh sách JSON dài, encode rồi parse lại.
/// Chỉ nhận và trả về số nguyên (itemCount -> checksum), danh sách lớn
/// được tạo và parse ngay trong isolate nên không phải gửi qua message.
int jsonTask(int itemCount) {
  final items = List.generate(
    itemCount,
    (i) => {'id': i, 'name': 'item_$i', 'value': (i * 31) % 97},
  );

  final text = jsonEncode(items);
  final decoded = jsonDecode(text) as List<dynamic>;

  int checksum = 0;
  for (final item in decoded) {
    final value = (item as Map<String, dynamic>)['value'] as int;
    checksum = (checksum + value) % 1000000007;
  }
  return checksum;
}