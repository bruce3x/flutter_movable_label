import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movable_label/src/controller.dart';
import 'package:flutter_movable_label/src/model.dart';
import 'package:flutter_movable_label/src/touch.dart';
import 'package:flutter_movable_label/src/util.dart';

typedef LabelWidgetBuilder<T> = Widget Function(BuildContext context, LabelValue<T> label);

typedef LabelCallback<T> = void Function(LabelValue<T> label);
typedef MoveLabelUpdateCallback = LabelState Function(LabelState state);

class MovableLabel<T> extends StatefulWidget {
  final LabelController<T> controller;
  final LabelWidgetBuilder<T> builder;

  final LabelCallback<T> onMoveStart;
  final MoveLabelUpdateCallback onMoveUpdate;
  final LabelCallback<T> onMoveEnd;

  final LabelCallback<T> onTap;
  final LabelCallback<T> onDoubleTap;

  MovableLabel({
    Key key,
    @required this.controller,
    @required this.builder,
    this.onMoveStart,
    this.onMoveUpdate,
    this.onMoveEnd,
    this.onTap,
    this.onDoubleTap,
  }) : super(key: key) {
    assert(controller != null);
    assert(builder != null);
  }

  @override
  _MovableLabelState<T> createState() => _MovableLabelState<T>();
}

class _MovableLabelState<T> extends State<MovableLabel<T>> {
  LabelValue<T> lastTouched;
  LabelValue<T> touching;
  LabelState initialState;
  Offset initialTouchPosition;

  Widget _labels() {
    return ClipRect(
      child: ValueListenableBuilder<List<LabelValue<T>>>(
        valueListenable: widget.controller,
        builder: (_, value, child) {
          return Stack(
            children: value
                .map(
                  (label) => Listener(
                    onPointerDown: (event) => _startTouch(label),
                    child: _LabelWidget(
                      state: label.state,
                      child: widget.builder(context, label),
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
    if (touching == null) return SizedBox.shrink();

    return _LabelWidget(
      state: touching.state,
      child: widget.builder(context, touching),
    );
  }

  void _startTouch(LabelValue<T> label) {
    if (touching != null) return;
    log('Start touch $label');
    touching = label;
    widget.controller.remove(label);
    setState(() {});
  }

  void _finishTouch() {
    if (touching != null) widget.controller.add(touching);
    lastTouched = touching;
    touching = null;
    initialTouchPosition = null;
    initialState = null;
    log('Finish touch, cleanup, last touched = $lastTouched');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TouchPointerCounter(
      onChange: (count) {
        log('pointerCount => $count');
        if (count == 0) _finishTouch();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (details) {
          log('scaleStart: $details');
          if (touching == null) return;
          initialState = touching.state;
          initialTouchPosition = details.localFocalPoint;
          widget.onMoveStart?.call(touching);
        },
        onScaleUpdate: (details) {
          if (initialTouchPosition == null || touching == null) return;

          LabelState adjustment = LabelState(
            translation: (details.localFocalPoint - initialTouchPosition),
            scale: details.scale,
            rotation: rad2deg(details.rotation),
          );

          LabelState nextState = initialState + adjustment;
          nextState = widget.onMoveUpdate?.call(nextState) ?? nextState;

          touching = touching.copyWith(state: nextState);
          setState(() {});
        },
        onScaleEnd: (details) {
          log('scaleEnd: $details');
          if (lastTouched != null) {
            widget.onMoveEnd?.call(lastTouched);
          }
        },
        onTap: () {
          log('onTap');
          widget.onTap?.call(lastTouched);
        },
        onDoubleTap: () {
          log('onDoubleTap');
          widget.onDoubleTap?.call(lastTouched);
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
