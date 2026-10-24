Trong các thư mục sẽ có các nội dung:
- Isolate : Compute.dart
            Long_lived.dart
* Các ví dụ về isolate
- Mainthread : Mainthread.dart
* Các ví dụ về mainthread
- Demo : chứa mã nguồn demo và các cấu hình flutter đi kèm để build app trên các nền tảng
* Demo thể hiện sự khác nhau khi khởi chạy Isolate và Mainthread
*Note
- Slide trình bày cần làm rõ:
  + Cơ chế hoạt động của Event Loop và Isolate trong Dart.
  + Phân biệt `async/await` (không tạo thread mới) và `compute/Isolate` (tạo thread riêng).
  + Điều kiện sử dụng `compute()`: Hàm xử lý phải là Top-level hoặc `static`.
- Ứng dụng demo bám sát lý thuyết và dễ theo dõi.