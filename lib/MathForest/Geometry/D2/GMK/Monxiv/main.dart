import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../Core/GMKData.dart';

import '../../Fertile/DPoint.dart';
import '../../Fertile/QPoint.dart';

import '../../Conic/Circle.dart';
import '../../Conic/Conic0.dart';
import '../../Conic/Conic1.dart';
import '../../Conic/Conic2.dart';
import '../../Conic/XLine.dart';
import '../../Conic/HLine.dart';
import '../../Conic/Wipkyy.dart';

import '../../Linear/Vector.dart';
import '../../Linear/Line.dart';
import '../../Linear/Dots.dart';
import '../../Linear/Polygon.dart';

class Monxiv {
  Vector p = Vector();
  num lam = 10;
  bool infoMode = false;
  Vector size = Vector();

  // 用于处理手势
  Offset _startLocalPosition = Offset.zero;
  Vector _startMonxivP = Vector();
  double _startMonxivLam = 1.0;
  bool _isDragging = false;
  List<num> monxivLamRestriction = [5, 1e3];

  //
  num get xStart => -p.x / lam;
  num get xEnd => (size.x - p.x) / lam;
  num get yStart => -(size.y - p.y) / lam;
  num get yEnd => p.y / lam;

  void setSize(Size size_) {
    size = Vector(size_.width, size_.height);
  }

