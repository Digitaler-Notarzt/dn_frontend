import 'package:web_socket_channel/web_socket_channel.dart';

class StreamReceiver {
  final WebSocketChannel channel;

  StreamReceiver(this.channel);

  void listen() async {
    print('Starting listening...');
    
    try {
      await channel.ready.timeout(const Duration(seconds: 5)); // Warten auf erfolgreiche Verbindung
      setupStream();
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  void setupStream() {
    channel.stream.listen((data) {
      print('Received data: $data');
    }, onError: (error) {
      print('Error: $error');
    }, onDone: () {
      print('Socket closed');
    });
  }

}
