import 'dart:math';

import '../../../Algebra/Trunk/Fertile/DNum.dart';
import '../../../Algebra/Trunk/Fertile/QNum.dart';
import '../Fertile/DPoint.dart';
import '../Fertile/QPoint.dart';
import 'HLine.dart';
import 'XLine.dart';

import '../Linear/Vector.dart';
import '../Linear/Line.dart';

/*
#Conic0 封闭形圆锥曲线
当前位置 MathForest.Geo.Conic.Conic0
#1: Conic0是由方程 p + cos(θ)*u + sin(θ)*v
    所确定的曲线，这里的p,u,v都是向量，θ是参数
    从形状上 不仅有椭圆,圆，还有点,线段类型，
    从位置上 不仅可以在原点处产生，还可以进行任意的平移和旋转，脱离2d平面
    向量p叫位置参数，向量u和向量v叫形状参数
    当u和为平行时(要求模长不同时为零)，则产生一条线段
    当u和v垂直时，分为模相等和模不等
                相等时 产生圆
                不相等时 产生以u和v为长轴和短轴的椭圆
    当u和v模长同时为零时 产生一个点
    当他们的模长不同时为零，且既不平行也不垂直的时候 产生一般的斜椭圆
#2: 在正投影与透视投影变换中类型不变，仍然为Conic0
#3: 创建方法如下
    Conic0() / Conic0(Vector(),Vector(2,1),Vector(1,2))
    也可以使用其他以new作为开头的方法进行创建
    比如 使用两焦点和椭圆上一点建立平面椭圆
         Conic0.newEllipse2dBy3P(F1,F2,P)
    等等
 */

class Conic0 {
  Vector p;
  Vector u;
  Vector v;

  String get type => "Conic0";
  //conic0: p + cos(θ)*u + sin(θ)*v
  Conic0([Vector? p, Vector? u, Vector? v])
    : //中心，共轭方向1，共轭方向2
      p = p ?? Vector(),
      u = u ?? Vector(0, 1),
      v = v ?? Vector(1);

  //索引点
  Vector indexPoint(num theta) => p + u * cos(theta) + v * sin(theta);
  //索引骈点
  DPoint indexDPoint(DNum theta) =>
      DPoint(indexPoint(theta.n1), indexPoint(theta.n2));
  //合点
  QPoint indexQPoint(QNum theta) => QPoint(
    indexPoint(theta.n1),
    indexPoint(theta.n2),
    indexPoint(theta.n3),
    indexPoint(theta.n4),
  );
  //计算
  Map<String, num> get ab {
    //计算长短轴(半)
    num a1 = u.pow2;
    num a2 = (u.dot(v)) * 2;
    num a3 = v.pow2;
    num b1 = 0.5 * (a1 + a3);
    num b2 = sqrt(pow(0.5 * (a1 - a3), 2) + pow(0.5 * a2, 2));
    num A = sqrt(b1 + b2);
    num B = sqrt(b1 - b2);
    //return [A, B]; //非骈，有顺序
    return {"a": A, "b": B};
  }

  //
  num get a => ab['a']??0; // 长半轴
  num get b => ab['b']??0; // 短半轴
  num get c => sqrt(pow(a, 2) - pow(b, 2));
  //
  bool get isDegenerate {
    // 判断是否退化，如果u和v平行或其中一个为零向量，则曲线退化
    return u.crossLen(v) < 1e-10 || (u.len < 1e-10 && v.len < 1e-10);
  }

  //
  num get h {
    //h 最直接的意义是衡量椭圆的扁平程度（扁率）。
    final numerator = pow(a - b, 2);
    final denominator = pow(a + b, 2);
    return numerator / denominator;
  }

  //
  num get e {
    //e 离心率
    return sqrt(1 - pow(b / a, 2));
  }

  //面积
  num get area {
    return pi * a * b;
  }

  //周长
  num get cir {
    return pi * (a + b) * (1 + (3 * h) / (10 + sqrt(4 - 3 * h)));
  }

  //长轴参数
  DNum get thetaA {
    num a1 = u.pow2;
    num a2 = (u.dot(v)) * 2;
    num a3 = v.pow2;
    num b3 = atan2(a1 - a3, a2);
    return DNum(pi * (1 + 0.25) - b3 / 2, pi * (2 + 0.25) - b3 / 2);
  }

