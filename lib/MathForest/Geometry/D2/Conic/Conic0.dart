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
#Conic0 封闭形圆锥曲线 - 椭圆超集
当前位置 MathForest/Geometry/D2/Conic/Conic0
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
  Vector p;  // 中心位置向量
  Vector u;  // 形状参数向量1（对应cos分量）
  Vector v;  // 形状参数向量2（对应sin分量）

  /// 获取曲线类型标识
  String get type => "Conic0";

  /// 构造函数：创建圆锥曲线 p + cos(θ)*u + sin(θ)*v
  /// [p] 中心位置向量，默认为原点
  /// [u] 形状参数向量1，默认为(0,1)
  /// [v] 形状参数向量2，默认为(1,0)
  Conic0([Vector? p, Vector? u, Vector? v])
      : p = p ?? Vector(),
        u = u ?? Vector(0, 1),
        v = v ?? Vector(1);

  /// 根据参数θ获取曲线上的点
  /// [theta] 参数角度（弧度）
  /// 返回 参数对应的曲线点
  Vector indexPoint(num theta) => p + u * cos(theta) + v * sin(theta);

  /// 根据骈数参数获取曲线上的骈点
  /// [theta] 骈数参数，包含两个角度值
  /// 返回 包含两个对应点的骈点对象
  DPoint indexDPoint(DNum theta) =>
      DPoint(indexPoint(theta.n1), indexPoint(theta.n2));

  /// 根据四元数参数获取曲线上的四点组
  /// [theta] 四元数参数，包含四个角度值
  /// 返回 包含四个对应点的四元点对象
  QPoint indexQPoint(QNum theta) => QPoint(
    indexPoint(theta.n1),
    indexPoint(theta.n2),
    indexPoint(theta.n3),
    indexPoint(theta.n4),
  );

  /// 计算椭圆的长短半轴长度
  /// 返回 包含长半轴a和短半轴b的映射
  Map<String, num> get ab {
    // 计算二次型系数
    num a1 = u.pow2;        // u的平方模
    num a2 = (u.dot(v)) * 2; // u和v点积的2倍
    num a3 = v.pow2;        // v的平方模

    // 计算特征值相关量
    num b1 = 0.5 * (a1 + a3);  // 平均值
    num b2 = sqrt(pow(0.5 * (a1 - a3), 2) + pow(0.5 * a2, 2)); // 差值

    // 计算长短半轴（特征值的平方根）
    num A = sqrt(b1 + b2);
    num B = sqrt(b1 - b2);

    return {"a": A, "b": B};
  }

  /// 获取长半轴长度
  num get a => ab['a']??0;

  /// 获取短半轴长度
  num get b => ab['b']??0;

  /// 获取焦距（椭圆焦点到中心的距离）
  num get c => sqrt(pow(a, 2) - pow(b, 2));

  /// 判断曲线是否退化（退化为点或线段）
  /// 返回 true如果u和v平行或其中一个为零向量
  bool get isDegenerate {
    return u.crossLen(v) < 1e-10 || (u.len < 1e-10 && v.len < 1e-10);
  }

  /// 获取椭圆形状参数h（衡量扁平程度）
  /// h = (a-b)²/(a+b)²，值越大越扁平
  num get h {
    final numerator = pow(a - b, 2);
    final denominator = pow(a + b, 2);
    return numerator / denominator;
  }

  /// 获取椭圆离心率
  /// e = √(1 - (b/a)²)，0≤e<1
  num get e {
    return sqrt(1 - pow(b / a, 2));
  }

  /// 计算椭圆面积
  num get area {
    return pi * a * b;
  }

  /// 计算椭圆周长近似值（使用Ramanujan近似公式）
  num get cir {
    return pi * (a + b) * (1 + (3 * h) / (10 + sqrt(4 - 3 * h)));
  }

  /// 获取长轴方向的参数角度（骈数，两个可能方向）
  DNum get thetaA {
    num a1 = u.pow2;
    num a2 = (u.dot(v)) * 2;
    num a3 = v.pow2;
    num b3 = atan2(a1 - a3, a2);  // 计算主轴方向角
    return DNum(pi * (1 + 0.25) - b3 / 2, pi * (2 + 0.25) - b3 / 2);
  }

  /// 获取短轴方向的参数角度（骈数，两个可能方向）
  DNum get thetaB {
    num a1 = u.pow2;
    num a2 = (u.dot(v)) * 2;
    num a3 = v.pow2;
    num b3 = atan2(a1 - a3, a2);  // 计算副轴方向角
    return DNum(pi * (1 - 0.25) - b3 / 2, pi * (2 - 0.25) - b3 / 2);
  }

  /// 获取长轴端点（骈点，两个端点）
  DPoint get A {
    return indexDPoint(thetaA);
  }

  /// 获取短轴端点（骈点，两个端点）
  DPoint get B {
    return indexDPoint(thetaB);
  }

  /// 获取长轴方向的单位向量
  Vector get vA => (indexDPoint(thetaA).p1 - p).unit;

  /// 获取短轴方向的单位向量
  Vector get vB => (indexDPoint(thetaB).p1 - p).unit;

  /// 获取焦点位置（骈点，两个焦点）
  DPoint get F => DPoint.newPV(p, vA * c);

  /// 计算曲线在参数θ处的导数（切向量）
  /// [theta] 参数角度
  /// 返回 切向量
  Vector der(theta) => u * (-sin(theta)) + v * (cos(theta));

  /// 获取曲线在参数θ处的切向量（同der方法）
  Vector tangentVector(theta) => der(theta);

  /// 获取曲线在参数θ处的切线
  /// [theta] 参数角度
  /// 返回 切线对象
  Line tangentLine(theta) {
    return Line(indexPoint(theta), tangentVector(theta));
  }

  /// 计算点P到参数θ对应点的距离平方
  /// [P] 目标点
  /// [theta] 参数角度
  /// 返回 距离平方值
  num disPow2P2thetaP(Vector P, num theta) {
    return P.disPow2(indexPoint(theta));
  }

  /// 计算距离平方函数关于θ的导数
  /// 用于优化查找最近点
  /// [P] 目标点
  /// [theta] 参数角度
  /// 返回 导数值
  num derDisP2thetaP(Vector P, num theta) {
    // 对x分量求导
    num dx = 2 * (-u.x * sin(theta) + v.x * cos(theta)) *
        (p.x + u.x * cos(theta) + v.x * sin(theta) - P.x);
    // 对y分量求导
    num dy = 2 * (-u.y * sin(theta) + v.y * cos(theta)) *
        (p.y + u.y * cos(theta) + v.y * sin(theta) - P.y);
    return dx + dy;
  }

  /// 使用梯度下降法找到曲线上距离点P最近的参数θ
  /// [P] 目标点
  /// [tolerance] 收敛容差
  /// [maxIterations] 最大迭代次数
  /// 返回 最优参数θ
  num thetaClosestP(Vector P, {double tolerance = 1e-8, int maxIterations = 50}) {
    // 局部优化函数：从初始点t0开始优化
    num optimizeFrom(num t0) {
      num t = t0;
      num k = -0.5; // 初始学习率（负号因为梯度下降）
      num prevDistance = double.infinity;

      for (var i = 0; i < maxIterations; i++) {
        // 计算梯度（距离平方的导数）
        num gradient = derDisP2thetaP(P, t);

        // 收敛检测：梯度足够小
        if (gradient.abs() < tolerance) break;

        // 更新参数：梯度下降
        t += k * gradient;

        // 规范化角度到 [0, 2π)
        t = t % (2 * pi);
        if (t < 0) t += 2 * pi;

        // 计算当前距离
        num currentDistance = disPow2P2thetaP(P, t);

        // 检查距离变化是否足够小
        if ((prevDistance - currentDistance).abs() < tolerance) break;
        prevDistance = currentDistance;

        // 衰减学习率
        k *= 0.85; // 每次衰减15%
      }
      return t;
    }

    // 初始点采样：覆盖一个周期 [0, 2π)，每30°一个点
    List<num> initialThetas = [];
    for (int i = 0; i < 12; i++) {
      initialThetas.add(i * pi / 6);
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

  /// 找到椭圆上距离给定点P最近的点
  /// [P] 目标点
  /// 返回 曲线上最近的点
  Vector closestP(Vector P) {
    return indexPoint(thetaClosestP(P));
  }

  /// 计算点P到椭圆的最短距离
  /// [P] 目标点
  /// 返回 最短距离
  num disP(Vector P) {
    return P.dis(closestP(P));
  }

  /// 获取点P对应的最近点处的切向量
  /// [P] 目标点
  /// 返回 切向量
  Vector tangentVectorByP(Vector P) {
    return tangentVector(thetaClosestP(P));
  }

  /// 获取点P对应的最近点处的切线
  /// [P] 目标点
  /// 返回 切线对象
  Line tangentLineByP(Vector P) {
    return tangentLine(thetaClosestP(P));
  }

  /// 获取骈点dP对应的切线（交叉线）
  /// [dP] 目标骈点
  /// 返回 交叉线对象
  XLine tangentLineByDP(DPoint dP) {
    return XLine.new2L(tangentLineByP(dP.p1), tangentLineByP(dP.p2));
  }

  //Conic get conic => Conic().byConic0(this);

  @override
  String toString() {
    return 'Conic0(${p.toString()}, ${u.toString()}, ${v.toString()})';
  }
}