  Paint defaultPaint = Paint()
    ..color = Colors.amber
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;
  Paint defaultQPointPaint = Paint()
    ..color = Colors.blueAccent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;
  Paint defaultPointPaint = Paint()
    ..color = Colors.redAccent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;
  Paint defaultLinePaint = Paint()
    ..color = Colors.green
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;
  Paint axisPaint = Paint()
    ..color = Color.fromARGB(180, 0, 0, 0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
  Paint gridPaint = Paint()
    ..color = Color.fromARGB(80, 0, 0, 0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  Color bgc = Color.fromARGB(200, 230, 230, 230);
  Color axisLabelColor = Colors.black54;

  Vector c2s(Vector c) {
    return Vector(c.x * lam + p.x, -c.y * lam + p.y);
  }

  Vector s2c(Vector s) {
    return Vector((s.x - p.x) / lam, -(s.y - p.y) / lam);
  }

  void reset([Vector? v]) {
    p = v ?? Vector(150, 150);
    lam = 100;
  }

  // 处理缩放开始
  void handleScaleStart(ScaleStartDetails details) {
    //print('开始移动');
    _isDragging = true;
    _startLocalPosition = details.localFocalPoint;
    _startMonxivP = Vector(p.x, p.y); // 保存当前平移状态
    _startMonxivLam = lam.toDouble(); // 保存当前缩放状态
  }

  // 处理缩放更新（同时处理平移和缩放）
  void handleScaleUpdate(ScaleUpdateDetails details) {
    //print('handleScaleUpdate');
    if (details.scale != 1.0) {
      // 缩放操作
      double newScale = _startMonxivLam * details.scale;
      // 限制缩放范围
      lam = newScale.clamp(monxivLamRestriction[0], monxivLamRestriction[1]);
    } else if (details.localFocalPoint != _startLocalPosition) {
      // 平移操作（没有缩放，只有位置变化）
      Offset delta = details.localFocalPoint - _startLocalPosition;
      p = Vector(_startMonxivP.x + delta.dx, _startMonxivP.y + delta.dy);
    }
  }

  // 处理缩放结束
  void handleScaleEnd(ScaleEndDetails details) {
    _isDragging = false;
  }

  // 处理滚轮缩放
  void handlePointerSignal(PointerSignalEvent event) {
    //print('滚轮缩放');
    if (event is PointerScrollEvent) {
      double zoomFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
      double newScale = lam * zoomFactor;
      lam = newScale.clamp(monxivLamRestriction[0], monxivLamRestriction[1]);
    }
  }

  // 双击重置视图
  void handleDoubleTap() {
    reset();
    p = Vector(400, 400); // 重置到初始位置
    lam = 100; // 重置到初始缩放
  }

  void onTap() {}

  void onTapDown(TapDownDetails details) {
    // 获取点击坐标
    Offset globalPosition = details.globalPosition; // 全局坐标
    Vector tapSP = Vector(globalPosition.dx, globalPosition.dy);
    Vector tapCP = s2c(tapSP);

    //print(tapCP.toString());
  }

  bool drawText(
    String str,
    Vector p,
    double fontSize,
    double width,
    Canvas canvas, {
    Color? color,
  }) {
    ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
      ),
    );
    builder.pushStyle(ui.TextStyle(
      color: color?? Color.fromARGB(200,0,0,0)
    ));
    builder.addText(str);
    final ui.Paragraph paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: width));
    canvas.drawParagraph(paragraph, (c2s(p)).offset);
    return true;
  }

  bool drawPoint(Vector p, Canvas canvas, {Paint? paint}) {
    final Paint usedPaint = paint ?? defaultPointPaint;
    canvas.drawCircle(c2s(p).offset, 3, usedPaint);
    if (infoMode) {
      drawText(p.toString(), p, 12, 500.0, canvas);
    }
    return true;
  }

  bool drawDPoint(DPoint dP, Canvas canvas, {Paint? paint}) {
    drawPoint(dP.p1, canvas);
    drawPoint(dP.p2, canvas);
    return true;
  }

  bool drawQPoint(QPoint qP, Canvas canvas, {Paint? paint}) {
    drawPoint(qP.p1, canvas, paint: defaultQPointPaint);
    drawPoint(qP.p2, canvas, paint: defaultQPointPaint);
    drawPoint(qP.p3, canvas, paint: defaultQPointPaint);
    drawPoint(qP.p4, canvas, paint: defaultQPointPaint);
    return true;
  }

  bool drawDots(Dots ds, Canvas canvas, {Paint? paint}) {
    List<Vector> dots = ds.dots;
    final Paint usedPaint = paint ?? defaultPaint;
    for (int i = 0; i < dots.length; i++) {
      Vector item = dots[i];
      drawPoint(item, canvas, paint: usedPaint);
    }
    return true;
  }

  bool drawPolygon(Polygon poly, Canvas canvas, {Paint? paint}) {
    final vertices = poly.vertices;
    if (vertices.isEmpty) return false; // 空多边形不绘制

    final usedPaint =
        paint ??
              Paint() // 提供默认Paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = Colors.black;

    final path = Path();

    // 移动到第一个点
    Vector v1 = c2s(vertices[0]);
    path.moveTo(v1.x.toDouble(), v1.y.toDouble());

    // 连接所有顶点
    for (int i = 1; i < vertices.length; i++) {
      Vector vi = c2s(vertices[i]);
      path.lineTo(vi.x.toDouble(), vi.y.toDouble());
    }

    // 闭合路径（连接最后一个点回第一个点）
    path.close();

    canvas.drawPath(path, usedPaint);
    return true;
  }

  bool drawCircle(Circle circle, Canvas canvas, {Paint? paint}) {
    final Paint usedPaint = paint ?? defaultPaint;
    canvas.drawCircle(
      c2s(circle.p).offset,
      (circle.r * lam).toDouble(),
      usedPaint,
    );
    if (infoMode) {
      drawText(circle.toString(), circle.p, 12, 500, canvas);
    }
    return true;
  }

  bool drawLine(Line l, Canvas canvas, {Paint? paint}) {
    final Paint usedPaint = paint ?? defaultLinePaint;
    num long = 114514 / lam;
    Offset p1 = c2s(l.indexPoint(-long)).offset;
    Offset p2 = c2s(l.indexPoint(long)).offset;
    canvas.drawLine(p1, p2, usedPaint);
    if (infoMode) {
      drawText(l.toString(), l.p, 12, 500, canvas);
    }
    return true;
  }

  bool drawSegmentBy2P(Vector p1_, Vector p2_, Canvas canvas, {Paint? paint}) {
    final Paint usedPaint = paint ?? defaultPaint;
    Offset p1 = c2s(p1_).offset;
    Offset p2 = c2s(p2_).offset;
    canvas.drawLine(p1, p2, usedPaint);
    if (infoMode) {
      drawText(
        'SegmentBy2P : ${p1_.toString()}-${p2_.toString()}',
        p1_,
        12,
        500,
        canvas,
      );
    }
    return true;
  }

  bool drawConic0(Conic0 c0, Canvas canvas, {Paint? paint}) {
    final Paint usedPaint = paint ?? defaultPaint;
    Path p = Path();
    Vector initVector = c2s(c0.indexPoint(0));
    p.moveTo(initVector.x.toDouble(), initVector.y.toDouble());
    for (double theta = 0.1; theta <= 2 * pi; theta += 0.1) {
      Vector nowVector = c2s(c0.indexPoint(theta));
      p.lineTo(nowVector.x.toDouble(), nowVector.y.toDouble());
    }
    p.close();
    canvas.drawPath(p, usedPaint);
    if (infoMode) {
      drawText(c0.toString(), c0.p, 12, 500, canvas);
    }
    return true;
  }

  bool drawConic2(Conic2 c2, Canvas canvas, {Paint? paint}) {
    final Paint usedPaint = paint ?? defaultPaint;
    num dt = 0.1;
    Path p1 = Path();
    Vector initVec1 = c2s(c2.indexPoint(-(pow(e, dt) - 1) * .3));
    p1.moveTo(initVec1.x.toDouble(), initVec1.y.toDouble());
    for (num t = dt * .1; t <= 380 / lam + 5; t += dt) {
      Vector nowVector = c2s(c2.indexPoint(-(pow(e, t) - 1) * .3));
      p1.lineTo(nowVector.x.toDouble(), nowVector.y.toDouble());
    }
    canvas.drawPath(p1, usedPaint);

    Path p2 = Path();
    Vector initVec2 = c2s(c2.indexPoint(dt));
    p2.moveTo(initVec2.x.toDouble(), initVec2.y.toDouble());
    for (num t = dt; t <= 380 / lam + 5; t += dt) {
      Vector nowVector = c2s(c2.indexPoint((pow(e, t) - 1) * .3));
      p2.lineTo(nowVector.x.toDouble(), nowVector.y.toDouble());
    }
    canvas.drawPath(p2, usedPaint);
    return true;
  }

  /*
  bool drawConic(Conic co, Canvas canvas, {Paint? paint}) {
    if (co.type=="Conic0"){
      drawConic0(co.reveal,canvas);
    } else if (co.type=="Conic1") {
      //drawConic1(co.reveal,canvas);
    } else if (co.type=="Conic2") {
      drawConic2(co.reveal,canvas);
    } else if (co.type=="XLine") {
      //drawXLine(co.reveal,canvas);
    } else if (co.type=="HLine") {
      //drawHLine(co.reveal,canvas);
    }
    return true;
  }

   */

  bool drawGMKData(GMKData gmkData, canvas) {
    //drawText('drawGMKData - error', c2s(Vector(10,10)), 12, 500, canvas);
    if (gmkData.count != 0) {
      for (var key in gmkData.data.keys) {
        switch (gmkData.data[key]?.type) {
          case const ("Vector"):
            Vector p = gmkData.data[key]?.obj;
            drawPoint(p, canvas);
            drawText('Point: $key', p, 12, 500, canvas);
          case const ("DPoint"):
            DPoint dp = gmkData.data[key]?.obj;
            drawDPoint(dp, canvas);
          case const ("QPoint"):
            QPoint qp = gmkData.data[key]?.obj;
            drawQPoint(qp, canvas);
            //drawText('Point: $key', qp.p1, 12, 500, canvas);
          case const ("num"):
            Vector p = Vector(gmkData.data[key]?.obj);
            drawPoint(p, canvas);
            drawText('N: $key', p, 12, 500, canvas);
          case const ("Circle"):
            Circle circle = gmkData.data[key]?.obj;
            drawCircle(circle, canvas);
            drawText('Circle: $key', circle.p, 12, 500, canvas);
          case const ("Line"):
            Line l = gmkData.data[key]?.obj;
            drawLine(l, canvas);
            drawText('Circle: $key', l.p, 12, 500, canvas);

          default:
            // drawText('error: $key', Vector(0, 0), 12, 500, canvas);
        }
      }
    }
    return true;
  }

  bool drawFramework(Canvas canvas) {
    canvas.drawColor(bgc, BlendMode.srcOver);
    drawSegmentBy2P(
      Vector(xStart, 0),
      Vector(xEnd, 0),
      canvas,
      paint: axisPaint,
    );
    drawSegmentBy2P(
      Vector(0, yStart),
      Vector(0, yEnd),
      canvas,
      paint: axisPaint,
    );

    int drawX = xStart.floor() - 1;
    if (drawX < 1) drawX = 1;
    int drawX_ = xEnd.floor() + 1;
    if (drawX_ > 100) drawX_ = 100;

    int drawY = yStart.floor() - 1;
    if (drawY < 1) drawY = 1;
    int drawY_ = yEnd.floor() + 1;
    if (drawY_ > 100) drawY_ = 100;

    for (int x = xStart.floor(); x <= xEnd; x++) {
      drawPoint(Vector(x), canvas, paint: axisPaint);
      drawText("$x", Vector(x) + Vector(-0.1, -0.1), 12, 500, canvas, color: axisLabelColor);
      drawSegmentBy2P(
        Vector(x, yEnd),
        Vector(x, yStart),
        canvas,
        paint: gridPaint,
      );
    }

    for (int y = yStart.floor(); y <= yEnd; y++) {
      drawPoint(Vector(0, y), canvas, paint: axisPaint);
      drawText("$y", Vector(0, y) + Vector(-0.1, -0.1), 12, 500, canvas, color: axisLabelColor);
      drawSegmentBy2P(
        Vector(xStart, y),
        Vector(xEnd, y),
        canvas,
        paint: gridPaint,
      );
    }

    return true;
  }
}