  //短轴参数
  DNum get thetaB {
    num a1 = u.pow2;
    num a2 = (u.dot(v)) * 2;
    num a3 = v.pow2;
    num b3 = atan2(a1 - a3, a2);
    return DNum(pi * (1 - 0.25) - b3 / 2, pi * (2 - 0.25) - b3 / 2);
  }

  //长轴端点
  DPoint get A {
    return indexDPoint(thetaA);
  }

  //短轴端点
  DPoint get B {
    return indexDPoint(thetaB);
  }

  //长轴，短轴单位方向
  Vector get vA => (indexDPoint(thetaA).p1 - p).unit;
  Vector get vB => (indexDPoint(thetaB).p1 - p).unit;

  // 计算焦点
  DPoint get F => DPoint.newPV(p, vA * c);
  //切方向
  Vector der(theta) => u * (-sin(theta)) + v * (cos(theta));
  //切方向
  Vector tangentVector(theta) => der(theta);
  //切线
  Line tangentLine(theta) {
    return Line(indexPoint(theta), tangentVector(theta));
  }

  //
  num disPow2P2thetaP(Vector P, num theta) {
    return P.disPow2(indexPoint(theta));
  }

  //
  num derDisP2thetaP(Vector P, num theta) {
    num dx =
        2 *
        (-u.x * sin(theta) + v.x * cos(theta)) *
        (p.x + u.x * cos(theta) + v.x * sin(theta) - P.x);
    num dy =
        2 *
        (-u.y * sin(theta) + v.y * cos(theta)) *
        (p.y + u.y * cos(theta) + v.y * sin(theta) - P.y);
    return dx + dy;
  }

  //
  num thetaClosestP(
    Vector P, {
    double tolerance = 1e-8,
    int maxIterations = 50,
  }) {
    // 局部优化函数
    num optimizeFrom(num t0) {
      num t = t0;
      num k = -0.5; // 初始学习率
      num prevDistance = double.infinity;
      for (var i = 0; i < maxIterations; i++) {
        // 计算梯度（距离平方的导数）
        num gradient = derDisP2thetaP(P, t);
        // 收敛检测
        if (gradient.abs() < tolerance) break;
        // 更新参数
        t += k * gradient;
        // 规范化角度到 [0, 2π)
        t = t % (2 * pi);
        if (t < 0) t += 2 * pi;
        // 计算当前距离
        num currentDistance = disPow2P2thetaP(P, t);
        // 检查距离变化
        if ((prevDistance - currentDistance).abs() < tolerance) break;
        prevDistance = currentDistance;
        // 衰减学习率
        k *= 0.85; // 每次衰减15%
      }
      return t;
    }

    // 初始点：覆盖一个周期 [0, 2π)
    List<num> initialThetas = [];
    for (int i = 0; i < 12; i++) {
      initialThetas.add(i * pi / 6); // 每30°一个点
    }
    // 优化每个初始点并找到最佳结果
    num bestTheta = initialThetas[0];
    num minDistance = double.infinity;
    for (num t0 in initialThetas) {
      num theta = optimizeFrom(t0);
      num distance = disPow2P2thetaP(P, theta);
      if (distance < minDistance) {
        minDistance = distance;
        bestTheta = theta;
      }
    }
    return bestTheta;
  }

  // 找到椭圆上距离给定点最近的点
  Vector closestP(Vector P) {
    return indexPoint(thetaClosestP(P));
  }

  // 计算点到椭圆的最短距离
  num disP(Vector P) {
    return P.dis(closestP(P));
  }

  Vector tangentVectorByP(Vector P) {
    return tangentVector(thetaClosestP(P));
  }

  Line tangentLineByP(Vector P) {
    return tangentLine(thetaClosestP(P));
  }

  XLine tangentLineByDP(DPoint dP) {
    return XLine.new2L(tangentLineByP(dP.p1), tangentLineByP(dP.p2));
  }

  //Conic get conic => Conic().byConic0(this);

  @override
  String toString() {
    return 'Conic0(${p.toString()}, ${u.toString()}, ${v.toString()})';
  }
}
