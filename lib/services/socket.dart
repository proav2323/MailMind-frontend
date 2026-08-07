import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailmind/services/api.dart';
import 'package:mailmind/services/auth.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

final SOCKET = FutureProvider<SocketService>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user != null) {
    final socketService = SocketService();
    List<Cookie> tokenList = await getCookies(
      Uri.parse(BACKEND_URL + "/auth/"),
    );
    int tokenIndex = tokenList.indexWhere((cookie) => cookie.name == "token");
    if (tokenIndex == -1) {
      throw Exception('Token not found in cookies');
    }
    socketService.initSocket(tokenList[tokenIndex].value);
    return socketService;
  } else {
    throw Exception('User not authenticated');
  }
});

class SocketService {
  late IO.Socket socket;

  void initSocket(String token) {
    // Replace with your server URL
    socket = IO.io(
      BACKEND_URL,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Required for Flutter mobile
          .disableAutoConnect() // Better control over connection lifecycle
          .setAuth({'token': token}) // Optional authentication
          .setExtraHeaders({'token': token}) // Optional headers
          .setQuery({"platform": "mobile"})
          .build(),
    );
    socket.connect();

    // Handle connection lifecycle
    socket.onConnect((_) {
      print('Connection established successfully');
    });

    socket.onDisconnect((_) => print('Connection disconnected'));
    socket.onConnectError((data) => print('Connection error: $data'));
  }
}
