void main() {
  try {
    int a = 10 ~/ 0;
    print(a);
  } catch (e) {
    print("Lỗi chia cho 0!");
  } finally {
    print("Kết thúc chương trình!");
  }
}
