import 'dart:async';
import 'dart:convert';

import 'package:tanks_battel_server/world/logic/world_controller.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:event_bus_arch/event_bus_arch.dart';

class ServerViewClient {
  final WebSocketChannel _wsocket;
  final EventBus _bus;
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  StreamSubscription? _subscription;
  ServerViewClient(this._wsocket, this._bus) {
    //rx channel
    _subscription = _wsocket.stream.listen(
      (event) {
        if (event is String) {
          var j = jsonDecode(event);
          var c = j['command'];
          if (c == 'start') {
            _bus.send<void>(null, eventName: eWorldEventName.start.name);
          }
        }
      },
      onDone: () {
        dispose();
      },
    );
    //TODO: TX channel from bus to client
  }
  void dispose() {
    //TODO:
    _subscription?.cancel();
    _bus.send<ServerViewClient>(this, eventName: eWorldEventName.disconnectView.name);
  }

  void send(Map<String, dynamic> map) {
    _wsocket.sink.add(jsonEncode(map));
  }
}
