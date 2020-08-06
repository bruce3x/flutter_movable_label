library flutter_movable_label;

import 'dart:math';

import 'package:flutter/material.dart';

class LabelState {
  final Offset translation;
  final double scale;
  final double rotation;

  static const LabelState zero = LabelState();

  const LabelState({this.translation = Offset.zero, this.scale = 1, this.rotation = 0});

  LabelState copyWith({Offset translation, double scale, double rotation}) {
    return LabelState(
      translation: translation ?? this.translation,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  LabelState operator +(LabelState other) {
    return LabelState(
      translation: this.translation + other.translation,
      scale: this.scale * other.scale,
      rotation: this.rotation + other.rotation,
    );
  }
}

class Label {
  final Widget widget;
  final LabelState state;

  Label({@required this.widget, this.state = LabelState.zero});
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

  Offset startOffset;

  Offset clamp(Offset offset, double halfWidth, double halfHeight) {
    return Offset(
      offset.dx.clamp(-halfWidth, halfWidth),
      offset.dy.clamp(-halfHeight, halfHeight),
    );
  }

  @override
  void initState() {
    super.initState();
    state = widget.label.state.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    print('Building item $this');
    return LayoutBuilder(
      builder: (_, constraints) {
        return GestureDetector(
          // onPanStart: (detail) {},
          // onPanUpdate: (details) {
          //   final offset = state.translation + details.delta;
          //   state = state.copyWith(
          //       translation: Offset(
          //     offset.dx.clamp(-constraints.maxWidth / 2, constraints.maxWidth / 2),
          //     offset.dy.clamp(-constraints.maxHeight / 2, constraints.maxHeight / 2),
          //   ));
          //   setState(() {});
          // },
          // onPanCancel: () {
          //   widget.onStateUpdate?.call(state);
          // },
          // onPanEnd: (detail) {
          //   widget.onStateUpdate?.call(state);
          // },

          onScaleStart: (details) {
            print('onScaleStart: $details');
            startOffset = details.focalPoint;
          },
          onScaleUpdate: (details) {
            if (startOffset == null) return;
            state = widget.label.state +
                LabelState(
                  translation:
                      clamp(details.focalPoint - startOffset, constraints.maxWidth / 2, constraints.maxHeight / 2),
                  scale: details.scale,
                  rotation: (details.rotation / 2 / pi * 360) % 360,
                );
            setState(() {});
          },
          onScaleEnd: (details) {
            print('onScaleEnd: $details');
            startOffset = null;
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
      },
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
                labels[entry.key] = Label(widget: entry.value.widget, state: state);
                setState(() {});
              },
            ))
        .toList();

    print(">>>>> ${widget.labels.length} ${children.length}");
    return ClipRect(
      child: Stack(children: children),
    );
  }
}
