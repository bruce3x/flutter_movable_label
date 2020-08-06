// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LabelStateCopyWithExtension on LabelState {
  LabelState copyWith({
    double rotation,
    double scale,
    Offset translation,
  }) {
    return LabelState(
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      translation: translation ?? this.translation,
    );
  }
}

extension LabelValueCopyWithExtension<T> on LabelValue<T> {
  LabelValue<T> copyWith({
    T data,
    String id,
    LabelState state,
  }) {
    return LabelValue<T>(
      data: data ?? this.data,
      id: id ?? this.id,
      state: state ?? this.state,
    );
  }
}
