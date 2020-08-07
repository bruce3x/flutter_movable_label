import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_movable_label/src/controller.dart';
import 'package:flutter_movable_label/src/model.dart';
import 'package:flutter_movable_label/src/util.dart';

typedef LabelWidgetBuilder<T> = Widget Function(BuildContext context, T data);

class MovableLabel<T> extends StatefulWidget {
  final LabelController<T> controller;
  final LabelWidgetBuilder<T> builder;

  MovableLabel({Key key, @required this.controller, @required this.builder}) : super(key: key) {
    assert(controller != null);
    assert(builder != null);
  }

  @override
  _MovableLabelState<T> createState() => _MovableLabelState<T>();
}

class _MovableLabelState<T> extends State<MovableLabel<T>> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ValueListenableBuilder<List<LabelValue<T>>>(
        valueListenable: widget.controller,
        builder: (_, value, child) {
          return Stack(
            children: value
                .map((label) => _LabelWidget(
                      initialState: label.state,
                      child: widget.builder(context, label.data),
                      onStateUpdate: (state) => widget.controller.update(label.copyWith(state: state), label),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class _LabelWidget extends StatefulWidget {
  final LabelState initialState;
  final Widget child;
  final Function(LabelState) onStateUpdate;

  const _LabelWidget({Key key, this.initialState, this.child, this.onStateUpdate}) : super(key: key);

  @override
  _LabelWidgetState createState() => _LabelWidgetState();
}

class _LabelWidgetState extends State<_LabelWidget> {
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
    state = widget.initialState.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return GestureDetector(
          onScaleStart: (details) {
            startOffset = details.focalPoint;
          },
          onScaleUpdate: (details) {
            if (startOffset == null) return;
            final stateDiff = LabelState(
              translation: details.focalPoint - startOffset,
              scale: details.scale,
              rotation: rad2deg(details.rotation),
            );

            state = widget.initialState + stateDiff;

            state = state.copyWith(
              translation: clamp(state.translation, constraints.maxWidth / 2, constraints.maxHeight / 2),
            );

            setState(() {});
          },
          onScaleEnd: (details) {
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
                  angle: deg2rad(state.rotation),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
