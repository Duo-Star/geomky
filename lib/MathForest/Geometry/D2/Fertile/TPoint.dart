import '../Linear/Line.dart';
import '../Linear/Vector.dart';
import '../../../Algebra/Trunk/Fertile/DNum.dart';

class TPoint {
  Vector p;
  Vector p1;
  Vector p2;

  TPoint([Vector? p, Vector? p1, Vector? p2])
    : p = p ?? Vector(),
      p1 = p1 ?? Vector(-1),
      p2 = p2 ?? Vector(1);
}
