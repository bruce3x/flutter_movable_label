import 'package:flutter/material.dart';
import 'package:flutter_movable_label/src/model.dart';

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
