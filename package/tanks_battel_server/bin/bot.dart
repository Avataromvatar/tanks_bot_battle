import 'dart:async';
import 'dart:convert';

import 'package:tanks_battel_server/world/models/action/action.dart';
import 'package:tanks_battel_server/world/models/bullet.dart';
import 'package:tanks_battel_server/world/models/cell.dart';
import 'package:tanks_battel_server/world/models/map.dart';
import 'package:tanks_battel_server/world/models/tank.dart';
import 'package:tanks_battel_server/world/models/tile.dart';
import 'package:tanks_battel_server/world/models/wall.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

StreamSubscription? _streamSubscription;
WebSocketChannel? channel;
int? lastID;
void main() async {
  final wsUrl = Uri.parse('ws://127.0.0.1:33101');
  bool isRun = false;
  channel = WebSocketChannel.connect(wsUrl);
  await channel!.ready;
  isRun = true;
  _streamSubscription = channel!.stream.listen(
    (event) async {
      TankActionsData? a;
      if (event is String) {
        a = await parse(jsonDecode(event));
      }
      if (event is Map) {
        a = await parse(event as Map<String, dynamic>);
      }
      if (a != null) {
        print(a.toJson());
        channel?.sink.add(jsonEncode(a.toJson()));
      }
    },
    onDone: () {
      print('WS Done!');
      channel?.sink.close();
      isRun = false;
    },
    onError: (err) {
      print('WS Error:$err');
      isRun = false;
    },
  );
  await Future.doWhile(() async {
    await Future.delayed(Duration(seconds: 1));
    return isRun;
  });
}

int logicCount = 0;
Future<TankActionsData> parse(Map<String, dynamic> json) async {
  //---MapSize Section
  int w = json['w'];
  int h = json['h'];
  String key = json['key'];
  int playerID = json['id'];
  lastID = playerID;
  List<dynamic> map = json['map'];
  //---- Map object section V2
  Tank? playerTank;
  TankActionsData? actions;
  Map<int, Tile> mapTile = {};
  Map<int, Tank> mapTank = {};
  Map<int, Wall> mapWall = {};
  Map<int, Bullet> mapBullet = {};
  for (var e in map) {
    switch (ICellObject.typeFromValue(e as int)) {
      case eTanksBattelMapObjectType.terrain:
        var t = Tile.fromRaw(e);
        mapTile[t.x + t.y * w] = t;
        // tiles.add(Tile.fromRaw(e));
        break;
      case eTanksBattelMapObjectType.bullet:
        var t = Bullet.fromRaw(e);
        mapBullet[t.x + t.y * w] = t;
        // bullet.add(Bullet.fromRaw(e));
        break;
      case eTanksBattelMapObjectType.wall:
        var t = Wall.fromRaw(e);
        mapWall[t.x + t.y * w] = t;
        // walls.add(Wall.fromRaw(e));
        break;
      case eTanksBattelMapObjectType.tank:
        var t = Tank.fromRaw(e);
        if (t.getPlayerID() == playerID) {
          playerTank = t;
        }
        mapTank[t.x + t.y * w] = t;
        // tanks.add(Tank.fromRaw(e));
        break;
      default:
    }
  }
  if (logicCount == 0) {
    actions = TankActionsData(key: key, actions: [
      eTankActions.tower_rotate_clockwise,
      eTankActions.shoot,
      eTankActions.move_back,
    ]);
  } else if (logicCount == 1) {
    actions = TankActionsData(key: key, actions: [
      eTankActions.move_back,
      eTankActions.platform_rotate_clockwise,
      eTankActions.shoot,
    ]);
  } else if (logicCount == 2) {
    actions = TankActionsData(key: key, actions: [
      eTankActions.platform_rotate_clockwise,
      eTankActions.tower_rotate_clockwise,
      eTankActions.shoot,
    ]);
  } else if (logicCount == 3) {
    actions = TankActionsData(
        key: key, actions: [eTankActions.tower_rotate_clockwise, eTankActions.shoot, eTankActions.move_forward]);
  } else if (logicCount == 4) {
    actions = TankActionsData(
        key: key, actions: [eTankActions.shoot, eTankActions.tower_rotate_clockwise, eTankActions.move_forward]);
  }
  logicCount++;
  if (logicCount > 4) {
    logicCount = 0;
  }
  return actions!;
}

// void parseMap(Map<String, dynamic> json) {
//   //---MapSize Section
//   int w = json['w'];
//   int h = json['h'];
//   if (w != _lastMapSize?.w || h != _lastMapSize?.h) {
//     _lastMapSize = MapSize(w: w, h: h);
//     gEventBus.send<MapSize>(MapSize(w: w, h: h));
//     print('New Map Size $w $h');
//   }
//   List<dynamic> map = json['map'];
//   //---- Map object section V1
//   // List<Tile> tiles = [];
//   // List<Tank> tanks = [];
//   // List<Wall> walls = [];
//   // List<Bullet> bullet = [];

