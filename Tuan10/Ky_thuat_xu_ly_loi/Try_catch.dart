void main() {
  try {
    int a = int.parse("abc");
    print(a);
  } catch (e) {
    print("Lỗi: Không thể chuyển chuỗi thành số!");
  }
}
