import 'dart:collection';

class DartStack<T> {
  final _stack = Queue<T>();

  void push(T element) => _stack.addLast(element);
  T? pop() => _stack.isNotEmpty ? _stack.removeLast() : null;

  T? get top => _stack.isNotEmpty ? _stack.last : null;
  bool get isEmpty => _stack.isEmpty;
  bool get isNotEmpty => _stack.isNotEmpty;
  void clear() => _stack.clear();
  bool contains(T element) => _stack.contains(element);
  List<T> toList() => _stack.toList();
  int get count => _stack.length;

  @override
  String toString() => _stack.toSet().toString();
}