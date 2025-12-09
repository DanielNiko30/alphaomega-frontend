import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(String userId) {
    socket = IO.io('https://tokalphaomegaploso.my.id', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected: ${socket.id}');
      socket.emit('joinRoom', userId);
    });

    socket.on('newTransaction', (data) {
      print('New Transaction: $data');
    });

    socket.on('updateTransaction', (data) {
      print('Update Transaction: $data');
    });

    socket.on('updateStatusTransaction', (data) {
      print('Update Status: $data');
    });

    socket.onDisconnect((_) => print('Disconnected'));
  }

  void disconnect() {
    socket.disconnect();
  }
}
