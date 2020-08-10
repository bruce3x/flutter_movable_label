import 'dart:math';

// convert radian to degree
double rad2deg(double radian) {
  return radian / 2 / pi * 360;
}

// convert degree to radian
double deg2rad(double degree) {
  return degree / 360 * 2 * pi;
}

const _logEnable = false;

void log(String message) {
  if (_logEnable) {
    print('[MovableLabel] $message');
  }
}
