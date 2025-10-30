//Vector
/*
走进箭头世界，感受几何之美
二维向量，如果你在寻找三维向量，请转至 Vector3
 */

import 'dart:math' as math;
import 'dart:ui'; // we need Offset in ui
import '../../../Algebra/Functions/Main.dart' as funcs;
import '../../D3/Linear/Vec3.dart';

class Vector {
  num x = 0.0;
  num y = 0.0;

  // 默认从坐标创建
  Vector([this.x = .0, this.y = .0]);

  // 从极坐标创建
  Vector.newAL(num theta, num l) :
        x = math.cos(theta)  * l,
        y = math.sin(theta)  * l;

  // 常量
  static Vector zero = Vector();
  static Vector i = Vector(1);
  static Vector j = Vector(0,1);
  static Vector inf = Vector(1/0, 1/0);
  static Vector nan = Vector(0/0, 0/0);

  //运算符重载
  Vector operator +(Vector other) => Vector(x + other.x, y + other.y);
  Vector operator -(Vector other) => Vector(x - other.x, y - other.y);
  Vector operator *(num scalar) => Vector(x * scalar, y * scalar);
  Vector operator /(num scalar) => Vector(x / scalar, y / scalar);
  Vector operator -() => Vector(-x, -y);
  num operator ^(num index) => math.pow(x, index) + math.pow(y, index);

  //如果你不想用运算符
  Vector add(Vector other) => this + other;
  Vector sub(Vector other) => this - other;
  Vector scale(num scalar) => this * scalar;
  Vector div(num scalar) => this / scalar;
  num power(num index) => this ^ index;

  /*
  ### tips ###
  我刚开始学dart，这是我的第一个类
  this 可以省略
   */

  // 点积 除以 模积
  num cos(Vector other) => dot(other) / (len * other.len);

  // 投影向量
  Vector projectVec(Vector other) => other.unit * project(other);

  // 投影
  num project(Vector other) => dot(other) / (other.len);

  // 点积
  num dot(Vector other) => x * other.x + y * other.y;

  // 中点
  Vector mid(Vector other) => (this + other) * .5;

  // 计算与另一个向量的夹角（弧度，范围 0 到 π）
  num ang(Vector other) => math.acos(cos(other).clamp(-1.0, 1.0));

  // 虚拟坐标系
  Vector tp(Vector p, Vector u, Vector v, Vector n) => p + u * x + v * y;

  // 逆旋转90
  Vector roll90() => Vector(-y, x);

  // 顺旋转90
  Vector roll270() => Vector(y, -x);

  //叉积模长
  num crossLen(Vector other) => funcs.abs(x * other.y - y * other.x);

  //叉积数值
  num crossNum(Vector other) => (x * other.y - y * other.x);

  // 复制一份
  Vector copy() => Vector(x, y);
  Vector clone() => copy();

  // 向下取整
  Vector get floor => Vector(x.floor(), y.floor());

  // 反
  Vector get negate => -this;
  Vector get ops => negate;

  // 平方
  num get pow2 => this ^ 2;

  // 模
  num get len => math.sqrt(x * x + y * y);

  num get lenPow2 => x * x + y * y;

  Vec3 get vec3 => Vec3(x, y, 0.0);

  // 计算单位向量
  Vector get unit => len > 0 ? this / len : Vector.zero;

  // 转为offset
  Offset get offset {
    if (x.isNaN || y.isNaN) { return Offset(1/0, 1/0); }
    return Offset(x.toDouble(), y.toDouble());
  }

  // 分解函数，大名鼎鼎的RSV
  (num, num) rsv(Vector a, Vector b) {
    Vector p = this;
    num dotPA = p.dot(a);
    num dotPB = p.dot(b);
    num dotAB = a.dot(b);
    num aPow2 = a.pow2;
    num bPow2 = b.pow2;
    num lam = (bPow2 * dotPA - dotPB * dotAB) / (aPow2 * bPow2 - math.pow(dotAB, 2));
    num mu = (aPow2 * dotPB - dotPA * dotAB) / (aPow2 * bPow2 - math.pow(dotAB, 2));
    return (lam, mu);
  }

  // 距离
  num dis(Vector other) => (this - other).len;

  //
  num disPow2(Vector other) => (this - other).pow2;

  // 角分向量
  Vector angB(Vector other) => (unit + other.unit);

  //
  bool isVertical(Vector other) {
    return dot(other) == 0.0;
  }

  //
  bool isParallel(Vector other) {
    return crossLen(other) == 0.0;
  }


  // 判定相等
  @override
  bool operator ==(Object other) => other is Vector && x == other.x && y == other.y;

  // 字符化
  @override
  String toString() => 'Vector($x, $y)';

  //类型
  String get type => "Vec2";

  // 哈希值
  int get hash => Object.hash(x, y);
}
