import 'package:tanks_battel_server/world/models/cell.dart';
import 'package:tanks_battel_server/world/models/map.dart';
import 'package:tanks_battel_server/world/models/subobject.dart';

enum eTileType {
  common,
  field,
  forest,
  river,
}

class Tile extends CellObject {
  Tile(eTileType val) : super(eTanksBattelMapObjectType.terrain, value: val.index) {
    update(value);
  }
  Tile.fromRaw(int value) : super(eTanksBattelMapObjectType.terrain, value: value) {
    update(value);
  }
  eTileType getTileType() {
    return eTileType.values[value & 0x1FFF];
  }

  void setNewTileType(eTileType type) {
    update(value | (type.index));
  }
}

// class Tile implements ICellObject {
//   ///
//   int _value;
//   @override
//   int get value => _value;

//   Tile(this._value) {}

//   @override
//   // TODO: implement isChanged
//   bool get isChanged => false;

//   @override
//   int readValue() {
//     // TODO: implement readValue
//     throw UnimplementedError();
//   }

//   @override
//   // TODO: implement type
//   eTanksBattelMapObjectType get type => throw UnimplementedError();
//   // Tile.set({int type = 0, int object = 0}) : _value = ((type & 0xFF) << 8) | (object & 0xFF);
//   // Tile copy({int? subObject}) {
//   //   if (subObject != null) {
//   //     return Tile(_value | (subObject & 0xFF));
//   //   }
//   //   return Tile(_value);
//   // }
// }
