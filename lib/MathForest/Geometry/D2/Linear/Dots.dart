import 'dart:math';

import 'Vector.dart';
import 'Polygon.dart';
import 'Enclosure.dart';

import '../../../Statistics/RandomMaster.dart';

class Dots {
  List<Vector> dots = [];

  Dots(this.dots);

  Vector get center {
    Vector sum = Vector();
    for (int i = 0; i < dots.length; i++) {
      sum += dots[i];
    }
    return sum.scale(1 / dots.length);
  }

  Vector indexPoint(int n) {
    return dots[n - 1];
  }

  bool removePoint(Vector p) {
    dots.remove(p);
    return true;
  }

  bool clear() {
    dots.clear();
    return true;
  }

  bool add(Vector p) {
    dots.add(p);
    return true;
  }

  bool contains(Vector p) {
    dots.contains(p);
    return true;
  }

  /// 计算点集的轴对齐最小包围盒 Enclosure
  /// 返回 (minX, maxX, minY, maxY)
  Enclosure get enclosure {
    if (dots.isEmpty) {
      throw StateError("点集为空，无法计算包围盒");
    }
    num minX = double.infinity;
    num maxX = -double.infinity;
    num minY = double.infinity;
    num maxY = -double.infinity;
    for (final point in dots) {
      minX = point.x < minX ? point.x : minX;
      maxX = point.x > maxX ? point.x : maxX;
      minY = point.y < minY ? point.y : minY;
      maxY = point.y > maxY ? point.y : maxY;
    }
    return Enclosure(Vector(minX, minY), Vector(maxX, maxY));
  }

  Vector findNearest(Vector point) {
    if (dots.isEmpty) throw StateError("点集为空，无法计算最近邻");
    Vector nearest = dots.first;
    num minDist = (point-nearest).lenPow2;
    for (final current in dots.skip(1)) {
      final dist =  (point-current).lenPow2;
      if (dist < minDist) {
        minDist = dist;
        nearest = current;
      }
    }
    return nearest;
  }


  num get density {
    if (dots.length < 2) return 0.0;
    Enclosure myEnclosure = enclosure;
    final area = myEnclosure.area ;
    return area > 0 ? dots.length / area : double.infinity;
  }


  List<Vector> get farthestPair {
    if (dots.length < 2) throw StateError("至少需要2个点");
    // 计算凸包
    final convexHull = tight.vertices;
    if (convexHull.length == 2) return convexHull; // 仅两个点时直接返回
    // 旋转卡壳算法找最远点对
    int a = 0, b = 1;
    num maxDist = (convexHull[a] - convexHull[b]).lenPow2;
    for (int i = 0; i < convexHull.length; i++) {
      final nextI = (i + 1) % convexHull.length;
      while (true) {
        int nextB = (b + 1) % convexHull.length;
        num dist = (convexHull[nextI] - convexHull[i]).crossNum(
          convexHull[nextB] - convexHull[b],
        );
        if (dist <= 0) break; // 不再增加距离
        b = nextB;
      }
      num currentDist = (convexHull[i] - convexHull[b]).lenPow2;
      if (currentDist > maxDist) {
        maxDist = currentDist;
        a = i;
      }
    }
    return [convexHull[a], convexHull[b]];
  }

  Polygon get tight {
    // 处理点数不足的情况
    if (dots.isEmpty) return Polygon([]);
    if (dots.length == 1) return Polygon([dots[0]]);
    if (dots.length == 2) return Polygon([dots[0], dots[1]]);
    // 按坐标排序点集，先x后y
    List<Vector> sorted = List.from(dots)
      ..sort((a, b) => a.x != b.x ? a.x.compareTo(b.x) : a.y.compareTo(b.y));
    // 构建上凸包
    List<Vector> upper = [];
    for (int i = 0; i < sorted.length; i++) {
      Vector c = sorted[i];
      while (upper.length >= 2) {
        Vector a = upper[upper.length - 2];
        Vector b = upper[upper.length - 1];
        // 叉积 AB × BC
        num cross = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
        if (cross <= 0) {
          // 右转或共线，移除凹点
          upper.removeLast();
        } else {
          break;
        }
      }
      upper.add(c);
    }
    // 构建下凸包
    List<Vector> lower = [];
    for (int i = sorted.length - 1; i >= 0; i--) {
      Vector c = sorted[i];
      while (lower.length >= 2) {
        Vector a = lower[lower.length - 2];
        Vector b = lower[lower.length - 1];
        // 叉积 AB × BC
        num cross = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
        if (cross <= 0) {
          // 右转或共线，移除凹点
          lower.removeLast();
        } else {
          break;
        }
      }
      lower.add(c);
    }
    // 合并凸包，移除重复端点，注意，lower[0] 和 lower.last 分别与 upper 的端点重复
    List<Vector> hull = List.from(upper)
      ..addAll(lower.sublist(1, lower.length - 1));
    return Polygon(hull);
  }

  static Dots randomUniform(int num) {
    final random = Random(0);
    List<Vector> dots = [];
    for (int i = 0; i < num; i++) {
      dots.add(Vector(random.nextDouble() * 10, random.nextDouble() * 10));
    }
    return Dots(dots);
  }

  static Dots randomFill(int num, RandomMaster rmx, RandomMaster rmy) {
    List<Vector> dots = [];
    for (int i = 0; i < num; i++) {
      dots.add(Vector(rmx.compute(), rmy.compute()));
    }
    return Dots(dots);
  }
}
