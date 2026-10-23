class Student {
  String name;
  int age;
  Student(this.name, this.age); // Constructor thông thường
  Student.guest() // Named Constructor
    : name = "Khách",
      age = 0;
  Student.fromAge(this.name, this.age); // Named Constructor khác
  void showInfo() {
    print("Tên: $name - Tuổi: $age");
  }
}

void main() {
  Student s1 = Student("An", 20);
  Student s2 = Student.guest();
  Student s3 = Student.fromAge("Bình", 21);
  s1.showInfo();
  s2.showInfo();
  s3.showInfo();
}
