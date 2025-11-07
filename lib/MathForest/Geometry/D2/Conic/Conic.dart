import 'dart:math';

//
import 'Conic0.dart';
//
import '../../../Algebra/Trunk/Fertile/DNum.dart';
import '../../../Algebra/Trunk/Fertile/QNum.dart';
import '../Fertile/DPoint.dart';
import '../Fertile/QPoint.dart';
import 'HLine.dart';
import 'XLine.dart';

import '../Linear/Vector.dart';
import '../Linear/Line.dart';

/*
#Conic 二元二次方程表示的圆锥曲线
当前位置 MathForest/Geometry/D2/Conic/Conic
#1: Conic由一般二元二次方程表示：Ax² + Bxy + Cy² + Dx + Ey + F = 0
#2: 支持椭圆、双曲线、抛物线、退化情况（点、直线等）
#3: 提供从Conic0（参数形式）到Conic（隐式形式）的转换
 */

class Conic {
  // 二元二次方程系数：Ax² + Bxy + Cy² + Dx + Ey + F = 0
  num A;
  num B;
  num C;
  num D;
  num E;
  num F;

  /// 获取曲线类型标识
  String get type => "Conic";

  /// 构造函数：通过系数创建圆锥曲线
  Conic(this.A, this.B, this.C, this.D, this.E, this.F);

  /// 从Conic0转换到Conic
  /// [conic0] 参数形式的圆锥曲线
  factory Conic.fromConic0(Conic0 conic0) {
    // 获取参数方程的向量分量
    Vector p = conic0.p;
    Vector u = conic0.u;
    Vector v = conic0.v;
    // 参数方程：x = p.x + u.x*cosθ + v.x*sinθ
    //          y = p.y + u.y*cosθ + v.y*sinθ
    // 为了消去参数θ，我们需要将方程转换为隐式形式
    // 通过消去cosθ和sinθ，得到关于x,y的二次方程
    // 令 X = x - p.x, Y = y - p.y
    // 则方程组为：u.x*cosθ + v.x*sinθ = X
    //            u.y*cosθ + v.y*sinθ = Y
    // 写成矩阵形式：M * [cosθ, sinθ]ᵀ = [X, Y]ᵀ
    // 其中 M = [[u.x, v.x],
    //           [u.y, v.y]]
    // 如果M可逆，则 [cosθ, sinθ]ᵀ = M⁻¹ * [X, Y]ᵀ
    // 再利用恒等式 cos²θ + sin²θ = 1 得到二次方程
    num ux = u.x, uy = u.y;
    num vx = v.x, vy = v.y;
    num px = p.x, py = p.y;
    // 计算矩阵M的行列式
    num detM = ux * vy - uy * vx;
    if (detM.abs() < 1e-10) {
      // 退化情况：u和v平行或其中一个为零向量
      // 此时曲线退化为点或线段，需要特殊处理
      if (u.len < 1e-10 && v.len < 1e-10) {
        // 退化为点：p点
        // 方程形式为 (x-px)² + (y-py)² = 0
        return Conic(1, 0, 1, -2 * px, -2 * py, px * px + py * py);
      } else {
        // 退化为线段，这里简化为直线处理
        // 使用u和v中较长的向量作为方向
        Vector dir = u.len > v.len ? u : v;
        if (dir.len < 1e-10) dir = u.lenPow2 > v.lenPow2 ? u : v;
        // 直线方程：通过点p，方向为dir
        // 直线法向量为dir的垂直向量
        Vector normal = Vector(-dir.y, dir.x);
        num a = normal.x, b = normal.y;
        num c = -(a * px + b * py);
        // 对于直线，我们使用A=B=C=0的特殊形式，或者使用二次退化形式
        // 这里使用 (ax + by + c)² = 0
        return Conic(a * a, 2 * a * b, b * b, 2 * a * c, 2 * b * c, c * c);
      }
    }
    // 一般情况：计算M的逆矩阵（除以行列式）
    num invDet = 1 / detM;
    num m11 = vy * invDet; // 逆矩阵第一行第一列
    num m12 = -vx * invDet; // 逆矩阵第一行第二列
    num m21 = -uy * invDet; // 逆矩阵第二行第一列
    num m22 = ux * invDet; // 逆矩阵第二行第二列
    // 计算变换后的坐标：X = x - px, Y = y - py
    // [cosθ, sinθ]ᵀ = M⁻¹ * [X, Y]ᵀ
    // 即：cosθ = m11*X + m12*Y
    //     sinθ = m21*X + m22*Y
    // 代入恒等式 cos²θ + sin²θ = 1
    // (m11*X + m12*Y)² + (m21*X + m22*Y)² = 1
    // 展开得到二次型：
    // (m11² + m21²)X² + 2(m11*m12 + m21*m22)XY + (m12² + m22²)Y² = 1
    num a11 = m11 * m11 + m21 * m21;
    num a12 = m11 * m12 + m21 * m22;
    num a22 = m12 * m12 + m22 * m22;
    // 方程：a11*X² + 2*a12*X*Y + a22*Y² = 1
    // 即：a11*X² + 2*a12*X*Y + a22*Y² - 1 = 0
    // 将X = x - px, Y = y - py代入并展开
    num x_0 = px, y_0 = py;
    // 展开后的系数：
    num A = a11;
    num B = 2 * a12;
    num C = a22;
    num D = -2 * (a11 * x_0 + a12 * y_0);
    num E = -2 * (a12 * x_0 + a22 * y_0);
    num F = a11 * x_0 * x_0 + 2 * a12 * x_0 * y_0 + a22 * y_0 * y_0 - 1;
    return Conic(A, B, C, D, E, F);
  }

