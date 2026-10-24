import 'dart:isolate';
class SimpleWorker {
  late Isolate _isolate;
  late SendPort _workerSendPort;
  final ReceivePort _mainReceivePort = ReceivePort();
  Future<void> init() async {
    // 1. Khởi tạo Isolate và truyền SendPort của Main Thread vào
    _isolate = await Isolate.spawn(_entryPoint, _mainReceivePort.sendPort);
    // 2. Lắng nghe phản hồi từ background
    _mainReceivePort.listen((message) {
      if (message is SendPort) {
        _workerSendPort = message; // Lưu lại cổng của worker để gửi việc sau
        print('Đã kết nối với Long-lived Isolate!');
      } else {
        print('Kết quả từ Isolate: $message');
      }
    });
  }
  // Gửi tác vụ sang Isolate bất cứ lúc nào
  void sendTask(String task) {
    _workerSendPort.send(task);
  }
  // Hủy Isolate khi không dùng nữa
  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    _mainReceivePort.close();
  }
}
// Hàm chạy độc lập ở background
void _entryPoint(SendPort mainSendPort) {
  final workerReceivePort = ReceivePort();
  // Gửi SendPort của worker ngược về cho Main Thread
  mainSendPort.send(workerReceivePort.sendPort);
  // Lắng nghe và xử lý liên tục các task gửi đến
  workerReceivePort.listen((message) {
    // Giả lập xử lý dữ liệu nặng
    String result = 'Xử lý xong: "$message"';
    mainSendPort.send(result);
  });
}
void main() async {
  final worker = SimpleWorker();
  await worker.init();
  // Gửi các task độc lập vào các thời điểm khác nhau mà không tạo Isolate mới
  worker.sendTask('Task số 1');
  worker.sendTask('Task số 2');
}