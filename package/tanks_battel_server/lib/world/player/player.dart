import 'dart:async';
import 'dart:convert';

import 'package:event_bus_arch/event_bus_arch.dart';
import 'package:tanks_battel_server/world/logic/world_controller.dart';
import 'package:tanks_battel_server/world/models/action/action.dart';
import 'package:tanks_battel_server/world/models/tank.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Player {
  int id;
  int color;
  Tank? tank;
  WebSocketChannel channel;
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  StreamSubscription? _subscription;
  EventBus bus;
  String? turnKey;
  Player(this.id, this.bus, {this.color = 0xFF0000FF, this.tank, required this.channel}) {
    //rx channel
    _subscription = channel.stream.listen(
      (event) {
        if (turnKey != null) {
          TankActionsData? action;
          if (event is String) {
            action = TankActionsData.fromJson(jsonDecode(event));
          } else if (event is Map) {
            action = TankActionsData.fromJson(event as Map<String, dynamic>);
          }
          if (action != null && turnKey == action.key) {
            turnKey = null;
            bus.send<MapEntry<int, TankActionsData>>(MapEntry(id, action),
                eventName: eWorldEventName.playerAction.name);
          } else {
            print('Error Action:$event');
          }
        } else {
          print('Error Not Turn Action:$event');
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
    bus.send<int>(id, eventName: eWorldEventName.disconnect.name);
  }

  void updateMap(List<int> map, String key, int w, int h) {
    turnKey = key;

    channel.sink.add(jsonEncode({'id': id, 'key': key, 'w': w, 'h': h, 'map': map}));
  }
}
