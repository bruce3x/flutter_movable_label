import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';

@immutable
@CopyWith()
class LabelState {
  final Offset translation;
  final double scale;
  final double rotation;

  static const LabelState zero = LabelState();

  const LabelState({this.translation = Offset.zero, this.scale = 1, this.rotation = 0});

  LabelState operator +(LabelState other) {
    return LabelState(
      translation: this.translation + other.translation,
      scale: this.scale * other.scale,
      rotation: this.rotation + other.rotation,
    );
  }

  LabelState copyWith({double rotation, double scale, Offset translation}) {
    return LabelState(
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      translation: translation ?? this.translation,
    );
  }

  @override
  String toString() {
    return "LabelState{translation: $translation, scale: $scale, rotation: $rotation}";
  }
}

@immutable
@CopyWith()
class LabelValue<T> {
  final String id;
  final T data;
  final LabelState state;

  LabelValue({@required this.id, @required this.data, this.state = LabelState.zero}) {
    assert(id != null);
    assert(data != null);
  }

  LabelValue<T> copyWith({T data, LabelState state}) {
    return LabelValue<T>(
      id: id,
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

  @override
  String toString() {
    return "LabelValue{id: $id, data: $data, state: $state}";
  }
}
