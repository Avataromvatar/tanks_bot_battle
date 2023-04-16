import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tanks_battel/view/models/map_size.dart';
import 'package:tanks_battel/view/tanks_map.dart';
import 'package:tanks_battel_server/world/models/map.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:event_bus_arch/event_bus_arch.dart';
import 'package:tanks_battel_server/server_model.dart';

EventModelController gEventBus = EventModelController(
  prefix: 'client',
);
StreamSubscription? _streamSubscription;
WebSocketChannel? channel;
void main() async {
  gEventBus.addHandler<dynamic>(parse);
  // gEventBus.setLogger(
  //   cb: (p0) {
  //     print('---- $p0 -----');
  //   },
  // );
  final wsUrl = Uri.parse('ws://127.0.0.1:33100');

  channel = WebSocketChannel.connect(wsUrl);
  await channel!.ready;

  _streamSubscription = channel!.stream.listen(
    (event) {
      gEventBus.send<dynamic>(event);
    },
    onDone: () {
      print('WS Done!');
    },
    onError: (err) {
      print('WS Error:$err');
    },
  );
  gEventBus.listenEvent<String>(eventName: 'toServer')!.listen(
    (event) {
      channel?.sink.add(event);
    },
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: AppTanksBattelMap(),
    );
  }
}

MapSize? _lastMapSize;
Future<void> parse(EventDTO<dynamic> event, EventEmitter<EventDTO<dynamic>>? emit,
    {EventBus? bus, Completer? needComplete}) async {
  Map<String, dynamic> json = jsonDecode(event.data);
  if (json.containsKey('status')) {
    parseStatus(json);
    return;
  }
  if (json.containsKey('w')) {
    parseMap(json);

    return;
  }

  //------

  // print(event.data);
}

void parseMap(Map<String, dynamic> json) {
  //---MapSize Section
  int w = json['w'];
  int h = json['h'];
  if (w != _lastMapSize?.w || h != _lastMapSize?.h) {
    _lastMapSize = MapSize(w: w, h: h);
    gEventBus.send<MapSize>(MapSize(w: w, h: h));
    print('New Map Size $w $h');
  }
  List<dynamic> map = json['map'];
  //---- Map object section V1
  // List<Tile> tiles = [];
  // List<Tank> tanks = [];
  // List<Wall> walls = [];
  // List<Bullet> bullet = [];

  // for (var e in map) {
  //   switch (ICellObject.typeFromValue(e as int)) {
  //     case eTanksBattelMapObjectType.terrain:
  //       tiles.add(Tile.fromRaw(e));
  //       break;
  //     case eTanksBattelMapObjectType.bullet:
  //       bullet.add(Bullet.fromRaw(e));
  //       break;
  //     case eTanksBattelMapObjectType.wall:
  //       walls.add(Wall.fromRaw(e));
  //       break;
  //     case eTanksBattelMapObjectType.tank:
  //       tanks.add(Tank.fromRaw(e));
  //       break;
  //     default:
  //   }
  // }

  // if (tiles.isNotEmpty) {
  //   print('Tile update');
  //   tiles.forEach((element) {
  //     gEventBus.send<Tile>(element, eventName: '${element.x}:${element.y}');
  //   });
  //   // bus?.send<List<Tile>>(tiles);
  // }
  // if (tanks.isNotEmpty) {
  //   tanks.forEach((element) {
  //     gEventBus.send<Tank>(element, eventName: '${element.x}:${element.y}');
  //   });
  //   // bus?.send<List<Tank>>(tanks);
  // }
  // if (walls.isNotEmpty) {
  //   print('Wall update');
  //   walls.forEach((element) {
  //     gEventBus.send<Wall>(element, eventName: '${element.x}:${element.y}');
  //   });
  //   // bus?.send<List<Wall>>(walls);
  // }
  // if (bullet.isNotEmpty) {
  //   bullet.forEach((element) {
  //     gEventBus.send<Bullet>(element, eventName: '${element.x}:${element.y}');
  //   });
  //   // bus?.send<List<Bullet>>(bullet);
  // }
  //---- Map object section V2
  var lastIndex = w * h;
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
        mapTank[t.x + t.y * w] = t;
        // tanks.add(Tank.fromRaw(e));
        break;
      default:
    }
  }
  for (var i = 0; i < w * h; i++) {
    var x = i % w;
    var y = i ~/ w;
    var lt = gEventBus.lastEvent<Tile>(eventName: '$x:$y');
    var lw = gEventBus.lastEvent<Wall>(eventName: '$x:$y');
    var ltank = gEventBus.lastEvent<Tank>(eventName: '$x:$y');
    var lb = gEventBus.lastEvent<Bullet>(eventName: '$x:$y');

    var tile = mapTile[i];
    var wall = mapWall[i];
    var tank = mapTank[i];
    var bullet = mapBullet[i];

    if (tile != null) {
      gEventBus.send<Tile?>(tile, eventName: '$x:$y');
    } else {
      // gEventBus.send<Tile?>(null, eventName: '$x:$y');
    }
    if (wall != null) {
      gEventBus.send<Wall?>(wall, eventName: '$x:$y');
    } else {
      // gEventBus.send<Wall?>(null, eventName: '$x:$y');
    }
    if (tank != null) {
      gEventBus.send<Tank?>(tank, eventName: '$x:$y');
    } else {
      // if (ltank != null) {
      // ltank.setToDelete(true);
      // gEventBus.send<Tank>(ltank, eventName: '$x:$y');
      gEventBus.send<Tank?>(null, eventName: '$x:$y');
      // }
    }
    if (bullet != null) {
      gEventBus.send<Bullet?>(bullet, eventName: '$x:$y');
    } else {
      // if (lb != null) {
      // lb.setToDelete(true);
      // gEventBus.send<Bullet?>(lb, eventName: '$x:$y');
      gEventBus.send<Bullet?>(null, eventName: '$x:$y');
      // }
    }
  }
}

void parseStatus(Map<String, dynamic> json) {}
