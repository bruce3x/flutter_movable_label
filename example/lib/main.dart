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
        padding: const EdgeInsets.all(24.0),
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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RandomColor randomColor = RandomColor();

  LabelController<LabelCell> labelController = LabelController();

  LabelWidgetBuilder<LabelCell> labelBuilder = (context, data) => ColorfulLabel(data: data);

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
            child: MovableLabel<LabelCell>(
              controller: labelController,
              builder: labelBuilder,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          labelController.add(
            LabelValue(
              id: DateTime.now().toString(),
              data: randomCell(),
            ),
          );
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
