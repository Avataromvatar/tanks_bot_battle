import 'dart:async';

import 'package:event_bus_arch/event_bus_arch.dart';
import 'package:tanks_battel_server/view_client/server_view_client.dart';
import 'package:tanks_battel_server/world/logic/world_time_service.dart';
import 'package:tanks_battel_server/world/models/action/action.dart';
import 'package:tanks_battel_server/world/models/bullet.dart';
import 'package:tanks_battel_server/world/models/map.dart';
import 'package:tanks_battel_server/world/models/tank.dart';
import 'package:tanks_battel_server/world/player/player.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum eWorldEventName {
  connect,
  connectView,
  disconnect,
  disconnectView,
  start,
  stop,
  reset,
  nextTurn,
  calculateTurn,
  playerAction
}

class WorldEventBus extends EventController {
  int _countPlayer = 1;
  Map<int, Player> players = {};
  Map<int, TankActionsData> turnAction = {};
  List<ServerViewClient> viewers = [];
  late TanksBattelMap map;
  bool isStart = false;
  Timer? tmr;

  WorldTime? lastWorldTime;
  WorldEventBus(String name) : super(prefix: name) {
    addHandler<WebSocketChannel>(addPlayer, eventName: eWorldEventName.connect.name);
    addHandler<int>(removePlayer, eventName: eWorldEventName.disconnect.name);
    addHandler<WebSocketChannel>(addView, eventName: eWorldEventName.connectView.name);
    addHandler<ServerViewClient>(removeView, eventName: eWorldEventName.disconnectView.name);
    addHandler<WorldTime>(nextTurn, eventName: eWorldEventName.nextTurn.name);
    addHandler<Map<int, TankActionsData>>(calculateTurn, eventName: eWorldEventName.calculateTurn.name);
    addHandler<void>(start, eventName: eWorldEventName.start.name);
    addHandler<void>(stop, eventName: eWorldEventName.stop.name);

    addHandler<MapEntry<int, TankActionsData>>(playerAction, eventName: eWorldEventName.playerAction.name);
    map = TanksBattelMap(13, 13);
    map.init(null);
  }

  Future<void> addView(EventDTO<WebSocketChannel> event, EventEmitter<EventDTO<WebSocketChannel>>? emit,
      {EventBus? bus, Completer? needComplete}) async {
    viewers.add(ServerViewClient(event.data, this));
    print('Add ViewClient');
    // if (!isStart) {
    //   isStart = true;
    //   send<void>(null, eventName: eWorldEventName.start.name);
    // }
  }

  Future<void> removeView(EventDTO<ServerViewClient> event, EventEmitter<EventDTO<ServerViewClient>>? emit,
      {EventBus? bus, Completer? needComplete}) async {
    viewers.remove(event.data);
    print('Remove ViewClient');
  }

  Future<void> addPlayer(EventDTO<WebSocketChannel> event, EventEmitter<EventDTO<WebSocketChannel>>? emit,
      {EventBus? bus, Completer? needComplete}) async {
    if (/*!isStart &&*/ players.values.length < 5) {
      while (players.containsKey(_countPlayer) && players.isNotEmpty) {
        _countPlayer++;
        if (_countPlayer > 0x1FFF) {
          _countPlayer = 1;
        }
      }
      var tank = Tank(playerID: _countPlayer, hit: 3);
      //for test 4 players
      switch (players.values.length) {
        case 0:
          tank.newPosition(2, 0);
          break;
        case 1:
          tank.newPosition(10, 0);
          break;
        case 2:
          tank.newPosition(2, 12);
          break;
        case 3:
          tank.newPosition(10, 12);
          break;
        default:
      }
      map.addObject(tank);
      players[_countPlayer] = Player(_countPlayer, this, channel: event.data, tank: tank);
      print('Add Player $_countPlayer');
      _countPlayer++;
      //Test -  for auto start
      // if (!isStart) {
      //   isStart = true;
      //   send<void>(null, eventName: eWorldEventName.start.name);
      // }
    }
  }

  Future<void> removePlayer(EventDTO<int> event, EventEmitter<EventDTO<int>>? emit,
      {EventBus? bus, Completer? needComplete}) async {
    var p = players.remove(event.data);
    if (p != null) {
      map.removeObject(p.tank!);
      print('Remove Player ${p.id}');
    }
  }

