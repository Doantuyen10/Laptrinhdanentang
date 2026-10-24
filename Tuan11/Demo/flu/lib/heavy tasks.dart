// Cùng một hàm xử lý CPU được dùng cho cả hai cách chạy.
// Đặt ngoài class để compute() có thể gọi an toàn trong isolate.
int heavyCalculation(int iterations) {
  int checksum = 0;
  for (int i = 0; i < iterations; i++) {
    checksum = (checksum + (i * 31) % 97) % 1000000007;
  }
  return checksum;
}
 