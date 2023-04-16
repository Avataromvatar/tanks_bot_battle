extension ListExtension<E> on List<E> {
  E? firstWhereOrNull(bool Function(E element) handler) {
    bool ret = false;
    for (var i = 0; i < length; i++) {
      ret = handler.call(this[i]);
      if (ret) return this[i];
    }
  }
}
