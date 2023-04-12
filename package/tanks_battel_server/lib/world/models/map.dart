import 'package:tanks_battel_server/world/models/bullet.dart';
import 'package:tanks_battel_server/world/models/cell.dart';
import 'package:tanks_battel_server/world/models/tank.dart';
import 'package:tanks_battel_server/world/models/tile.dart';
import 'package:tanks_battel_server/world/models/wall.dart';

enum eDirection {
  forward,
  right,
  back,
  left,
}

enum eTanksBattelMapObjectType {
  hide,
  terrain,
  feature,
  wall,
  tank,
  bullet,
  other,
  ;

  // int type;
  // const eTanksBattelMapObjectType(this.type);
}

class TanksBattelMap {
  int width;
  int height;
  late Tile defaultTile;
  List<Cell> cells = [];
  // Map<int, List<ICellObject>> cells = {};
  // Map<int, Tank> tanksByPlayerID = {};
  // Map<int, Bullet> bulletByPlayerID = {};
  Map<int, Wall> wallsByIndex = {};
  TanksBattelMap(this.width, this.height, {Tile? defaultTile}) {
    this.defaultTile = defaultTile ?? Tile(eTileType.common);
  }
  Future init(dynamic map) async {
    //for test
    width = 13;
    height = 13;
    var len = width * height;

    for (var i = 0; i < len; i++) {
      ICellObject? obj;
      Tile? tile;

      var y = i ~/ width;
      var x = i % width;
      if (x == 6 || y == 6) {
        obj = Wall();
        obj.newPosition(x, y);
      }
      if ((x == 3 || x == 10) && (y == 0 || y == 12)) {
        //new player spawn
      }
      tile = tile ?? Tile(defaultTile.getTileType());
      tile.newPosition(x, y);
      var cell = Cell(i % width, i ~/ width,
          layers: {eTanksBattelMapObjectType.terrain: tile, if (obj != null) eTanksBattelMapObjectType.wall: obj});

      if (obj?.type == eTanksBattelMapObjectType.wall) {
        wallsByIndex[i] = obj as Wall;
      }
      cells[getIndex(x, y)] = cell;
      // cells[getIndex(x, y)]!.add(tile);
      // if (obj != null) {
      //   cells[getIndex(x, y)]!.add(obj);
      // }
    }
  }

  bool addObject(ICellObject obj) {
    var index = getIndex(obj.x, obj.y);
    var c = cells[index];
    c.layers[obj.type] = obj;
    return true;
  }

  bool removeObject(ICellObject obj) {
    var index = getIndex(obj.x, obj.y);
    var c = cells[index];
    c.layers.remove(obj.type);
    return true;
  }

  bool moveTank(Tank tank, {bool isForward = true}) {
    var index = getIndex(tank.x, tank.y);
    var c = cells[index];
    var t = c.layers[eTanksBattelMapObjectType.tank];
    if (t?.value == tank.value) {
      var targetIndex = getNextCellToDir(tank.getPlatformDir(), tank.x, tank.y, isForward: isForward);

      if (targetIndex != null) {
        var targetCell = cells[targetIndex];
        var twall = targetCell.layers[eTanksBattelMapObjectType.wall];
        if (twall == null /*|| twall.toDelete*/) {
          if (targetCell.layers.containsKey(eTanksBattelMapObjectType.bullet)) {
            var bullet = targetCell.layers[eTanksBattelMapObjectType.bullet] as Bullet;
            if (!bullet.toDelete) {
              hitTank(tank, bullet);
              bullet.setToDelete(true);
            }
          }
          t!.newPosition(targetCell.x, targetCell.y);
          return true;
        }
      }
    }
    return false;
  }

  void shoot(Tank tank) {
    var index = getIndex(tank.x, tank.y);
    var c = cells[index];
    var t = c.layers[eTanksBattelMapObjectType.tank];
    if (t?.value == tank.value) {
      var tIndex = getNextCellToDir(tank.getTowerDir(), tank.x, tank.y);
      if (tIndex != null) {
        var b = Bullet(playerID: tank.getPlayerID(), dir: tank.getTowerDir());
        moveBullet(
          b,
        );
        // var ct = cells[tIndex];
        // var wt = ct.layers[eTanksBattelMapObjectType.wall];
        // var tt = ct.layers[eTanksBattelMapObjectType.tank];
        // var bt = ct.layers[eTanksBattelMapObjectType.bullet];
        // if()
      }
    }
  }

