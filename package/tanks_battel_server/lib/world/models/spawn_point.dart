import 'package:tanks_battel_server/helper/bit_helper.dart';
import 'package:tanks_battel_server/world/models/cell.dart';
import 'package:tanks_battel_server/world/models/map.dart';
import 'package:tanks_battel_server/world/models/subobject.dart';

class SpawnPoint implements ISubObject {
  ///8bit value:
  int _value;
  int get value => _value;
  SpawnPoint(this._value);

  int get playerID => getPlayerID();
  int getPlayerID() {
    return _value & 0x3F;
  }

  // int readValue() {
  //   var ret = _value;
  //   _clearChangedFlag();
  //   return ret;
  // }

  void _clearChangedFlag() {
    _value = BitHelper.clearBit(_value, 15);
  }
}
