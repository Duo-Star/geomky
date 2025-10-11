//Triangle - 平面三角形

/*
最简单的图形 - 三角形 - 组成单元！
我们提供了三角形属性计算
  -四心，面积，周长，形状
 */

import 'dart:math';
import 'Vector.dart';

class Triangle {
  Vector a;
  Vector b;
  Vector c;

  // 三个点创建
  Triangle([Vector? a, Vector? b, Vector? c])
    : a = a ?? Vector.zero,
      b = b ?? Vector.i,
      c = c ?? Vector.j;

  // 相对向量
  Vector get u => a - c;
  Vector get v => b - c;

  // 辅助
  num get dotUV => u.dot(v);
  num get powU => u.pow2;
  num get powV => v.pow2;

  // 边长
  num get aLen => (b - c).len; // 边a的长度
  num get bLen => (a - c).len; // 边b的长度
  num get cLen => (a - b).len; // 边c的长度

  // 面积
  get area => u.crossLen(v) / 2;

  // 周长
  get cir => aLen + bLen + cLen;

  // 内心
  Vector get iO {
    return (a * aLen + b * bLen + c * cLen) / cir;
  }

  // 外心
  Vector get oO {
    num m = 2 * (pow(dotUV, 2) - powV * powU);
    num uL = (powV * (dotUV - powU)) / m;
    num vL = (powU * (dotUV - powV)) / m;
    return c + u * uL + v * vL;
  }

  // 垂心
  Vector get hO {
    num m = pow(dotUV, 2) - powV * powU;
    num uL = (dotUV * (dotUV - powV)) / m;
    num vL = (dotUV * (dotUV - powU)) / m;
    return c + u * uL + v * vL;
  }

  // 重心
  Vector get gO {
    return (a + b + c) * (1 / 3);
  }

  //
  bool isPInside(Vector p) {
    return false;
  }

  //
  bool get isRight {
    return false;
  }

  //
  bool get isObtuse {
    return false;
  }

  //
  bool get isAcute {
    return false;
  }

  // 字符化
  @override
  String toString() =>
      'Triangle(a:${a.toString()}, b:${b.toString()}, c:${c.toString()})';

  //类型
  String get type => "Vec2";

  // 哈希值
  int get hash => Object.hash(a.x, a.y, b.x, b.y, c.x, c.y);
}
