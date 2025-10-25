//

import 'dart:math';
import '../../../Algebra/Functions/Main.dart' as funcs;
//
import '../../../Algebra/Trunk/Fertile/DNum.dart';
import '../../../Algebra/Trunk/Fertile/QNum.dart';
//
import '../Linear/Vector.dart';
//
import '../Fertile/DPoint.dart';
import '../Fertile/QPoint.dart';

/*

 */

//
class Circle {
  Vector p = Vector();
  num r = 1;

  String get type => "Cir";

  Circle(this.p, this.r);

  Circle.new2P(Vector p1, Vector p2) : p = p1, r = (p2 - p1).len;

  num get area => pi * r * r;
  num get cir => 2 * pi * r;

  Vector indexPoint(num theta) => p + Vector(r) * cos(theta) + Vector(0, r) * sin(theta);
  DPoint indexDPoint(DNum theta) => DPoint(indexPoint(theta.n1), indexPoint(theta.n2));
  QPoint indexQPoint(QNum theta) => QPoint(
    indexPoint(theta.n1),
    indexPoint(theta.n2),
    indexPoint(theta.n3),
    indexPoint(theta.n4),
  );

  num disP(Vector p0){
    return funcs.abs((p0 - p).len - r);
  }

  @override
  String toString() {
    return "Cir2(${p.toString()} , $r})";
  }
}
