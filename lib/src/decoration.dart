import 'dart:math';

import 'package:flutter/material.dart';

///
/// Shape like this 👇 but with rounded corner
///      +-----------------+
///    X                   |
///  X                     |
///    X                   |
///      +-----------------+
///
class ArrowDecoration extends Decoration {
  final Color color;
  final double radius;
  final double angleLength;

  ArrowDecoration(this.color, this.radius, this.angleLength);

  @override
  BoxPainter createBoxPainter([onChanged]) {
    return ArrowDecorationPainter(color, radius, angleLength);
  }
}

class ArrowDecorationPainter extends BoxPainter {
  final Color color;
  final double radius;
  final double angleLength;

  ArrowDecorationPainter(this.color, this.radius, this.angleLength);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect bounds = offset & configuration.size;

    final leftCircleAngle = (pi / 2 - atan(bounds.height / 2 / angleLength)) * 2;
    final bottomCircleAngle = pi - (leftCircleAngle / 2 + pi / 2);

    final topLeftCenter = bounds.topLeft.translate(radius * tan(bottomCircleAngle / 2), radius);
    final topRightCenter = bounds.topRight.translate(-radius, radius);
    final bottomRightCenter = bounds.bottomRight.translate(-radius, -radius);
    final bottomLeftCenter = topLeftCenter.translate(0, bounds.height - 2 * radius);
    final leftCenter = Offset(bounds.left - angleLength + radius / sin(leftCircleAngle / 2), bounds.center.dy);

    final Path path = Path()
      ..moveToPoint(topLeftCenter + Offset.fromDirection(-pi / 2, radius))
      ..lineToPoint(topRightCenter + Offset.fromDirection(-pi / 2, radius))
      ..arcTo(Rect.fromCircle(center: topRightCenter, radius: radius), -pi / 2, pi / 2, false)
      ..lineToPoint(bottomRightCenter + Offset.fromDirection(0, radius))
      ..arcTo(Rect.fromCircle(center: bottomRightCenter, radius: radius), 0, pi / 2, false)
      ..lineToPoint(bottomLeftCenter + Offset.fromDirection(pi / 2, radius))
      ..arcTo(Rect.fromCircle(center: bottomLeftCenter, radius: radius), pi / 2, bottomCircleAngle, false)
      ..lineToPoint(leftCenter + Offset.fromDirection(pi - leftCircleAngle / 2, radius))
      ..arcTo(Rect.fromCircle(center: leftCenter, radius: radius), pi - leftCircleAngle / 2, leftCircleAngle, false)
      ..lineToPoint(topLeftCenter + Offset.fromDirection(-pi / 2 - bottomCircleAngle, radius))
      ..arcTo(
          Rect.fromCircle(center: topLeftCenter, radius: radius), -pi / 2 - bottomCircleAngle, bottomCircleAngle, false)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }
}

extension PathExtension on Path {
  void lineToPoint(Offset point) {
    lineTo(point.dx, point.dy);
  }

  void moveToPoint(Offset point) {
    moveTo(point.dx, point.dy);
  }
}
