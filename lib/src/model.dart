import 'package:flutter/material.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'model.g.dart';

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

  @override
  bool operator ==(Object other) {
    return other is LabelValue<T> && this.id == other.id;
  }

  @override
  int get hashCode => this.id.hashCode;
}
