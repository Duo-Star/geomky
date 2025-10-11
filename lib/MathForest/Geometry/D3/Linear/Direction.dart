import 'Vec3.dart';

class Direction {
  final num theta;
  final num phi;

  Direction(num theta, [num phi = 0.0])
      : theta = theta,
        phi = phi;

  //
  Vec3 get v => Vec3.newAL(this, 1);

}