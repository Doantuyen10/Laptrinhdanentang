class User {
  String name;
  User(this.name);
  factory User.fromInput(String name) {
    if (name.trim().isEmpty) {
      return User("Người dùng mặc định");
    }
    return User(name);
  }
  void showInfo() {
    print("Xin chào $name");
  }
}
void main() {
  User u1 = User.fromInput("Nam");
  User u2 = User.fromInput("");
  u1.showInfo();
  u2.showInfo();
}
