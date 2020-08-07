import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

@immutable
class LabelCell {
  static final randomColor = RandomColor();

  final String text;
  final Color color;

  const LabelCell({@required this.text, @required this.color});

  LabelCell.random()
      : this(
          text: generateWordPairs().first.asPascalCase,
          color: randomColor.randomColor(),
        );

  @override
  String toString() {
    return "Label($text)";
  }
}

class ColorfulLabel extends StatelessWidget {
  final LabelCell data;

  const ColorfulLabel({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
