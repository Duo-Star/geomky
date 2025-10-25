// 平面骈点
import '../Linear/Line.dart';
import '../Linear/Vector.dart';
import '../../../Algebra/Trunk/Fertile/DNum.dart';

/*
共生双点，没有区分方法和必要
例如，我们的 圆 和 直线 交出的 骈点
为了程序存储，我们使用 P1,P2 但请注意，序号没有意义
上游（比如交点求解器-方程求解器）产生数学意义上的顺序，一般不去作为区分条件

 */

class DPoint {
  Vector p1;
  Vector p2;

  DPoint([Vector? p1, Vector? p2])
    : p1 = p1 ?? Vector(-1),
      p2 = p2 ?? Vector(1);

  DPoint.newPV([Vector? p, Vector? v])
    : p1 = (p ?? Vector.zero) + (v ?? Vector(1, 0)),
      p2 = (p ?? Vector.zero) - (v ?? Vector(1, 0));

  Vector get mid => (p1 + p2) / 2;

  Line get l => Line.new2P(p1, p2);

  DNum disP(Vector p0){
    return DNum(p0.dis(p1), p0.dis(p2));
  }

  static DPoint zero = DPoint(Vector.zero, Vector.zero);
  static DPoint inf = DPoint(Vector.inf, Vector.inf);
  static DPoint nan = DPoint(Vector.nan, Vector.nan);

  @override
  String toString() {
    return 'DPoint(${p1.toString()}, ${p2.toString()})';
  }
}
