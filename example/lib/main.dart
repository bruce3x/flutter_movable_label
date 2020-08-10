import 'package:flutter/material.dart';
import 'package:flutter_movable_label/flutter_movable_label.dart';
import 'package:movable_label_example/colorful_label.dart';
import 'package:oktoast/oktoast.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'MovableLabel Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LabelController<LabelCell> labelController = LabelController();

  GlobalKey containerKey = GlobalKey();

  LabelValue movingLabel;
  bool deleteAvailable = false;

  bool get moving => movingLabel != null;

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

  Widget _labels(BuildContext context) {
    return Container(
      key: containerKey,
      color: Colors.indigo,
      child: MovableLabel<LabelCell>(
        controller: labelController,
        builder: (_, label) => ColorfulLabel(
          data: label.data,
          active: label == movingLabel,
        ),
        onMoveStart: (label) {
          movingLabel = label;
          setState(() {});
        },
        onMoveUpdate: (state) {
          final box = containerKey.currentContext.findRenderObject() as RenderBox;
          final size = box.size;

          deleteAvailable = state.translation.dy > size.height / 2;
          setState(() {});

          return LabelState(
            translation: Offset(
              state.translation.dx.clamp(-size.width / 2, size.width / 2),
              state.translation.dy.clamp(-size.height / 2, double.infinity),
            ),
            scale: state.scale.clamp(0.2, 3.0),
            rotation: (state.rotation + 360) % 360,
          );
        },
        onMoveEnd: (label) {
          if (deleteAvailable) {
            labelController.remove(label);
            showToast('Delete: ${label.data.text}');
          }

          deleteAvailable = false;
          movingLabel = null;
          setState(() {});
        },
        onTap: (label) {
          showToast('Tap: ${label.data.text}');
        },
        onDoubleTap: (label) {
          showToast('DoubleTap: ${label.data.text}');
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
            child: _labels(context),
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
