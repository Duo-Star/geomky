//
import 'dart:math' as math;
//
import '../Linear/Line.dart';
import '../Linear/Vector.dart';
//
import '../Fertile/DPoint.dart';
//
import '../../../Algebra/Trunk/Fertile/DNum.dart';

//
import '../Intersection/Line520.dart' as l520;
/*

 */

class XLine {
  Vector  p;
  Vector  u;
  Vector  v;

  //XLine: Line(p, u) ^^ Line(p, v)
  XLine([Vector ? p, Vector ? u, Vector ? v]):
        p = p ?? Vector (),
        u = u ?? Vector (1,  1),
        v = v ?? Vector (1, -1);

  Line get l1 => Line(p, u);
  Line get l2 => Line(p, v);

  static newPDP(Vector  p, DPoint dp) => XLine(p, dp.p1-p, dp.p2-p);

  static new2L(Line l1, Line l2) => XLine(l520.xLineLine(l1, l2), l1.v, l2.v);

  num disP(Vector p0) {
    return math.min(l1.disP(p0),l2.disP(p0));
  }

}