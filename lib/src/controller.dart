import 'package:flutter/material.dart';
import 'package:flutter_movable_label/src/model.dart';

class LabelController<T> extends ValueNotifier<List<LabelValue<T>>> {
  LabelController({List<LabelValue<T>> initial = const []}) : super(initial);

  void add(LabelValue<T> label) {
    value = List.from(value, growable: true)..add(label);
  }

  void remove(LabelValue<T> label) {
    value = List.from(value, growable: true)..remove(label);
  }
}
