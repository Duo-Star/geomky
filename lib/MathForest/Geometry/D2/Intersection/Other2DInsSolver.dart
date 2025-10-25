library;

import 'dart:math' as math;
import '../Linear/Line.dart';
// conic
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



DNum xCircleCircleTheta(Circle c1, Circle c2) {
  DNum theta = trigonometric_solver.solveCosSinForMainRoot(
    2 * c2.p.x * c2.r - 2 * c1.p.x * c2.r,
    2 * c2.p.y * c2.r - 2 * c1.p.y * c2.r,
    math.pow(c1.p.x - c2.p.x, 2) +
        math.pow(c1.p.y - c2.p.y, 2) +
        c2.r * c2.r -
        c1.r * c1.r,
  );
  return theta; //注意这里获取的theta是c2的
}

DPoint xCircleCircle(Circle c1, Circle c2) {
  DNum theta = xCircleCircleTheta(c1, c2);
  return c2.indexDPoint(theta);
}