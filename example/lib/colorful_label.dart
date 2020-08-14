import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movable_label/flutter_movable_label.dart';
import 'package:random_color/random_color.dart';

@immutable
class LabelCell {
  static final randomColor = RandomColor();

  final String text;
  final Color color;
  final bool arrow;

  const LabelCell({@required this.text, @required this.color, this.arrow = false});

  LabelCell.random()
      : this(
          text: generateWordPairs().first.asPascalCase,
          color: randomColor.randomColor(),
          arrow: Random().nextBool(),
        );

  @override
  String toString() {
    return "Label($text)";
  }
}

class ColorfulLabel extends StatelessWidget {
  final LabelCell data;
  final bool active;

  const ColorfulLabel({Key key, this.data, this.active = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = data.arrow
        ? ArrowDecoration(data.color, 4.0, 12)
        : BoxDecoration(
            color: data.color,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: active ? Border.all(color: Colors.redAccent) : null,
          );
    return DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          data.text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
