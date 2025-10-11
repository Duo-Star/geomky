import 'dart:math';
import '../../../Algebra/Trunk/Fertile/DNum.dart';
import '../Fertile/DPoint.dart';
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


  //Conic get conic => Conic().byConic1(this);


  @override
  String toString() {
    return 'Conic1(${p.toString()}, ${v.toString()}, ${v.toString()})';
  }

}