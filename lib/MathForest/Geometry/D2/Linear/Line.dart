// Line - 平面直线类

import 'dart:math' as math ;
import 'Vector.dart';
import '../../../Algebra/Trunk/Fertile/DNum.dart';
import '../../../Algebra/Trunk/Fertile/QNum.dart';
import '../Fertile/DPoint.dart';
import '../Fertile/QPoint.dart';
/*
为保证广泛性，我们使用 p + lam * v 代替 k * x + b
，另外 我不喜欢 Ax + By +C =0
其实兼容三维
 */


class Line {
  final Vector p;
  final Vector v;
  // line: p + lam * v

  // 默认创建方法
  Line([Vector? p, Vector? v]): p = p ?? Vector(), v = v ?? Vector(1);

  // 从两点创建
  static new2P(Vector p1, Vector p2) => Line(p1, p2-p1);

  // 索引点
  Vector indexPoint(num lam) => p + v * lam;
  DPoint indexDPoint(DNum theta) => DPoint(indexPoint(theta.n1), indexPoint(theta.n2));
  QPoint indexQPoint(QNum theta) => QPoint(
    indexPoint(theta.n1),
    indexPoint(theta.n2),
    indexPoint(theta.n3),
    indexPoint(theta.n4),
  );

  // 判定平行，注意我们不规避重合！
  bool isParallel (Line other) {
    return v.isParallel(other.v);
  }

  // 判定垂直
  bool isVertical (Line other) {
    return v.isVertical (other.v);
  }

  Vector operator [](num index) {
    return indexPoint(index);
  }

  // 字符化
  @override
  String toString() => 'Line(p:${p.toString()}, v:${v.toString()})';

  //类型
  String get type => "Line";

  // 哈希值
  int get hash => Object.hash(p.x,p.y,v.x,v.y);
}