import 'package:flutter/material.dart';

typedef TouchPointerCounterCallback = void Function(int count);

class TouchPointerCounter extends StatelessWidget {
  final Widget child;
  final TouchPointerCounterCallback onChange;

  final pointers = Set<int>();

  TouchPointerCounter({
    Key key,
    this.onChange,
    @required this.child,
  }) : super(key: key) {
    assert(child != null);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        pointers.add(event.pointer);
        onChange?.call(pointers.length);
      },
      onPointerUp: (event) {
        pointers.remove(event.pointer);
        onChange?.call(pointers.length);
      },
      onPointerCancel: (event) {
        pointers.remove(event.pointer);
        onChange?.call(pointers.length);
      },
      child: child,
    );
  }
}
