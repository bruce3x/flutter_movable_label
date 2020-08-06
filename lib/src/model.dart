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
