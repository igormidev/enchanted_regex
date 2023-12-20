typedef ForEachMapper<T> = void Function(
    T value, bool isFirst, bool isLast, int index);

extension ListUtils<T> on List<T> {
  void forEachMapper(ForEachMapper<T> toElement) {
    asMap().entries.forEach((final MapEntry<int, T> entry) {
      final index = entry.key;
      final value = entry.value;
      final isLast = (index + 1) == length;
      final isFirst = index == 0;
      toElement(value, isFirst, isLast, index);
    });
  }
}

extension ListLessBoilerPlateExtension<T> on List<T> {
  /// The single element satisfying [test].
  ///
  /// Returns `null` if there are either no elements
  /// or more than one element satisfying [test].
  ///
  /// **Notice**: This behavior differs from [Iterable.singleWhere]
  /// which always throws if there are more than one match,
  /// and only calls the `orElse` function on zero matches.
  T? singleWhereOrNull(bool Function(T element) test) {
    T? result;
    bool found = false;
    for (final T element in this) {
      if (test(element)) {
        if (found == false) {
          result = element;
          found = true;
        } else {
          return null;
        }
      }
    }
    return result;
  }

  T? firstWhereOrNull(bool Function(T element) test) {
    for (final T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
