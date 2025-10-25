import 'dart:math' as math;
import 'Line.dart';
import 'Vector.dart';

/// 线段类：由两个端点 [p1] 和 [p2] 定义的有限长度线段
/// 继承自 [Line] 类（直线），增加端点约束和线段特有操作
class Segment extends Line {
  Vector p1; // 起点
  Vector p2; // 终点

  /// 通过两个端点构造线段
  Segment(this.p1, this.p2) : super(p1, p2 - p1);

  /// 获取线段长度
  num get length => (p2 - p1).len;

  /// 重写父类方法：约束参数 λ ∈ [0, 1] 以确保点在线段上
  @override
  Vector indexPoint(num lam) {
    lam = lam.clamp(0.0, 1.0); // 限制参数范围
    return super.indexPoint(lam);
  }

  /// 判断点 [p0] 是否在线段上（包含端点）
  bool containsPoint(Vector p0, {num tolerance = 1e-10}) {
    // 1. 检查点是否在直线上
    if (disP(p0) > tolerance) return false;
    // 2. 检查投影参数 λ 是否在 [0,1] 范围内
    final v = p0 - p1;
    final lam = v.dot(v) / (v.dot(v) + v.dot(p2 - p1));
    return lam.clamp(0.0, 1.0) == lam;
  }

  /// 计算点到线段的最近距离（考虑端点）
  @override
  num disP(Vector p0) {
    final v = p2 - p1;
    final w = p0 - p1;
    final dot1 = w.dot(v);
    // 点在起点外侧
    if (dot1 <= 0) return w.len;
    // 点在终点外侧
    final dot2 = v.dot(v);
    if (dot1 >= dot2) return (p0 - p2).len;
    // 点在中间，返回垂直距离
    return super.disP(p0);
  }

  /// 获取线段中点
  Vector get midpoint => (p1 + p2) * 0.5;

  /// 判断两线段是否相交（不包含端点）
  bool intersects(Segment other, {num tolerance = 1e-10}) {
    // 快速排斥实验（AABB检测）
    if (math.max(p1.x, p2.x) < math.min(other.p1.x, other.p2.x) - tolerance ||
        math.min(p1.x, p2.x) > math.max(other.p1.x, other.p2.x) + tolerance ||
        math.max(p1.y, p2.y) < math.min(other.p1.y, other.p2.y) - tolerance ||
        math.min(p1.y, p2.y) > math.max(other.p1.y, other.p2.y) + tolerance) {
      return false;
    }
    // 跨立实验（叉积判断）
    final c1 = (p2 - p1).crossNum(other.p1 - p1);
    final c2 = (p2 - p1).crossNum(other.p2 - p1);
    final c3 = (other.p2 - other.p1).crossNum(p1 - other.p1);
    final c4 = (other.p2 - other.p1).crossNum(p2 - other.p1);
    return c1 * c2 < -tolerance && c3 * c4 < -tolerance;
  }

  /// 转为直线（去除端点约束）
  Line toLine() => Line(p1, p2 - p1);

  @override
  String toString() => 'Segment(p1: $p1, p2: $p2)';

  @override
  bool operator ==(Object other) =>
      other is Segment && p1 == other.p1 && p2 == other.p2;

  @override
  int get hash => Object.hash(p1, p2);

  @override
  int get hashCode {
    return Object.hash(p1.hashCode, p2.hashCode);
  }


}