  /// 判断圆锥曲线类型
  String get conicType {
    // 计算判别式
    num discriminant = B * B - 4 * A * C;
    if (discriminant.abs() < 1e-10) {
      return "抛物线";
    } else if (discriminant < 0) {
      return "椭圆";
    } else {
      return "双曲线";
    }
  }

  /// 判断是否退化
  bool get isDegenerate {
    // 计算矩阵的行列式
    num det =
        A * (C * F - E * E / 4) -
        B * (B * F / 4 - D * E / 4) +
        D * (B * E / 4 - C * D / 4);
    return det.abs() < 1e-10;
  }

  /// 计算离心率（仅对非退化圆锥曲线有效）
  num get eccentricity {
    String type = conicType;
    if (type == "椭圆") {
      // 对于椭圆：e = √(1 - b²/a²)
      // 需要先计算长短轴
      Map<String, num> axes = semiAxes;
      num a = axes['a'] ?? 0;
      num b = axes['b'] ?? 0;
      return sqrt(1 - (b * b) / (a * a));
    } else if (type == "双曲线") {
      // 对于双曲线：e = √(1 + b²/a²)
      Map<String, num> axes = semiAxes;
      num a = axes['a'] ?? 0;
      num b = axes['b'] ?? 0;
      return sqrt(1 + (b * b) / (a * a));
    } else if (type == "抛物线") {
      return 1;
    }
    return 0;
  }

  /// 计算半轴长度
  Map<String, num> get semiAxes {
    // 旋转角度消除交叉项
    num theta = 0.5 * atan2(B, A - C);
    // 旋转后的系数
    num aPrime =
        A * cos(theta) * cos(theta) +
        B * cos(theta) * sin(theta) +
        C * sin(theta) * sin(theta);
    num cPrime =
        A * sin(theta) * sin(theta) -
        B * cos(theta) * sin(theta) +
        C * cos(theta) * cos(theta);
    // 平移消除一次项（简化计算）
    // 这里假设已经平移到了中心
    if (conicType == "椭圆") {
      num a = 1 / sqrt(aPrime.abs());
      num b = 1 / sqrt(cPrime.abs());
      return {'a': max(a, b), 'b': min(a, b)};
    } else if (conicType == "双曲线") {
      num a = 1 / sqrt(aPrime.abs());
      num b = 1 / sqrt(cPrime.abs());
      return {'a': a, 'b': b};
    }
    return {'a': 0, 'b': 0};
  }

  /// 判断点是否在圆锥曲线上（考虑误差）
  bool containsPoint(Vector point, {double tolerance = 1e-8}) {
    num x = point.x, y = point.y;
    num value = A * x * x + B * x * y + C * y * y + D * x + E * y + F;
    return value.abs() < tolerance;
  }

  /// 获取中心点（对于有中心的圆锥曲线）
  Vector get center {
    // 解线性方程组求中心
    // ∂F/∂x = 2Ax + By + D = 0
    // ∂F/∂y = Bx + 2Cy + E = 0
    num det = 4 * A * C - B * B;
    if (det.abs() < 1e-10) {
      // 抛物线或无中心情况
      return Vector.zero;
    }
    num x = (B * E - 2 * C * D) / det;
    num y = (B * D - 2 * A * E) / det;
    return Vector(x, y);
  }

  @override
  String toString() {
    List<String> terms = [];
    if (A.abs() > 1e-10) terms.add("${A.toStringAsFixed(4)}x²");
    if (B.abs() > 1e-10) terms.add("${B.toStringAsFixed(4)}xy");
    if (C.abs() > 1e-10) terms.add("${C.toStringAsFixed(4)}y²");
    if (D.abs() > 1e-10) terms.add("${D.toStringAsFixed(4)}x");
    if (E.abs() > 1e-10) terms.add("${E.toStringAsFixed(4)}y");
    if (F.abs() > 1e-10) terms.add(F.toStringAsFixed(4));
    if (terms.isEmpty) return "0 = 0";
    String equation = "${terms.join(" + ").replaceAll("+ -", "- ")} = 0";
    return "Conic($equation)";
  }

  /// 转换为标准形式字符串
  String toStandardString() {
    return "$A x² + $B xy + $C y² + $D x + $E y + $F = 0";
  }
}
