import 'package:tanks_battel_server/helper/bit_helper.dart';
import 'package:tanks_battel_server/world/models/cell.dart';
import 'package:tanks_battel_server/world/models/map.dart';

class Bullet extends CellObject {
  ///13bit value:
  ///X PPPP PPDD SSHH
  ///
  ///X - not used
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
            value: ((playerID & 0x3F) << 6) | ((dir.index & 0x3) << 4) | ((speed & 0x3) << 2) | (hit & 0x3));

  Bullet.fromRaw(int value) : super(eTanksBattelMapObjectType.bullet, value: value);

  eDirection getDir() {
    return eDirection.values[(value >> 4) & 0x03];
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
    update(value | (dir.index & 0x03) << 4);
  }

  void setSpeed(int speed) {
    update(value | (speed & 0x03) << 2);
  }

  void setHits(int hit) {
    update(value | (hit & 0x03));
  }

  void setPlayerID(int player) {
    update(value | (player & 0x3F) << 6);
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
