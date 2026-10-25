// Tạo Custom Exception
class AgeException implements Exception {
  String message;
  AgeException(this.message);
  @override
  String toString() => message;
}

void main() {
  try {
    int age = 15;
    if (age < 18) {
      throw AgeException("Tuổi phải từ 18 trở lên!");
    }
    print("Tuổi hợp lệ!");
  } on AgeException catch (e) {
    print("Lỗi: $e");
  }
}
