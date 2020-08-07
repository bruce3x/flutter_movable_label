import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movable_label/src/controller.dart';
import 'package:flutter_movable_label/src/model.dart';
import 'package:flutter_movable_label/src/touch.dart';
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
  LabelValue<T> moving;
  LabelState initialState;
  Offset initialTouchPosition;

  int pointerCount = 0;

  void startTouch(LabelValue<T> label) {
    if (moving != null) return;
    print('Touching ${label.data}');
    moving = label;
    widget.controller.remove(label);
    setState(() {});
  }

  void finishTouch() {
    if (moving == null) return;
    widget.controller.add(moving);
    moving = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TouchPointerCounter(
      onChange: (count) => pointerCount = count,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (details) {
          print('scaleStart: $details');
          if (moving == null) return;
          initialState = moving.state;
          initialTouchPosition = details.localFocalPoint;
          print('Initial touch ... state & pos');
        },
        onScaleUpdate: (details) {
          if (initialTouchPosition == null) return;

          LabelState adjust = LabelState(
            translation: (details.localFocalPoint - initialTouchPosition),
            scale: details.scale,
            rotation: rad2deg(details.rotation),
          );

          moving = moving.copyWith(state: initialState + adjust);
          setState(() {});
        },
        onScaleEnd: (details) {
          print('scaleEnd: $details');
          if (pointerCount == 0) {
            finishTouch();
            print('Finish touch.. cleanup');
          }
        },
        child: ClipRect(
          child: ValueListenableBuilder<List<LabelValue<T>>>(
            valueListenable: widget.controller,
            builder: (_, value, child) {
              List<LabelValue<T>> labels = List.of(value);
              if (moving != null) labels.add(moving);
              return Stack(
                children: labels
                    .map(
                      (label) => Listener(
                        onPointerDown: (event) => startTouch(label),
                        child: _LabelWidget(
                          state: label.state,
                          child: widget.builder(context, label.data),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LabelWidget extends StatelessWidget {
  final LabelState state;
  final Widget child;

  const _LabelWidget({Key key, this.state = LabelState.zero, @required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Transform.translate(
        offset: state.translation,
        child: Transform.scale(
          scale: state.scale,
          child: Transform.rotate(
            angle: deg2rad(state.rotation),
            child: child,
          ),
        ),
      ),
    );
  }
}
