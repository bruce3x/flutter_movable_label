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

class LabelWidget extends StatefulWidget {
  final LabelState initialState;
  final Widget child;
  final Function(LabelState) onStateUpdate;

  const LabelWidget({Key key, this.initialState, this.child, this.onStateUpdate}) : super(key: key);

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
    state = widget.initialState.copyWith();
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
            state = widget.initialState +
                LabelState(
                  translation: details.focalPoint - startOffset,
                  scale: details.scale,
                  rotation: (details.rotation / 2 / pi * 360) % 360,
                );

            state = state.copyWith(
              translation: clamp(state.translation, constraints.maxWidth / 2, constraints.maxHeight / 2),
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

class MovableLabel<T> extends StatefulWidget {
  final LabelController<T> controller;
  final LabelWidgetBuilder<T> builder;

  const MovableLabel({Key key, @required this.controller, @required this.builder}) : super(key: key);

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
                .map((label) => LabelWidget(
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

typedef LabelWidgetBuilder<T> = Widget Function(BuildContext context, T data);

class LabelValue<T> {
  final String id;
  final T data;
  final LabelState state;

  const LabelValue({@required this.id, @required this.data, this.state = LabelState.zero});

  LabelValue<T> copyWith({T data, LabelState state}) {
    return LabelValue(
      id: this.id,
      data: data ?? this.data,
      state: state ?? this.state,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LabelValue<T> && this.id == other.id;
  }

  @override
  int get hashCode => this.id.hashCode;
}

class LabelController<T> extends ValueNotifier<List<LabelValue<T>>> {
  LabelController({List<LabelValue<T>> initial = const []}) : super(initial);

  void add(LabelValue<T> label) {
    value = List.from(value, growable: true)..add(label);
  }

  void update(LabelValue<T> label, LabelValue<T> oldLabel) {
    final index = value.indexOf(oldLabel);
    if (index >= 0) {
      value = List.from(value, growable: true)..[index] = label;
    }
  }

  void remove(LabelValue<T> label) {
    value = List.from(value, growable: true)..remove(label);
  }
}
