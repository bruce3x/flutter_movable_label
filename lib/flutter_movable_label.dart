library flutter_movable_label;

import 'dart:math';

import 'package:flutter/material.dart';

class LabelState {
  final Offset translation;
  final double scale;
  final double rotation;

  LabelState({this.translation = Offset.zero, this.scale = 0, this.rotation = 0});

  LabelState copyWith({Offset translation, double scale, double rotation}) {
    return LabelState(
      translation: translation ?? this.translation,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }
}

class Label {
  final Widget widget;
  final LabelState state;

  Label(this.widget, this.state);
}

class LabelWidget extends StatefulWidget {
  final Label label;
  final Function(LabelState) onStateUpdate;

  const LabelWidget({Key key, this.label, this.onStateUpdate}) : super(key: key);

  @override
  _LabelWidgetState createState() => _LabelWidgetState();
}

class _LabelWidgetState extends State<LabelWidget> {
  LabelState state;

  @override
  void initState() {
    super.initState();
    state = widget.label.state.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (detail) {},
      onPanUpdate: (details) {
        state = state.copyWith(translation: state.translation + details.delta);
        setState(() {});
      },
      onPanCancel: () {
        widget.onStateUpdate?.call(state);
      },
      onPanEnd: (detail) {
        widget.onStateUpdate?.call(state);
      },
      child: Align(
        alignment: Alignment.center,
        child: Transform.translate(
          offset: state.translation,
          child: Transform.scale(
            scale: state.scale,
            child: Transform.rotate(
              angle: state.rotation / 360 * 2 * pi,
              child: widget.label.widget,
            ),
          ),
        ),
      ),
    );
  }
}

class MovableLabel extends StatefulWidget {
  final List<Label> labels;

  const MovableLabel({Key key, this.labels}) : super(key: key);

  @override
  _MovableLabelState createState() => _MovableLabelState();
}

class _MovableLabelState extends State<MovableLabel> {
  List<Label> labels;
  @override
  void initState() {
    super.initState();
    labels = List.from(widget.labels ?? <Label>[]);
  }

  @override
  Widget build(BuildContext context) {
    final children = labels
        .asMap()
        .entries
        .map((entry) => LabelWidget(
              label: entry.value,
              onStateUpdate: (state) {
                labels[entry.key] = Label(entry.value.widget, state);
                setState(() {});
              },
            ))
        .toList();

    return Stack(
      children: children,
    );
  }
}
