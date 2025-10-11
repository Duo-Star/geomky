//
import 'dart:math';
import '../Linear/Vector.dart';
import '../Linear/Line.dart';

/*

 */

class HLine {
  final Vector p1;
  final Vector p2;
  final Vector v;

  HLine([Vector? p1, Vector? p2, Vector? v]):
        p1 = p1 ?? Vector(-1),
        p2 = p2 ?? Vector(1),
        v = v ?? Vector(0, 1);

  Line get l1 => Line(p1, v);
  Line get l2 => Line(p2, v);


}