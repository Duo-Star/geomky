import 'Vector.dart';
import 'Segment.dart'; // 需要之前实现的 Segment 类

class Polygon {
  List<Vector> vertices;

  Polygon(this.vertices) {
    if (vertices.length < 3) {
      throw ArgumentError("多边形必须至少有3个顶点");
    }
  }

  /// 计算点 [p] 到多边形所有边的最短距离
  num disP(Vector p) {
    num minDistance = double.infinity;
    for (int i = 0; i < vertices.length; i++) {
      final v1 = vertices[i];
      final v2 = vertices[(i + 1) % vertices.length]; // 循环连接最后一个点到第一个点
      final segment = Segment(v1, v2);
      num distance = segment.disP(p);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    return minDistance;
  }

  /// 判断点是否在多边形内部（Ray Casting 算法）
  bool containsPoint(Vector p) {
    int crossings = 0;
    final n = vertices.length;

    for (int i = 0; i < n; i++) {
      final v1 = vertices[i];
      final v2 = vertices[(i + 1) % n];
      // 检查点是否在顶点上
      if (p == v1 || p == v2) return true;
      // 检查水平射线与边的交点
      if ((v1.y > p.y) != (v2.y > p.y)) {
        final xIntersect = (p.y - v1.y) * (v2.x - v1.x) / (v2.y - v1.y) + v1.x;
        if (p.x <= xIntersect) {
          crossings++;
        }
      }
    }
    return crossings % 2 == 1;
  }

  /// 计算点到多边形的最短距离（包括内部和边）
  num distanceToPolygon(Vector p) {
    if (containsPoint(p)) {
      return 0.0; // 点在多边形内部
    }
    return disP(p); // 点到边的最短距离
  }
}