  Future<void> nextTurn(EventDTO<WorldTime> event, EventEmitter<EventDTO<WorldTime>>? emit,
      {EventBus? bus, Completer? needComplete}) async {
    lastWorldTime = event.data;
    turnAction.clear();
    // var l = map.getChanges();
    var m = event.data.turn < 2 ? map.getAll() : map.getChanges();
    for (var element in players.entries) {
      element.value.updateMap(
        m,
        '${event.data.turn}-${element.key}-${event.uuid}',
        map.width,
        map.height,
      );
    }
    for (var element in viewers) {
      element.send({'w': map.width, 'h': map.height, 'map': m});
    }
    map.clearToDelObj();
  }

  Future<void> start(EventDTO<void> event, EventEmitter<EventDTO<void>>? emit,
      {EventBus? bus, Completer? needComplete}) async {
    isStart = true;

    tmr = Timer.periodic(Duration(seconds: 1), (timer) {
      if (lastWorldTime == null) {
        lastWorldTime = WorldTime(turn: 0);
      }
      send<WorldTime>(WorldTime(turn: lastWorldTime!.turn + 1), eventName: eWorldEventName.nextTurn.name);
    });
  }

  Future<void> stop(EventDTO<void> event, EventEmitter<EventDTO<void>>? emit,
      {EventBus? bus, Completer? needComplete}) async {
    tmr?.cancel();
    isStart = false;
  }

  Future<void> playerAction(
      EventDTO<MapEntry<int, TankActionsData>> event, EventEmitter<EventDTO<MapEntry<int, TankActionsData>>>? emit,
      {EventBus? bus, Completer? needComplete}) async {
    var id = event.data.key;
    var action = event.data.value;
    turnAction[id] = action;
    if (players.length == turnAction.length) {
      send<Map<int, TankActionsData>>(turnAction, eventName: eWorldEventName.calculateTurn.name);
    }
  }

  Future<void> calculateTurn(
      EventDTO<Map<int, TankActionsData>> event, EventEmitter<EventDTO<Map<int, TankActionsData>>>? emit,
      {EventBus? bus, Completer? needComplete}) async {
    List<int> isShoot = [];
    List<int> isMove = [];
    Map<int, Tank> tanks = {};
    for (var element in players.entries) {
      tanks[element.key] = element.value.tank!;
    }
    for (var tick = 0; tick < 3; tick++) {
      for (var element in event.data.entries) {
        if (element.value.actions != null) {
          if (element.value.actions!.length > tick) {
            var a = element.value.actions![tick];
            switch (a) {
              case eTankActions.move_forward:
                if (!isMove.contains(element.key)) {
                  isMove.add(element.key);
                  // print('MoveF ${element.key} start: ${tanks[element.key]!.x} ${tanks[element.key]!.y}');
                  map.moveTank(tanks[element.key]!, isForward: true);
                  // print('MoveF ${element.key} end: ${tanks[element.key]!.x} ${tanks[element.key]!.y}');
                }
                break;
              case eTankActions.move_back:
                if (!isMove.contains(element.key)) {
                  isMove.add(element.key);
                  // print('MoveB ${element.key} start: ${tanks[element.key]!.x} ${tanks[element.key]!.y}');
                  map.moveTank(tanks[element.key]!, isForward: false);
                  // print('MoveB ${element.key} end: ${tanks[element.key]!.x} ${tanks[element.key]!.y}');
                }
                break;
              case eTankActions.platform_rotate_clockwise:
                map.rotatePlatform(tanks[element.key]!, clockwise: true);
                break;
              case eTankActions.platform_rotate_counterclockwise:
                map.rotatePlatform(tanks[element.key]!, clockwise: false);
                break;
              case eTankActions.tower_rotate_clockwise:
                map.rotateTower(tanks[element.key]!, clockwise: true);
                break;
              case eTankActions.tower_rotate_counterclockwise:
                map.rotateTower(tanks[element.key]!, clockwise: false);
                break;
              case eTankActions.shoot:
                if (!isShoot.contains(element.key)) {
                  isShoot.add(element.key);
                  map.shoot(tanks[element.key]!);
                }
                break;
              default:
            }
          }
        }
      }
    }
    for (var element in map.bullets) {
      map.moveBullet(element as Bullet);
      element.setIsMovedFlag(false);
    }
  }
}
