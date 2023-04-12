import 'package:tanks_battel_server/helper/bit_helper.dart';
import 'package:tanks_battel_server/world/models/cell.dart';
import 'package:tanks_battel_server/world/models/map.dart';

enum eWallType { wood, brick, stone, immortal }

class Wall extends CellObject {
  ///13bit value:
  ///X TTTT XXXX HHHH
  ///
  ///X - not used
  ///
  ///TTTT - sub type (view)
  ///
  ///HHHH - Hits
  Wall({int hit = 3, eWallType subtype = eWallType.brick})
      : super(eTanksBattelMapObjectType.wall, value: ((subtype.index & 0x15) << 8) | (hit & 0x15));

  Wall.fromRaw(int value) : super(eTanksBattelMapObjectType.wall, value: value);

  void setHit(int hit) {
    update(value | (hit & 0x15));
  }

  void setWallType(eWallType type) {
    update(value | (type.index & 0x15) << 8);
  }

  eWallType getWallType() {
    return eWallType.values[(value >> 8) & 0x15];
  }

  int getHits() {
    return value & 0x15;
  }
}

// class Wall implements ICellObject {
//   ///16bit value:
//   ///CTTT PPPP PPDD xHHH
//   ///
//   ///C - change or not
//   ///
//   ///TTT - type map object
//   ///
//   ///XXXXX - not used
//   ///
//   ///SS - sub type
//   ///
//   ///x - not used
//   ///
//   ///HHH - Hits
//   int _value;
//   @override
//   int get value => _value;
//   @override
//   eTanksBattelMapObjectType get type => eTanksBattelMapObjectType.wall;
//   eWallType get wallType => getWallType();

//   int get hits => getHits();

//   @override
//   bool get isChanged => (_value >> 15) & 0x1 == 1 ? true : false;
//   Wall(this._value) {
//     //set
//     _value = _value | (eTanksBattelMapObjectType.wall.index << 12);
//   }
//   Wall.type({eWallType type = eWallType.hit3}) : _value = 0 {
//     _value = _value | (eTanksBattelMapObjectType.wall.index << 12);
//     _setWallType(type);
//     switch (type) {
//       case eWallType.hit1:
//         _setHit(1);
//         break;
//       case eWallType.hit3:
//         _setHit(3);
//         break;
//       case eWallType.hit7:
//         _setHit(7);
//         break;
//       case eWallType.immortal:
//         _setHit(0);
//         break;
//       default:
//     }
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

//   void _setHit(int hit) {
//     _value = _value | (hit & 0x7);
//   }

//   void _setWallType(eWallType type) {
//     _value = _value | type.index << 4;
//   }

//   eWallType getWallType() {
//     return eWallType.values[(_value >> 4) & 0x03];
//   }

//   int getHits() {
//     return _value & 0x7;
//   }
// }
