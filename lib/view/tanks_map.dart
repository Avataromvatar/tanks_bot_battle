import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tanks_battel/main.dart';
import 'package:tanks_battel/view/models/map_size.dart';
import 'package:tanks_battel_server/server_model.dart';
import 'package:tanks_battel_server/world/models/map.dart';

class AppTanksBattelMap extends StatefulWidget {
  AppTanksBattelMap({super.key});

  @override
  State<AppTanksBattelMap> createState() => _AppTanksBattelMapState();
}

class _AppTanksBattelMapState extends State<AppTanksBattelMap> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                color: Colors.red,
                child: Column(children: [
                  TextButton(
                      onPressed: () {
                        gEventBus.send<String>(jsonEncode({'command': 'start'}), eventName: 'toServer');
                      },
                      child: Text('Start'))
                ]),
              )),
          Expanded(
              flex: 6,
              child: Container(
                color: Colors.green,
                child: StreamBuilder<MapSize>(
                    initialData: gEventBus.lastEvent<MapSize>(),
                    stream: gEventBus.listenEvent<MapSize>()!,
                    builder: (context, snapshotSize) {
                      if (!snapshotSize.hasData) {
                        print('NO View Map');
                        return SizedBox();
                      }
                      print('View Map');

                      return LayoutBuilder(builder: (context, con) {
                        double w = 0;
                        double h = 0;
                        if (snapshotSize.hasData) {
                          w = con.maxWidth / snapshotSize.data!.w;
                          h = con.maxHeight / snapshotSize.data!.h;
                        }
                        return Table(
                          defaultColumnWidth:
                              FlexColumnWidth(1), // FixedColumnWidth(con.maxWidth / (snapshotSize.data!.w)),
                          children: [
                            for (int i = 0; i < snapshotSize.data!.h; i++)
                              TableRow(children: [
                                for (int i1 = 0; i1 < snapshotSize.data!.w; i1++)
                                  Stack(
                                    children: [
                                      StreamBuilder(
                                        initialData: gEventBus.lastEvent<Tile?>(eventName: '$i1:$i'),
                                        stream: gEventBus.listenEvent<Tile?>(eventName: '$i1:$i'),
                                        builder: (context, snapshotTile) {
                                          if (snapshotTile.hasData) {
                                            return Image.asset(
                                              'assets/terrain/terrain_common.png',
                                              width: w,
                                              height: h,
                                              fit: BoxFit.fill,
                                            );
                                          } else
                                            return SizedBox(
                                              width: w,
                                              height: h,
                                            );
                                        },
                                      ),
                                      StreamBuilder(
                                        // initialData: gEventBus.lastEvent<Wall?>(eventName: '$i1:$i'),
                                        stream: gEventBus.listenEvent<Wall?>(eventName: '$i1:$i'),
                                        builder: (context, snapshotWall) {
                                          if (snapshotWall.hasData) {
                                            return snapshotWall.data!.toDelete
                                                ? SizedBox(
                                                    width: w,
                                                    height: h,
                                                  )
                                                : Image.asset(
                                                    'assets/walls/brick_wall_3.png',
                                                    fit: BoxFit.fill,
                                                    width: w,
                                                    height: h,
                                                  );
                                          } else
                                            return SizedBox(
                                              width: w,
                                              height: h,
                                            );
                                        },
                                      ),
                                      StreamBuilder(
                                        // initialData: gEventBus.lastEvent<Tank?>(eventName: '$i1:$i'),
                                        stream: gEventBus.listenEvent<Tank?>(eventName: '$i1:$i'),
                                        builder: (context, snapshotTank) {
                                          if (snapshotTank.hasData) {
                                            return snapshotTank.data!.toDelete
                                                ? SizedBox(
                                                    width: w,
                                                    height: h,
                                                  )
                                                : Stack(
                                                    children: [
                                                      Image.asset(getPlatformAsset(snapshotTank.data!),
                                                          width: w, height: h, fit: BoxFit.fill),
                                                      Image.asset(getTowerAsset(snapshotTank.data!), fit: BoxFit.fill),
                                                    ],
                                                  );
                                            // Image.asset('assets/tanks/tank_green.png', fit: BoxFit.fill);
                                          } else
                                            return SizedBox(
                                              width: w,
                                              height: h,
                                            );
                                        },
                                      ),
                                      StreamBuilder(
                                        initialData: gEventBus.lastEvent<Bullet?>(eventName: '$i1:$i'),
                                        stream: gEventBus.listenEvent<Bullet?>(eventName: '$i1:$i'),
                                        builder: (context, snapshotWall) {
                                          if (snapshotWall.hasData) {
                                            return snapshotWall.data!.toDelete
                                                ? SizedBox(
                                                    width: w,
                                                    height: h,
                                                  )
                                                : Image.asset(
                                                    'assets/tanks/shoot.png',
                                                    fit: BoxFit.fill,
                                                    width: w,
                                                    height: h,
                                                  );
                                          } else
                                            return SizedBox(
                                              width: w,
                                              height: h,
                                            );
                                        },
                                      ),
                                    ],
                                  )
                              ])
                          ],
                        );
                      });
                    }),
              )),
        ],
      ),
    );
  }

  String getPlatformAsset(Tank tank) {
    switch (tank.getPlatformDir()) {
      case eDirection.forward:
        return 'assets/tanks/tank_green_pf.png';
      case eDirection.right:
        return 'assets/tanks/tank_green_pr.png';
      case eDirection.back:
        return 'assets/tanks/tank_green_pb.png';
      case eDirection.left:
        return 'assets/tanks/tank_green_pl.png';
      default:
        return 'assets/tanks/tank_green_pf.png';
    }
  }

  String getTowerAsset(Tank tank) {
    switch (tank.getTowerDir()) {
      case eDirection.forward:
        return 'assets/tanks/tank_green_tf.png';
      case eDirection.right:
        return 'assets/tanks/tank_green_tr.png';
      case eDirection.back:
        return 'assets/tanks/tank_green_tb.png';
      case eDirection.left:
        return 'assets/tanks/tank_green_tl.png';
      default:
        return 'assets/tanks/tank_green_tf.png';
    }
  }
}
