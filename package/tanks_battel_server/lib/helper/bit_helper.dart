class BitHelper {
  static int bit(int pos) {
    return 1 << pos;
  }

  static int clearBit(int val, int pos) {
    return val & (~(bit(pos)));
  }

  static int setBit(int val, int pos) {
    return val | (bit(pos));
  }

  static bool getBit(int val, int pos) {
    return (val & (bit(pos))) != 0 ? true : false;
  }

  static int toggle(int val, int pos) {
    return val ^ (bit(pos));
  }

  static int setData(int val, int data, {int pos = 0}) {
    return val | (data << pos);
  }

  static int clearData(int val, int mask, {int pos = 0}) {
    return val & (~(mask << pos));
  }
}
