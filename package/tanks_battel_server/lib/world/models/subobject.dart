abstract class ISubObject {
  int get value;
  factory ISubObject(int val) {
    return SubObject(val);
  }
}

class SubObject implements ISubObject {
  int _value;
  @override
  int get value => _value;
  SubObject(this._value);
}
