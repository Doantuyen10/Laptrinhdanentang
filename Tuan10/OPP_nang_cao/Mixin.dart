mixin Logger {
  void log(String message) {
    print("[LOG] $message");
  }
}
class Student with Logger {
  void study() {
    log("Sinh viên đang học bài");
  }
}
class Teacher with Logger {
  void teach() {
    log("Giảng viên đang giảng bài");
  }
}
void main() {
  Student s = Student();
  Teacher t = Teacher();
  s.study();
  t.teach();
}