//   // for (var e in map) {
//   //   switch (ICellObject.typeFromValue(e as int)) {
//   //     case eTanksBattelMapObjectType.terrain:
//   //       tiles.add(Tile.fromRaw(e));
//   //       break;
//   //     case eTanksBattelMapObjectType.bullet:
//   //       bullet.add(Bullet.fromRaw(e));
//   //       break;
//   //     case eTanksBattelMapObjectType.wall:
//   //       walls.add(Wall.fromRaw(e));
//   //       break;
//   //     case eTanksBattelMapObjectType.tank:
//   //       tanks.add(Tank.fromRaw(e));
//   //       break;
//   //     default:
//   //   }
//   // }

//   // if (tiles.isNotEmpty) {
//   //   print('Tile update');
//   //   tiles.forEach((element) {
//   //     gEventBus.send<Tile>(element, eventName: '${element.x}:${element.y}');
//   //   });
//   //   // bus?.send<List<Tile>>(tiles);
//   // }
//   // if (tanks.isNotEmpty) {
//   //   tanks.forEach((element) {
//   //     gEventBus.send<Tank>(element, eventName: '${element.x}:${element.y}');
//   //   });
//   //   // bus?.send<List<Tank>>(tanks);
//   // }
//   // if (walls.isNotEmpty) {
//   //   print('Wall update');
//   //   walls.forEach((element) {
//   //     gEventBus.send<Wall>(element, eventName: '${element.x}:${element.y}');
//   //   });
//   //   // bus?.send<List<Wall>>(walls);
//   // }
//   // if (bullet.isNotEmpty) {
//   //   bullet.forEach((element) {
//   //     gEventBus.send<Bullet>(element, eventName: '${element.x}:${element.y}');
//   //   });
//   //   // bus?.send<List<Bullet>>(bullet);
//   // }
//   //---- Map object section V2
//   Map<int, Tile> mapTile = {};
//   Map<int, Tank> mapTank = {};
//   Map<int, Wall> mapWall = {};
//   Map<int, Bullet> mapBullet = {};
//   for (var e in map) {
//     switch (ICellObject.typeFromValue(e as int)) {
//       case eTanksBattelMapObjectType.terrain:
//         var t = Tile.fromRaw(e);
//         mapTile[t.x + t.y * w] = t;
//         // tiles.add(Tile.fromRaw(e));
//         break;
//       case eTanksBattelMapObjectType.bullet:
//         var t = Bullet.fromRaw(e);
//         mapBullet[t.x + t.y * w] = t;
//         // bullet.add(Bullet.fromRaw(e));
//         break;
//       case eTanksBattelMapObjectType.wall:
//         var t = Wall.fromRaw(e);
//         mapWall[t.x + t.y * w] = t;
//         // walls.add(Wall.fromRaw(e));
//         break;
//       case eTanksBattelMapObjectType.tank:
//         var t = Tank.fromRaw(e);
//         mapTank[t.x + t.y * w] = t;
//         // tanks.add(Tank.fromRaw(e));
//         break;
//       default:
//     }
//   }
//   for (var i = 0; i < w * h; i++) {
//     var x = i % w;
//     var y = i ~/ w;
//     var lt = gEventBus.lastEvent<Tile>(eventName: '$x:$y');
//     var lw = gEventBus.lastEvent<Wall>(eventName: '$x:$y');
//     var ltank = gEventBus.lastEvent<Tank>(eventName: '$x:$y');
//     var lb = gEventBus.lastEvent<Bullet>(eventName: '$x:$y');

//     var tile = mapTile[i];
//     var wall = mapWall[i];
//     var tank = mapTank[i];
//     var bullet = mapBullet[i];

//     if (tile != null) {
//       gEventBus.send<Tile>(tile, eventName: '$x:$y');
//     } else {
//       if (lt != null) {
//         lt.setToDelete(true);
//         gEventBus.send<Tile>(lt, eventName: '$x:$y');
//       }
//     }
//     if (wall != null) {
//       gEventBus.send<Wall>(wall, eventName: '$x:$y');
//     } else {
//       if (lw != null) {
//         lw.setToDelete(true);
//         gEventBus.send<Wall>(lw, eventName: '$x:$y');
//       }
//     }
//     if (tank != null) {
//       gEventBus.send<Tank>(tank, eventName: '$x:$y');
//     } else {
//       if (ltank != null) {
//         ltank.setToDelete(true);
//         gEventBus.send<Tank>(ltank, eventName: '$x:$y');
//       }
//     }
//     if (bullet != null) {
//       gEventBus.send<Bullet>(bullet, eventName: '$x:$y');
//     } else {
//       if (lb != null) {
//         lb.setToDelete(true);
//         gEventBus.send<Bullet>(lb, eventName: '$x:$y');
//       }
//     }
//   }
// }