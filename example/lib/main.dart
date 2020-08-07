import 'package:flutter/material.dart';
import 'package:flutter_movable_label/flutter_movable_label.dart';
import 'package:movable_label_example/colorful_label.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
  LabelController<LabelCell> labelController = LabelController();

  bool moving = false;
  bool deleteAvailable = false;

  Widget _header() {
    return Offstage(
      offstage: moving,
      child: Center(
        child: Text(
          'Dismiss header whiling moving label',
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
    );
  }

  Widget _deleteArea() {
    return Offstage(
      offstage: !moving,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Move label here to delete.',
            style: Theme.of(context).textTheme.subtitle1.copyWith(color: deleteAvailable ? Colors.redAccent : null),
          ),
        ),
      ),
    );
  }

  Widget _labels() {
    return Container(
      color: Colors.indigo,
      child: MovableLabel<LabelCell>(
        controller: labelController,
        builder: (_, data) => ColorfulLabel(data: data),
        onMoveStart: (label) {
          moving = true;
          setState(() {});
        },
        onMoveUpdate: (state, box) {
          deleteAvailable = state.translation.dy > box.height / 2;
          setState(() {});

          return LabelState(
            translation: Offset(
              state.translation.dx.clamp(-box.width / 2, box.width / 2),
              state.translation.dy.clamp(-box.height / 2, double.infinity),
            ),
            scale: state.scale.clamp(0.2, 3.0),
            rotation: (state.rotation + 360) % 360,
          );
        },
        onMoveEnd: (label) {
          if (deleteAvailable) labelController.remove(label);

          deleteAvailable = false;
          moving = false;
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MovableLabel'),
      ),
      body: Column(
        // layout children reverse, make sure MovableLabel is above of DeleteArea
        verticalDirection: VerticalDirection.up,
        children: [
          Expanded(child: _deleteArea()),
          AspectRatio(
            aspectRatio: 1,
            child: _labels(),
          ),
          Expanded(child: _header()),
        ],
      ),
      floatingActionButton: moving
          ? null
          : FloatingActionButton(
              onPressed: () {
                labelController.add(
                  LabelValue(
                    id: Uuid().v4(),
                    data: LabelCell.random(),
                  ),
                );
              },
              child: Icon(Icons.add),
            ),
    );
  }
}
