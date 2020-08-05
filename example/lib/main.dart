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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RandomColor _randomColor = RandomColor();

  Widget _label(String text) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _randomColor.randomColor(colorHue: ColorHue.blue),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
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
              labels: [
                Label(
                  _label(generateWordPairs().first.first),
                  LabelState(
                    translation: Offset(0, 0),
                    scale: 1.0,
                    rotation: 45,
                  ),
                ),
                Label(
                  _label(generateWordPairs().first.first),
                  LabelState(
                    translation: Offset(100, 0),
                    scale: 1.5,
                    rotation: 90,
                  ),
                ),
                Label(
                  _label(generateWordPairs().first.first),
                  LabelState(
                    translation: Offset(0, 100),
                    scale: 2.0,
                    rotation: 30,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
