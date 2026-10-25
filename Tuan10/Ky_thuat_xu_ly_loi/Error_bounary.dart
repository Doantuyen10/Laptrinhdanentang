import 'dart:async';

void main() {
  runZonedGuarded(
    () {
      print("Chương trình bắt đầu");

      // Tác vụ 1: Gây lỗi
      Future.delayed(Duration(seconds: 1), () {
        throw Exception("Lỗi xử lý dữ liệu!");
      });

      // Tác vụ 2: Vẫn hoạt động
      Future.delayed(Duration(seconds: 2), () {
        print("Chương trình vẫn tiếp tục chạy!");
      });
    },
    (error, stackTrace) {
      print("Đã bắt lỗi: $error");
    },
  );
}