  void moveBullet(Bullet b, {int? speed}) {
    var index = getIndex(b.x, b.y);

    for (var i = 0; i < (speed ?? b.getSpeed()); i++) {
      if (index < 0) {
        //exit from map
        b.setToDelete(true);
        return;
      }
      if (b.toDelete) {
        return;
      }
      //getIndex(b.x, b.y);
      var ct = cells[index];
      var wt = ct.layers[eTanksBattelMapObjectType.wall];
      var tt = ct.layers[eTanksBattelMapObjectType.tank];
      var bt = ct.layers[eTanksBattelMapObjectType.bullet];
      if (wt != null && wt is Wall) {
        wt.setHit(wt.getHits() - b.getHits());
        if (wt.getHits() <= 0) {
          wt.setToDelete(true);
          b.setToDelete(true);
          return;
        }
        b.setToDelete(true);
      }
      if (tt is Tank) {
        tt.setHits(tt.getHits() - b.getHits());
        if (tt.getHits() <= 0) {
          tt.setToDelete(true);
          b.setToDelete(true);
          return;
        }
        b.setToDelete(true);
      }
      if (bt is Bullet) {
        bt.setToDelete(true);
        b.setToDelete(true);
        return;
      }

      index = getNextCellToDir(b.getDir(), ct.x, ct.y) ?? -1;
    }
  }

  int? getNextCellToDir(eDirection dir, int x, int y, {bool isForward = true}) {
    var targetIndex = -1;
    switch (dir) {
      case eDirection.forward:
        targetIndex = getIndex(x, isForward ? y - 1 : y + 1);
        break;
      case eDirection.back:
        targetIndex = getIndex(x, isForward ? y + 1 : y - 1);
        break;
      case eDirection.left:
        targetIndex = getIndex(isForward ? x - 1 : x + 1, y);
        break;
      case eDirection.right:
        targetIndex = getIndex(isForward ? x + 1 : x - 1, y);
        break;
      default:
    }
    if (targetIndex >= 0 && targetIndex < width * height) {
      return targetIndex;
    }
    return null;
  }

  // void moveAllBullet() {}

  void rotatePlatform(Tank tank, {bool clockwise = true}) {
    tank.setPlatformDir(nextDir(tank.getPlatformDir(), clockwise: clockwise));
  }

  void rotateTower(Tank tank, {bool clockwise = true}) {
    tank.setToweDir(nextDir(tank.getTowerDir(), clockwise: clockwise));
  }

  eDirection nextDir(eDirection currentDir, {bool clockwise = true}) {
    switch (currentDir) {
      case eDirection.forward:
        return clockwise ? eDirection.right : eDirection.left;
        break;
      case eDirection.back:
        return clockwise ? eDirection.left : eDirection.right;
        break;
      case eDirection.left:
        return clockwise ? eDirection.forward : eDirection.back;
        break;
      case eDirection.right:
        return clockwise ? eDirection.back : eDirection.forward;
        break;
      default:
        return currentDir;
    }
  }

  void hitTank(Tank t, Bullet b) {
    t.setHits(t.getHits() - b.getHits());
    if (t.getHits() <= 0) {
      t.setToDelete(true);
    }
  }

  void hitWall(Wall t, Bullet b) {
    t.setHit(t.getHits() - b.getHits());
    if (t.getHits() <= 0) {
      t.setToDelete(true);
    }
  }
  // bool moveObj(ICellObject obj, int newX,int newY)
  // {
  //    if (newX < 0 || newY < 0) return false;
  //   var sourceIndex = getIndex(obj.x, obj.y);
  //   var targetIndex = getIndex(newX, newY);
  //   if (targetIndex < cells.length && sourceIndex < cells.length) {
  //     var s = cells[sourceIndex];
  //     var t = cells[sourceIndex];

  //     c.layers[obj.type] = obj;
  //     return true;
  //   }
  //   return false;
  // }

  List<int> getTerrain() {
    return cells.map((e) => e.layers[eTanksBattelMapObjectType.terrain]!.value).toList();
  }

  List<int> getAll() {
    List<int> ret = [];
    for (var element in cells) {
      ret.addAll(element.getLayers(toggleChangeFlag: false));
    }
    return ret;
  }

  List<int> getChanges() {
    List<int> ret = [];
    for (var element in cells) {
      if (element.isChanged()) {
        ret.addAll(element.getLayers());
      }
    }
    return ret;
  }

  Cell? getCellByDir(Cell source, eDirection dir) {
    int? index;
    switch (dir) {
      case eDirection.forward:
        if (source.y - 1 >= 0) {
          index = getIndex(source.x, source.y - 1);
        }
        break;
      case eDirection.back:
        if (source.y + 1 < height) {
          index = getIndex(source.x, source.y + 1);
        }
        break;
      case eDirection.right:
        if (source.x + 1 < width) {
          index = getIndex(source.x + 1, source.y);
        }
        break;
      case eDirection.left:
        if (source.x - 1 >= 0) {
          index = getIndex(source.x, source.y + 1);
        }
        break;
      default:
    }
    if (index != null) {
      return cells[index];
    }
    return null;
  }

  int getIndex(int x, int y) {
    return y * width + x;
  }
}
