import 'package:tanks_battel_server/helper/bit_helper.dart';
import 'package:tanks_battel_server/world/models/cell.dart';
import 'package:tanks_battel_server/world/models/map.dart';

class Tank extends CellObject {
  ///13bit value:
  ///X PPPP PPDD ddHH
  ///
  ///X - not used
  ///
  ///PPPPPP - player ID
  ///
  ///DD - Tower Direction
  ///
  ///dd - Platform Direction
  ///
  ///HH - Hits
  Tank(
      {int playerID = 0,
      eDirection dirPlatform = eDirection.forward,
      int hit = 1,
      eDirection dirTower = eDirection.forward})
      : super(eTanksBattelMapObjectType.tank,
            value: ((playerID & 0x3F) << 6) |
                ((dirTower.index & 0x3) << 4) |
                ((dirPlatform.index & 0x3) << 2) |
                (hit & 0x3));

  Tank.fromRaw(int value) : super(eTanksBattelMapObjectType.tank, value: value);

  eDirection getTowerDir() {
    return eDirection.values[(value >> 4) & 0x03];
  }

  eDirection getPlatformDir() {
    return eDirection.values[(value >> 2) & 0x03];
  }

  int getHits() {
    return value & 0x3;
  }

  int getPlayerID() {
    return (value >> 6) & 0x3F;
  }

  void setToweDir(eDirection dir) {
    update(BitHelper.clearData(value, 0x03 << 4) | (dir.index & 0x03) << 4);
  }

  void setPlatformDir(eDirection dir) {
    update(BitHelper.clearData(value, 0x03 << 2) | (dir.index & 0x03) << 2);
  }

  void setHits(int hit) {
    update(BitHelper.clearData(value, 0x03) | (hit & 0x03));
  }

  void setPlayerID(int player) {
    update(BitHelper.clearData(value, 0x3F << 6) | (player & 0x3F) << 6);
  }
}

// class Tank extends ICellObject {
//   ///16bit value:
//   ///CTTT PPPP PPDD ddHH
//   ///
//   ///C - change or not
//   ///
//   ///TTT - type map object
//   ///
//   ///PPPPPP - player ID
//   ///
//   ///DD - Tower Direction
//   ///
//   ///dd - Platform Direction
//   ///
//   ///HH - Hits
//   int _value;
//   @override
//   int get value => _value;
//   eTanksBattelMapObjectType get type => eTanksBattelMapObjectType.tank;
//   eDirection get towerDir => getTowerDir();
//   eDirection get platformDir => getTowerDir();
//   int get hits => getHits();
//   int get playerID => getPlayerID();
//   @override
//   bool get isChanged => (_value >> 15) & 0x1 == 1 ? true : false;
//   Tank(this._value) {
//     //set
//     _value = _value | (eTanksBattelMapObjectType.tank.index << 12);
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

//   eDirection getTowerDir() {
//     return eDirection.values[(_value >> 4) & 0x03];
//   }

//   eDirection getPlatformDir() {
//     return eDirection.values[(_value >> 2) & 0x03];
//   }

//   int getHits() {
//     return _value & 0x3;
//   }

//   int getPlayerID() {
//     return (_value >> 6) & 0x3F;
//   }
// }
