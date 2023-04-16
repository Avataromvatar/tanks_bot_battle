import 'package:equatable/equatable.dart';
import 'package:tanks_battel_server/helper/bit_helper.dart';
import 'package:tanks_battel_server/world/models/map.dart';
import 'package:tanks_battel_server/world/models/tile.dart';

// enum eCellLayers { terrain, feature, walls, tanks, bullet }

abstract class ICellObject extends Equatable {
  ///
  ///CDTT TXXX XXXX YYYY YYYO OOOO OOOO OOOO
  int get value;
  eTanksBattelMapObjectType get type => eTanksBattelMapObjectType.values[(value >> 27) & 0x7];
  bool get isChanged => BitHelper.getBit(value, 31);
  bool get toDelete => BitHelper.getBit(value, 30);
  int get x => (value >> 20) & 0x7F;
  int get y => (value >> 13) & 0x7F;
  int get object => value & 0x1FFF;

  ///When we read value object clear changed flag!!
  int readValue();

  ///When update flag [isChanged] set true
  bool update(int value);

  static ICellObject create(
    eTanksBattelMapObjectType type, {
    int value = 0,
  }) {
    return CellObject(type, value: value);
  }

  static eTanksBattelMapObjectType typeFromValue(int value) {
    return eTanksBattelMapObjectType.values[(value >> 27) & 0x7];
  }

  int newPosition(int x, int y) {
    update((value & ~(0x7F << 20 | 0x7F << 13)) | (((x & 0x7F) << 20) | ((y & 0x7F) << 13)));
    return value;
  }

  int setToDelete(bool on) {
    if (on) {
      update(BitHelper.setBit(value, 30));
      return value;
    }
    update(BitHelper.clearBit(value, 30));
    return value;
  }

  @override
  List<Object?> get props => [value];
}

class CellObject extends ICellObject {
  int _value;
  @override
  int get value => _value;

  ///1<<31 - set changeFlag
  CellObject(
    eTanksBattelMapObjectType type, {
    int value = 0,
  }) : _value = value | type.index << 27 | 1 << 31;
  @override
  int readValue() {
    var ret = _value;
    _clearChangedFlag();
    return ret;
  }

  @override
  bool update(int value) {
    if (_value != value) {
      _value = value;
      _setChangedFlag();
      return true;
    }
    return false;
  }

  void _clearChangedFlag() {
    _value = BitHelper.clearBit(_value, 31);
  }

  void _setChangedFlag() {
    _value = BitHelper.setBit(_value, 31);
  }
}

class Cell {
  int x;
  int y;

  Map<eTanksBattelMapObjectType, ICellObject> layers = {};
  Cell(this.x, this.y, {Map<eTanksBattelMapObjectType, ICellObject>? layers}) {
    if (layers != null) {
      this.layers.addAll(layers);
    } else {
      this.layers[eTanksBattelMapObjectType.terrain] = Tile(eTileType.common);
    }
  }
  bool isChanged() {
    for (var element in layers.values) {
      if (element.isChanged) {
        return true;
      }
    }
    return false;
  }

  List<int> getLayers({bool toggleChangeFlag = true}) {
    List<int> ret = [];
    for (var element in layers.values) {
      ret.add(toggleChangeFlag ? element.readValue() : element.value);
    }
    return ret;
  }

  ICellObject? removeLayer(eTanksBattelMapObjectType layer) {
    return layers.remove(layer);
  }

  bool updateLayer(ICellObject obj) {
    if (obj.x == x && obj.y == y) {
      layers[obj.type] = obj;
      return true;
    }
    return false;
  }
}
