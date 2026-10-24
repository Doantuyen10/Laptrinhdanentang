# Laptrinhdanentang
Tuần 10 có Chủ đề 01: Nền tảng OOP nâng cao & Xử lý lỗi trong Dart
Nội dung:
Lập trình hướng đối tượng trong Dart: Named & Factory constructor (khởi tạo đối tượng linh hoạt), Mixins (tái sử dụng tính năng không qua kế thừa) và Generics cơ bản.
Kỹ thuật xử lý lỗi: Cấu trúc try-catch-finally, định nghĩa lỗi tùy biến (Custom Exception) và trả về thông báo lỗi thân thiện cho người dùng.
Yêu cầu demo:
Xây dựng một module quản lý dữ liệu đơn giản áp dụng Factory constructor (ví dụ: chuyển đổi dữ liệu từ Map/JSON) và Mixin (ví dụ: tự động in log hoặc kiểm tra tính hợp lệ).
Viết một hàm bao bọc (wrapper) để bắt và gom lỗi tập trung, hiển thị thông báo lỗi rõ ràng lên giao diện thay vì làm ứng dụng bị dừng đột ngột (crash).
*Note: 
- Phải 2 người cùng lên thuyết trình
- Chú ý nội dung trình bày slide để giải thích (Giống như giới thiệu kiến thức mới cho các bạn)
- Ứng dụng demo có liên quan đến nội dung đã trình bày và đơn giản

=====================================================================================================================================================================================

Tuần 11 có Chủ đề 03: Xử lý tác vụ nặng với Isolate (Hàm compute) để giữ mượt giao diện
Nội dung:
Khái niệm nghẽn luồng giao diện (UI Jank/Freeze) khi xử lý dữ liệu nặng trên Main Thread.
Giải pháp xử lý đa luồng đơn giản trong Flutter: Sử dụng hàm compute để đẩy tác vụ nặng chạy ngầm mà không làm đơ giao diện.
Yêu cầu demo:
Xây dựng giao diện có một hiệu ứng chuyển động liên tục (như con quay CircularProgressIndicator hoặc animation chuyển động mượt mà).
Tạo 2 nút bấm thực hiện cùng một tác vụ tính toán nặng (như tính toán thuật toán vòng lặp lớn hoặc đọc parse danh sách JSON dài):
Nút 1: Chạy trực tiếp trên Main Thread (làm animation bị khựng/đơ tạm thời).
Nút 2: Chạy qua hàm compute (animation vẫn quay mượt mà, không bị giật lag).
