import 'dart:math';
import '../Linear/Vector.dart';
import '../Linear/Line.dart';

import '../../../Algebra/Trunk/Fertile/DNum.dart';
import '../../../Algebra/Trunk/Fertile/QNum.dart';
import '../Fertile/DPoint.dart';
import '../Fertile/QPoint.dart';
import 'HLine.dart';
import 'XLine.dart';
//import 'Conic.dart';

// 这是双曲线类
// 数学方程 p + t*u + ( 1/t )*v
class Conic2 {
  Vector p;
  Vector u;
  Vector v;
  //conic2: p + t*u + ( 1/t )*v

  Conic2([Vector? p, Vector? u, Vector? v])
    : //中心，共轭方向1，共轭方向2
      p = p ?? Vector(),
      u = u ?? Vector(0, 1),
      v = v ?? Vector(1);

  factory Conic2.newPX(Vector P, XLine X) {
    //由一点及渐近线决定
    (num, num) rsv = P.rsv(X.u, X.v);
    num lamOrMu = sqrt(rsv.$1 * rsv.$2);
    return Conic2(X.p, X.u * lamOrMu, X.v * lamOrMu);
  }

  Vector indexPoint(num t) => p + u * t + v * (1 / t);
  DPoint indexDPoint(DNum theta) =>
      DPoint(indexPoint(theta.n1), indexPoint(theta.n2));
  QPoint indexQPoint(QNum theta) => QPoint(
    indexPoint(theta.n1),
    indexPoint(theta.n2),
    indexPoint(theta.n3),
    indexPoint(theta.n4),
  );

  Vector get vA => (u.unit + v.unit).unit; //实轴方向
  Vector get vB => (u.unit - v.unit).unit; //虚轴方向
  DNum get t0 {
    //顶点参数
    num t = pow(v.pow2 / u.pow2, 1 / 4);
    return DNum(t, -t);
  }

  DPoint get A => indexDPoint(t0); //两个顶点
  Vector get O => p; //中心
  num get halfAngTan {
    //半角正切
    num c2 = u.cos(v);
    return sqrt((1 - c2) / (1 + c2));
  }

  num get a => sqrt(2 * sqrt(u.pow2 * v.pow2) + 2 * u.dot(v));
  num get b => a * halfAngTan;
  num get c => sqrt(pow(a, 2) + pow(b, 2));
  num get e => sqrt(2 / (1 + u.cos(v))); //离心率

  DPoint get F => DPoint.newPV(p, vA * c); //焦点
  HLine get L {
    //准线
    num w = pow(a, 2) / c;
    return HLine(p + vA * w, p - vA * w, vB);
  }

  XLine get X => XLine(p, u, v); //渐近线
  XLine get asymptote => X;

  Vector der(t) => u + v * -pow(t, -2); //切方向
  Vector tangentVector(t) => der(t); //切方向
  Line tangentLine(t) => Line(indexPoint(t), der(t)); //切线

  num get ji => u.len * v.len; //积
  num get mJi => u.crossLen(v); //面积
  num get mian => mJi / ji; //面

  Conic2 get bro => Conic2(p, u, -v); //共轭双曲线

  Vector get pP => indexPoint(1); //正标
  Vector get nP => indexPoint(-1); //负标

  Vector get pV => u + v; //正-标共轭方向
  Vector get nV => u - v; //负-标共轭方向

  String get type => "Conic2";

  //Conic get conic => Conic().byConic2(this);

  // 计算点到双曲线的距离平方函数
  num disPow2P2thetaP(Vector P, num t) {
    return P.disPow2(indexPoint(t));
  }

  // 计算距离函数的导数
  num derDisP2thetaP(Vector P, num t) {
    Vector pointOnCurve = indexPoint(t);
    Vector derivative = u - v * (1 / (t * t));
    return 2 * (pointOnCurve - P).dot(derivative);
  }

  // 找到使点到双曲线距离最小的参数t
  num thetaClosestP(
    Vector P, {
    double tolerance = 1e-8,
    int maxIterations = 100,
  }) {
    // 处理特殊情况
    if (u.len < 1e-10 && v.len < 1e-10) {
      return 1.0; // 退化到中心点
    }
    // 双曲线有两支，需要在正负区间分别寻找
    List<num> positiveCandidates = _findCandidatesInInterval(P, 0.1, 1000, 10);
    List<num> negativeCandidates = _findCandidatesInInterval(
      P,
      -1000,
      -0.1,
      10,
    );
    // 合并所有候选点
    List<num> allCandidates = [...positiveCandidates, ...negativeCandidates];
    // 添加一些特殊候选点
    allCandidates.addAll([
      1.0, -1.0, // 标准点
      sqrt(v.len / u.len), -sqrt(v.len / u.len), // 顶点附近
    ]);
    // 为每个候选点进行优化
    num bestT = allCandidates[0];
    num minDistance = double.infinity;
    for (num candidate in allCandidates) {
      try {
        num optimizedT = _optimizeParameter(
          P,
          candidate,
          tolerance,
          maxIterations,
        );
        num distance = disPow2P2thetaP(P, optimizedT);
        if (distance < minDistance) {
          minDistance = distance;
          bestT = optimizedT;
        }
      } catch (e) {
        // 跳过优化失败的候选点
        continue;
      }
    }
    return bestT;
  }

  // 在指定区间内生成候选点
  List<num> _findCandidatesInInterval(Vector P, num start, num end, int count) {
    List<num> candidates = [];
    num step = (end - start) / (count - 1);
    for (int i = 0; i < count; i++) {
      num t = start + i * step;
      candidates.add(t);
    }
    return candidates;
  }

  // 使用牛顿法优化参数
  num _optimizeParameter(
    Vector P,
    num initialT,
    double tolerance,
    int maxIterations,
  ) {
    num t = initialT;
    for (int i = 0; i < maxIterations; i++) {
      // 避免接近奇点 t=0
      if (t.abs() < tolerance) {
        t = t.sign * tolerance;
      }
      num f = derDisP2thetaP(P, t);
      // 收敛检查
      if (f.abs() < tolerance) {
        break;
      }
      // 计算二阶导数（海森矩阵）
      Vector pointOnCurve = indexPoint(t);
      Vector firstDeriv = u - v * (1 / (t * t));
      Vector secondDeriv = v * (2 / (t * t * t));
      num fPrime = 2 * (firstDeriv.pow2 + (pointOnCurve - P).dot(secondDeriv));
      // 避免除零
      if (fPrime.abs() < tolerance) {
        break;
      }
      // 牛顿法更新
      num delta = f / fPrime;
      t -= delta;
      // 检查是否收敛
      if (delta.abs() < tolerance) {
        break;
      }
    }
    return t;
  }

  // 找到双曲线上距离给定点最近的点
  Vector closestP(Vector P) {
    num bestT = thetaClosestP(P);
    return indexPoint(bestT);
  }

  // 计算点到双曲线的最短距离
  num disP(Vector P) {
    Vector closest = closestP(P);
    return P.dis(closest);
  }

  // 通过最近点计算切线方向
  Vector tangentVectorByP(Vector P) {
    num t = thetaClosestP(P);
    return tangentVector(t);
  }

  XLine tangentLineByDP(DPoint dP) {
    return XLine.new2L(tangentLineByP(dP.p1), tangentLineByP(dP.p2));
  }

  // 通过最近点计算切线
  Line tangentLineByP(Vector P) {
    num t = thetaClosestP(P);
    return tangentLine(t);
  }

  @override
  String toString() {
    return 'Conic2(${p.toString()}, ${u.toString()}, ${v.toString()})';
  }
}
