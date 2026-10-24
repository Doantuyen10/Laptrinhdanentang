import 'dart:isolate';

// 1. Định nghĩa một hàm tính toán nặng (bắt buộc phải là top-level function hoặc static method)
int heavyTask(int maxNumber) {
  int sum = 0;
  for (int i = 0; i < maxNumber; i++) {
    sum += i;
  }
  return sum;
}

// 2. Chạy tính toán trên một isolate riêng
Future<void> performComputation() async {
  print('Bắt đầu tính toán trên background isolate...');
  // Isolate.run() tạo một isolate tạm thời, thực thi callback và tự hủy sau khi hoàn tất.
  final int result = await Isolate.run(() => heavyTask(2000000000));
  print('Kết quả: $result');
}
