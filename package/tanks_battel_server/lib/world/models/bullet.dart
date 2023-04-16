import 'package:tanks_battel_server/helper/bit_helper.dart';
import 'package:tanks_battel_server/world/models/cell.dart';
import 'package:tanks_battel_server/world/models/map.dart';

class Bullet extends CellObject {
  static int count = 0;
  late final int bulletID;

  ///13bit value:
  ///X PPPP PPDD SSHH
  ///
  ///M - move in this turn
  ///
  ///PPPPPP - player ID
  ///
  ///DD - Direction
  ///
  ///SS - speed
  ///
  ///HH - damage
  Bullet({int playerID = 0, int speed = 2, int hit = 1, eDirection dir = eDirection.forward})
      : super(eTanksBattelMapObjectType.bullet,
            value: ((playerID & 0x3F) << 6) | ((dir.index & 0x3) << 4) | ((speed & 0x3) << 2) | (hit & 0x3)) {
    bulletID = count;
    count++;
  }

  Bullet.fromRaw(int value) : super(eTanksBattelMapObjectType.bullet, value: value) {
    bulletID = count;
    count++;
  }

  eDirection getDir() {
    return eDirection.values[(value >> 4) & 0x03];
  }

  int get playerId => getPlayerID();
  int get speed => getSpeed();
  int get hit => getHits();
  eDirection get dir => getDir();

  // @override
  // int newPosition(int x, int y) {
  //   update((value & ~(0x7F << 20 | 0x7F << 13)) | (((x & 0x7F) << 20) | ((y & 0x7F) << 13)));

  //   return value;
  // }

  bool get isMoved => ((value >> 12) & 0x01) == 1;

  void setIsMovedFlag(bool on) {
    if (on) {
      update(BitHelper.setBit(value, 12));
    } else {
      update(BitHelper.clearBit(value, 12));
    }
  }

  int getSpeed() {
    return (value >> 2) & 0x03;
  }

  int getHits() {
    return value & 0x3;
  }

  int getPlayerID() {
    return (value >> 6) & 0x3F;
  }

  void setDir(eDirection dir) {
    update(BitHelper.clearData(value, 0x03 << 4) | (dir.index & 0x03) << 4);
  }

  void setSpeed(int speed) {
    update(BitHelper.clearData(value, 0x03 << 2) | (speed & 0x03) << 2);
  }

  void setHits(int hit) {
    update(BitHelper.clearData(value, 0x03) | (hit & 0x03));
  }

  void setPlayerID(int player) {
    update(BitHelper.clearData(value, 0x3F << 6) | (player & 0x3F) << 6);
  }
}

// class Bullet implements ICellObject {
//   ///13bit value:
//   ///CTTT PPPP PPDD SSHH
//   ///
//   ///C - change or not
//   ///
//   ///TTT - type map object
//   ///
//   ///PPPPPP - player ID
//   ///
//   ///DD - Direction
//   ///
//   ///SS - speed
//   ///
//   ///HH - damage
//   int _value;
//   @override
//   int get value => _value;
//   eTanksBattelMapObjectType get type => eTanksBattelMapObjectType.bullet;
//   eDirection get dir => getDir();
//   int get hits => getHits();
//   int get playerID => getPlayerID();
//   @override
//   bool get isChanged => (_value >> 15) & 0x1 == 1 ? true : false;
//   Bullet(this._value) {
//     _value = _value | (eTanksBattelMapObjectType.bullet.index << 12);
//   }

//   Bullet.custom({int playerID = 0, int hit = 1, eDirection dir = eDirection.forward, int speed = 1}) : _value = 0 {
//     setDir(dir);
//     setHits(hit);
//     setPlayerID(playerID);
//     setSpeed(speed);
//     _value = _value | (eTanksBattelMapObjectType.bullet.index << 12);
//   }

//   @override
//   int readValue() {
//     var ret = _value;
//     _clearChangedFlag();
//     return ret;
//   }

//   void _clearChangedFlag() {
//     _value = BitHelper.clearBit(_value, 15);
//   }

//   eDirection getDir() {
//     return eDirection.values[(_value >> 4) & 0x03];
//   }

//   int getSpeed() {
//     return (_value >> 2) & 0x03;
//   }

//   int getHits() {
//     return _value & 0x3;
//   }

//   int getPlayerID() {
//     return (_value >> 6) & 0x3F;
//   }

//   void setDir(eDirection dir) {
//     _value = _value | (dir.index & 0x03) << 4;
//   }

//   void setSpeed(int speed) {
//     _value = _value | (speed & 0x03) << 2;
//   }

//   void setHits(int hit) {
//     _value = _value | (hit & 0x03);
//   }

//   void setPlayerID(int player) {
//     _value = _value | (player & 0x3F) << 6;
//   }
// }
