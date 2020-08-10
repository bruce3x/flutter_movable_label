import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movable_label/src/controller.dart';
import 'package:flutter_movable_label/src/model.dart';
import 'package:flutter_movable_label/src/touch.dart';
import 'package:flutter_movable_label/src/util.dart';

typedef LabelWidgetBuilder<T> = Widget Function(BuildContext context, T data);

typedef MoveLabelStartCallback<T> = void Function(LabelValue<T> label);
typedef MoveLabelUpdateCallback = LabelState Function(LabelState state);
typedef MoveLabelEndCallback<T> = void Function(LabelValue<T> label);

class MovableLabel<T> extends StatefulWidget {
  final LabelController<T> controller;
  final LabelWidgetBuilder<T> builder;

  final MoveLabelStartCallback<T> onMoveStart;
  final MoveLabelUpdateCallback onMoveUpdate;
  final MoveLabelEndCallback<T> onMoveEnd;

  MovableLabel({
    Key key,
    @required this.controller,
    @required this.builder,
    this.onMoveStart,
    this.onMoveUpdate,
    this.onMoveEnd,
  }) : super(key: key) {
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

  Widget _labels() {
    return ClipRect(
      child: ValueListenableBuilder<List<LabelValue<T>>>(
        valueListenable: widget.controller,
        builder: (_, value, child) {
          return Stack(
            children: value
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
    );
  }

  Widget _activeLabel() {
    if (moving == null) return SizedBox.shrink();

    return _LabelWidget(
      state: moving.state,
      child: widget.builder(context, moving.data),
    );
  }

  void startTouch(LabelValue<T> label) {
    if (moving != null) return;
    log('Touching ${label.data}');
    moving = label;
    widget.controller.remove(label);
    widget.onMoveStart?.call(moving);
    setState(() {});
  }

  void finishTouch() {
    if (moving == null) return;
    log('Finsh touch');
    widget.controller.add(moving);
    widget.onMoveEnd?.call(moving);
    moving = null;
    setState(() {});
  }

  LabelState nextState(LabelState adjust) {
    final nextState = initialState + adjust;
    return widget.onMoveUpdate?.call(nextState) ?? nextState;
  }

  @override
  Widget build(BuildContext context) {
    return TouchPointerCounter(
      onChange: (count) => pointerCount = count,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (details) {
          log('scaleStart: $details');
          if (moving == null) return;
          initialState = moving.state;
          initialTouchPosition = details.localFocalPoint;
        },
        onScaleUpdate: (details) {
          if (initialTouchPosition == null) return;

          LabelState adjust = LabelState(
            translation: (details.localFocalPoint - initialTouchPosition),
            scale: details.scale,
            rotation: rad2deg(details.rotation),
          );

          moving = moving.copyWith(state: nextState(adjust));
          setState(() {});
        },
        onScaleEnd: (details) {
          log('scaleEnd: $details');
          if (pointerCount == 0) {
            finishTouch();
          }
        },
        child: Stack(
          children: [
            _labels(),
            _activeLabel(),
          ],
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
