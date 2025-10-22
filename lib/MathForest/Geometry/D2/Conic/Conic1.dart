import 'dart:math';
import '../../../Algebra/Trunk/Fertile/DNum.dart';
import '../../../Algebra/Trunk/Fertile/QNum.dart';
import '../Fertile/DPoint.dart';
import '../Fertile/QPoint.dart';
import 'HLine.dart';
import 'XLine.dart';

//import 'Conic.dart';



import '../Linear/Vector.dart';
import '../Linear/Line.dart';


class Conic1 {
  Vector p ;
  Vector v ;

  Conic1([Vector? p, Vector? v]): //中心，OF
        p = p ?? Vector.zero,
        v = v ?? Vector.i;

  String get type => "Conic1";

  Vector get u => v.roll90();

  Vector indexPoint(num t) => u*t + v*(t*t/4);
  DPoint indexDPoint(DNum theta) => DPoint(indexPoint(theta.n1), indexPoint(theta.n2));
  QPoint indexQPoint(QNum theta) => QPoint(
    indexPoint(theta.n1),
    indexPoint(theta.n2),
    indexPoint(theta.n3),
    indexPoint(theta.n4),
  );

  //Conic get conic => Conic().byConic1(this);


  @override
  String toString() {
    return 'Conic1(${p.toString()}, ${v.toString()}, ${v.toString()})';
  }

}