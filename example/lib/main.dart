import 'package:flutter/material.dart';
import 'package:flutter_movable_label/flutter_movable_label.dart';
import 'package:random_color/random_color.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovableLabel Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class LabelCell {
  final String text;
  final Color color;

  LabelCell({@required this.text, @required this.color});
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RandomColor randomColor = RandomColor();
  final List<LabelCell> cells = [];

  Widget _label(LabelCell cell) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cell.color,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          cell.text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MovableLabel'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            color: Colors.indigo,
            child: MovableLabel(
              labels: List.generate(5, (index) => randomCell()).map((cell) => Label(widget: _label(cell))).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // this.cells.add(randomCell());
          // setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }

  LabelCell randomCell() {
    return LabelCell(
      text: generateWordPairs().first.asPascalCase,
      color: randomColor.randomColor(),
    );
  }
}
