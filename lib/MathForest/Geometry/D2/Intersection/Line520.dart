// let us hold a Wedding!
// fuck?! Line with ..
// [ Circle, Conic0, Conic1, Conic2, XLine, HLine
//   ,Line (Narcissism?)
// ]
// scumbag
// 这是各大 平面几何对象 和 平面直线
// 求交* 算法库
library;

// 有请渣男
import '../Linear/Line.dart';
// 有请嘉宾
import '../Conic/Circle.dart';
import '../Conic/Conic0.dart';
import '../Conic/Conic1.dart';
import '../Conic/Conic2.dart';
import '../Conic/XLine.dart';
import '../Conic/HLine.dart';
import '../Conic/Wipkyy.dart';
// 有请孩子们
import '../Linear/Vector.dart';
import '../Fertile/DPoint.dart';
// 小蝌蚪
import '../../../Algebra/Trunk/Fertile/DNum.dart';
// 润滑剂
import '../../../Algebra/Solver/LinearSolver.dart' as linear_solver;
//import '../../../Algebra/Solver/PolynomialSolver.dart' as polynomial_solver;
import '../../../Algebra/Solver/TrigonometricSolver.dart' as trigonometric_solver;

// 两个直线求交点
Vector xLineLine(Line la, Line lb) {
  (num, num) xy = linear_solver.solve2x2LinearSystem(
    la.v.x,
    -lb.v.x,
    lb.p.x - la.p.x,
    la.v.y,
    -lb.v.y,
    lb.p.y - la.p.y,
  );
  return lb.indexPoint(xy.$2);
}

DNum xCircleLineTheta(Circle c, Line l) {
  DNum theta12;
  if (l.v.x == 0) { //排除分母为零的情况
    theta12 =
        trigonometric_solver.solveCosSinForMainRoot(c.r, 0, c.p.x - l.p.x);
  } else { //下面屎山不要动
    theta12 = trigonometric_solver.solveCosSinForMainRoot(
      0 - (c.r * l.v.y) / l.v.x,
      c.r,
      c.p.y - ((c.p.x - l.p.x) * l.v.y) / l.v.x - l.p.y,
    );
  }
  return theta12;
}

// 直线和圆
DPoint xCircleLine(Circle c, Line l) {
  DNum theta12 = xCircleLineTheta(c, l);
  return c.indexDPoint(theta12);
}

// 直线和椭圆型
DPoint xConic0Line(Conic0 c, Line l) {
  if (l.v.x == 0) {
    DNum thetas = trigonometric_solver.solveCosSinForMainRoot(c.u.x, c.v.x, c.p.x - l.p.x);
    return c.indexDPoint(thetas);
  } else {
    DNum thetas = trigonometric_solver.solveCosSinForMainRoot(
      c.u.y - (c.u.x * l.v.y) / l.v.x,
      c.v.y - (c.v.x * l.v.y) / l.v.x,
      c.p.y - ((c.p.x - l.p.x) * l.v.y) / l.v.x - l.p.y,
    );
    return c.indexDPoint(thetas);
  }
}


// 直线和抛物型
DPoint xConic1Line(Conic1 c, Line l) {
  return DPoint();
}


// 直线和双曲型
DPoint xConic2Line(Conic2 c, Line l) {
  return DPoint();
}


// 直线和交叉直线
DPoint xXLineLine(XLine c, Line l) {
  return DPoint(
    xLineLine(c.l1, l),
    xLineLine(c.l2, l),
  );
}

// 直线和平行直线
DPoint xHLineLine(HLine c, Line l) {
  return DPoint(
    xLineLine(c.l1, l),
    xLineLine(c.l2, l),
  );
}

// 直线和虚空
DPoint xWipkyyLine(Wipkyy c, Line l) {
  return DPoint.inf;
}
