library flutter_movable_label;

import 'package:flutter/material.dart';

class LabelState {
  final Offset translation;
  final double scale;
  final double rotation;

  LabelState({this.translation = Offset.zero, this.scale = 0, this.rotation = 0});
}

class MovableLabel extends StatefulWidget {
  @override
  _MovableLabelState createState() => _MovableLabelState();
}

class _MovableLabelState extends State<MovableLabel> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
