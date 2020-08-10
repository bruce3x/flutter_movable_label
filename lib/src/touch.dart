import 'package:flutter/material.dart';

typedef TouchPointerCounterCallback = void Function(int count);

class TouchPointerCounter extends StatefulWidget {
  final Widget child;
  final TouchPointerCounterCallback onChange;

  TouchPointerCounter({Key key, @required this.child, this.onChange}) : super(key: key) {
    assert(child != null);
  }

  @override
  _TouchPointerCounterState createState() => _TouchPointerCounterState();
}

class _TouchPointerCounterState extends State<TouchPointerCounter> {
  final pointers = Set<int>();
  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        pointers.add(event.pointer);
        widget.onChange?.call(pointers.length);
      },
      onPointerUp: (event) {
        pointers.remove(event.pointer);
        widget.onChange?.call(pointers.length);
      },
      onPointerCancel: (event) {
        pointers.remove(event.pointer);
        widget.onChange?.call(pointers.length);
      },
      child: widget.child,
    );
  }
}
