//Vec
import 'dart:math' as math;
import 'dart:ui';

import 'Direction.dart';

class Vec3 {
  num x;
  num y;
  num z;

  Vec3([num x = 0.0, num y = 0.0, num z = 0.0]) : x = x, y = y, z = z;

  Vec3.newAL(Direction dir, num len)
      : x = math.cos(dir.theta) * math.cos(dir.phi) * len,
        y = math.sin(dir.theta) * math.cos(dir.phi) * len,
        z = math.sin(dir.phi) * len;

  Vec3.fromList(List ls)
      : x = ls[0] ?? 0.0,
        y = ls[1] ?? 0.0,
        z = (ls.length > 2) ? (ls[2] ?? 0.0) : 0.0;


  // 常量
  static Vec3 zero = Vec3();
  static Vec3 i = Vec3(1);
  static Vec3 j = Vec3(0,1);
  static Vec3 k = Vec3(0,0,1);
  static Vec3 inf = Vec3(1/0, 1/0, 1/0);
  static Vec3 nan = Vec3(0/0, 0/0, 0/0);

  Vec3 operator +(Vec3 other) => Vec3(x + other.x, y + other.y, z + other.z);
  Vec3 operator -(Vec3 other) => Vec3(x - other.x, y - other.y, z - other.z);
  Vec3 operator *(num scalar) => Vec3(x * scalar, y * scalar, z * scalar);
  Vec3 operator /(num scalar) => Vec3(x / scalar, y / scalar, z / scalar);
  Vec3 operator -() => Vec3(-x, -y, -z);
  num operator ^(num index) =>
      math.pow(x, index) + math.pow(y, index) + math.pow(z, index);

  Vec3 add(Vec3 other) => this + other;
  Vec3 sub(Vec3 other) => this - other;
  Vec3 scale(num scalar) => this * scalar;
  Vec3 div(num scalar) => this / scalar;
  num pow_(num index) => this ^ index;

  //### tips ###  this 可以省略
  //num cosAngle(Vec other)=> this.dot(other)/(this.len * other.len);
  num cosAngle(Vec3 other) => dot(other) / (len * other.len);
  Vec3 projectVec(Vec3 other) => other.unit * project(other);
  num project(Vec3 other) => dot(other) / (other.len);
  num dot(Vec3 other) => x * other.x + y * other.y + z * other.z;
  Vec3 mid(Vec3 other) => (this + other) * .5;
  num cos(Vec3 other) => dot(other) / len * other.len;
  num ang(Vec3 other) =>
      math.acos(cosAngle(other).clamp(-1.0, 1.0)); // 计算与另一个向量的夹角（弧度，范围 0 到 π）

  Vec3 tp(Vec3 p, Vec3 u, Vec3 v, Vec3 n) => p + u * x + v * y + n * z;
  Vec3 tp2d(Vec3 p, Vec3 u, Vec3 v) => p + u * x + v * y;

  Vec3 roll(Vec3 n, num w) =>
      scale(math.cos(w)) +
          (n.cross(this)).scale(math.sin(w)) +
          n.scale((n.dot(this)) * (1 - math.cos(w)));

  Vec3 roll2d(num w) => roll(Vec3.k, w);
  Vec3 roll2d_90() => Vec3(-y, x, 0.0);
  Vec3 roll2dAround(Vec3 p, num w) => p + (this - p).roll2d(w);

  Vec3 get floor => Vec3(x.floor(), y.floor(), z.floor());
  Vec3 get negate => -this;
  Vec3 get ops => negate;
  num get pow2 => this ^ 2;
  num get len => math.sqrt(x * x + y * y + z * z);
  Vec3 get unit => len > 0 ? this / len : Vec3.zero;
  Offset get offset {
    if (x.isNaN || y.isNaN) {
      return Offset(1/0, 1/0);
    }
    return Offset(x.toDouble(), y.toDouble());
  }

  (num, num) RSV(Vec3 a, Vec3 b) {
    Vec3 p = this;
    num dotPA = p.dot(a);
    num dotPB = p.dot(b);
    num dotAB = a.dot(b);
    num aPow2 = a.pow2;
    num bPow2 = b.pow2;
    num lam =
        (bPow2 * dotPA - dotPB * dotAB) / (aPow2 * bPow2 - math.pow(dotAB, 2));
    num mu =
        (aPow2 * dotPB - dotPA * dotAB) / (aPow2 * bPow2 - math.pow(dotAB, 2));
    return (lam, mu);
  }

  Vec3 cross(Vec3 other) => Vec3(
    y * other.z - z * other.y,
    z * other.x - x * other.z,
    x * other.y - y * other.x,
  );

  num dis(Vec3 other) => (this - other).len;

  Vec3 angB(Vec3 other) => (unit + other.unit);

  @override
  String toString() => 'Vec($x, $y, $z)';

  @override
  bool operator ==(Object other) =>
      other is Vec3 && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);
}
