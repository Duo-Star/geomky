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
  Conic0([Vector? p, Vector? u, Vector? v]): //中心，共轭方向1，共轭方向2
        p = p ?? Vector(),
        u = u ?? Vector(0,1),
        v = v ?? Vector(1);

  Vector indexPoint(num theta) => p + u * cos(theta) + v * sin(theta);
  DPoint indexDPoint(DNum theta) => DPoint(indexPoint(theta.n1), indexPoint(theta.n2));
  QPoint indexQPoint(QNum theta) => QPoint(
    indexPoint(theta.n1),
    indexPoint(theta.n2),
    indexPoint(theta.n3),
    indexPoint(theta.n4),
  );

  List<num> get ab { //计算长短轴(半)
    num a1 = u.pow2;
    num a2 = (u.dot(v))*2;
    num a3=v.pow2;
    num b1=0.5*(a1+a3);
    num b2=sqrt( pow(0.5*(a1-a3), 2) + pow(0.5*a2, 2) );
    num A=sqrt(b1+b2);
    num B=sqrt(b1-b2);
    return [A,B]; //非骈，有顺序
  }

  num get a => ab[0]; // 长半轴
  num get b => ab[1]; // 短半轴
  num get c => sqrt(pow(a,2)-pow(b,2));

  bool get isDegenerate {// 判断是否退化，如果u和v平行或其中一个为零向量，则曲线退化
    return u.crossLen(v) < 1e-10 || (u.len < 1e-10 && v.len < 1e-10);
  }

  num get h { //h 最直接的意义是衡量椭圆的扁平程度（扁率）。
    final a = ab[0];
    final b = ab[1];
    final numerator = pow(a - b, 2);
    final denominator = pow(a + b, 2);
    return numerator / denominator;
  }
  num get e { //e 离心率
    final a = ab[0];
    final b = ab[1];
    return sqrt(1 - pow(b / a, 2));
  }
  num get area { //面积
    return pi * ab[1] * ab[2];
  }
  num get cir { //周长
    return pi * (ab[1] + ab[2]) * (1 + (3 * h) / (10 + sqrt(4 - 3 * h)));
  }

  DNum get thetaA {
    num a1=u.pow2;
    num a2=(u.dot(v))*2;
    num a3=v.pow2;
    num b3=atan((a1-a3)/a2);
    return DNum(pi*( 1 +0.25)-b3/2, pi*( 2 +0.25)-b3/2);
  }

  DNum get thetaB {
    num a1=u.pow2;
    num a2=(u.dot(v))*2;
    num a3=v.pow2;
    num b3=atan((a1-a3)/a2);
    return DNum(pi*( 1 -0.25)-b3/2, pi*( 2 -0.25)-b3/2);
  }

  DPoint get A {
    return indexDPoint(thetaA);
  }

  DPoint get B {
    return indexDPoint(thetaB);
  }

  Vector get vA => (indexDPoint(thetaA).p1 - p).unit;
  Vector get vB => (indexDPoint(thetaB).p1 - p).unit;

  DPoint get F => DPoint.newPV(p, vA * c);

  Vector der(theta) => u * (-sin(theta)) + v * (cos(theta));

  Vector tangentVector(theta) => der(theta);

  Line tangentLine(theta){
    return Line(indexPoint(theta), tangentVector(theta));
  }

  num disP2P(Vector P, num theta){
    return P.dis(indexPoint(theta));
  }

  num derDisP2P(Vector P, num theta){
    num dx=2 * (-u.x*sin(theta) + v.x*cos(theta)) * (p.x + u.x*cos(theta) + v.x*sin(theta)-P.x);
    num dy=2 * (-u.y*sin(theta) + v.y*cos(theta)) * (p.y + u.y*cos(theta) + v.y*sin(theta)-P.y);
    return dx + dy ;
  }

  //
  num thetaClosestP2P(Vector P, {double tolerance = 1e-8, int maxIterations = 50}) {
    // 局部优化函数
    num optimizeFrom(num t0) {
      num t = t0;
      num k = -0.5; // 初始学习率
      num prevDistance = double.infinity;
      for (var i = 0; i < maxIterations; i++) {
        // 计算梯度（距离平方的导数）
        num gradient = derDisP2P(P, t);
        // 收敛检测
        if (gradient.abs() < tolerance) break;
        // 更新参数
        t += k * gradient;
        // 规范化角度到 [0, 2π)
        t = t % (2 * pi);
        if (t < 0) t += 2 * pi;
        // 计算当前距离
        num currentDistance = disP2P(P, t);
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
      num distance = disP2P(P, theta);
      if (distance < minDistance) {
        minDistance = distance;
        bestTheta = theta;
      }
    }
    return bestTheta;
  }

  Vector closestP(Vector P){
    return indexPoint(thetaClosestP2P(P));
  }

  num disP(Vector P){
    return P.dis(closestP(P));
  }

  Vector tangentVectorByP(Vector P) {
    return tangentVector(thetaClosestP2P(P));
  }

  Line tangentLineByP(Vector P) {
    return tangentLine(thetaClosestP2P(P));
  }

  XLine tangentLineByDP(DPoint dP) {
    return XLine.new2L(tangentLineByP(dP.p1), tangentLineByP(dP.p2));
  }


  //Conic get conic => Conic().byConic0(this);

  @override
  String toString() {
    return 'Conic0(${p.toString()}, ${u.toString()}, ${v.toString()})';
  }


//*/




/*
  (Vec, num) findClosestPoint(VectorP, {double tolerance = 1e-8}) {
    // 方法1：使用多个初始点确保找到全局最优
    final initialGuesses = [0.0, pi/2, pi, 3*pi/2];
    num bestTheta = 0.0;
    num bestDistance = double.infinity;

    for (final guess in initialGuesses) {
      final theta = _gradientDescent(P, guess, tolerance);
      final distance = disP2P(P, theta);

      if (distance < bestDistance) {
        bestTheta = theta;
        bestDistance = distance;
      }
    }

    return (indexPoint(bestTheta), bestTheta);
  }

  num _normalizeAngle(num theta) {
    // 将角度归一化到[-π, π]范围
    while (theta > pi) theta -= 2 * pi;
    while (theta < -pi) theta += 2 * pi;
    return theta;
  }

  num _gradientDescent(VectorP, num initialTheta, double tolerance) {
    var theta = initialTheta;
    var learningRate = 0.1;

    for (var i = 0; i < 100; i++) {
      final derivative = der_disP2P(P, theta);

      if (derivative.abs() < tolerance) {
        break;
      }

      // 自适应学习率
      theta -= learningRate * derivative;
      learningRate *= 0.95; // 缓慢衰减

      theta = _normalizeAngle(theta);
    }

    return theta;
  }

 */


}