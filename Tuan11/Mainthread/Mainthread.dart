void main() async {
  print('🎬 [Main Thread] Bắt đầu chương trình...');
  print('⚡ [Main Thread] Lên lịch một việc nhẹ (in ra sau)...');
  // Dùng Future để đẩy xuống Event Loop xử lý sau
  Future.delayed(const Duration(milliseconds: 100), () {
    print('🔔 [Event Loop] Việc nhẹ đã được thực thi!');
  });
  print('⚙️ [Main Thread] Bắt đầu vòng lặp tính toán nặng TRỰC TIẾP trên Main Thread...');
  // ⚠️ Vòng lặp nặng chiếm dụng hoàn toàn Main Thread tại đây
  int totalSum = 0;
  for (int i = 0; i < 3000000000; i++) {
    totalSum += i;
  }
  print('✅ [Main Thread] Tính toán xong! Kết quả: $totalSum');
  print('🚀 [Main Thread] Các công việc phía sau được thực hiện.');
}