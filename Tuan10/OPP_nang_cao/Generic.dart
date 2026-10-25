class Box<T> {
  T value;
  Box(this.value);
  void show() {
    print(value);
  }
}

void main() {
  Box<int> a = Box<int>(10);
  Box<String> b = Box<String>("Hello Dart");
  a.show();
  b.show();
}
