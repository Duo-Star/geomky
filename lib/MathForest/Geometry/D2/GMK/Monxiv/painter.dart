library;

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

//
import '../../../../Algebra/Functions/Main.dart' as funcs;

//
import 'GraphOBJ.dart';
import 'main.dart';
//
import '../Core/GMKData.dart';
import '../Core/GMKStructure.dart';

//
import '../../Fertile/DPoint.dart';
import '../../Fertile/QPoint.dart';
//
import '../../Conic/Circle.dart';
import '../../Conic/Conic0.dart';
import '../../Conic/Conic1.dart';
import '../../Conic/Conic2.dart';
import '../../Conic/XLine.dart';
import '../../Conic/HLine.dart';
import '../../Conic/Wipkyy.dart';

//
import '../../Linear/Vector.dart';
import '../../Linear/Line.dart';
import '../../Linear/Dots.dart';
import '../../Linear/Polygon.dart';

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
  ..style = PaintingStyle.fill
  ..strokeWidth = 2.0;

Paint gridPaint = Paint()
  ..color = Color.fromARGB(60, 0, 0, 0)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.5;

void drawText(
  String str,
  Vector p,
  double fontSize,
  double width,
  Monxiv monxiv, {
  Color? color,
}) {
  ui.ParagraphBuilder builder = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
    ),
  );
  builder.pushStyle(ui.TextStyle(color: color ?? Color.fromARGB(200, 0, 0, 0)));
  builder.addText(str);
  final ui.Paragraph paragraph = builder.build();
  paragraph.layout(ui.ParagraphConstraints(width: width));
  monxiv.canvas.drawParagraph(paragraph, (monxiv.c2s(p)).offset);
}

void drawPoint(Vector p, Monxiv monxiv, {Paint? paint, double? size}) {
  final Paint usedPaint = paint ?? defaultPointPaint;
  monxiv.canvas.drawCircle(monxiv.c2s(p).offset, size ?? 3.5, usedPaint);
}

bool drawFramework(Monxiv monxiv) {
  num xStart = monxiv.xStart;
  num xEnd = monxiv.xEnd;
  num yStart = monxiv.yStart;
  num yEnd = monxiv.yEnd;
  monxiv.canvas.drawColor(monxiv.bgc, BlendMode.srcOver);
  drawSegmentBy2P(Vector(xStart, 0), Vector(xEnd, 0), monxiv, paint: axisPaint);
  drawSegmentBy2P(Vector(0, yStart), Vector(0, yEnd), monxiv, paint: axisPaint);
  int drawX = xStart.floor() - 1;
  if (drawX < 1) drawX = 1;
  int drawX_ = xEnd.floor() + 1;
  if (drawX_ > 100) drawX_ = 100;
  int drawY = yStart.floor() - 1;
  if (drawY < 1) drawY = 1;
  int drawY_ = yEnd.floor() + 1;
  if (drawY_ > 100) drawY_ = 100;
  for (int x = xStart.floor(); x <= xEnd; x++) {
    drawPoint(Vector(x), monxiv, paint: axisPaint, size: 3.0);
    drawText(
      "$x",
      Vector(x) + Vector(-0.1, -0.1),
      12,
      500,
      monxiv,
      color: monxiv.axisLabelColor,
    );
    drawSegmentBy2P(
      Vector(x, yEnd),
      Vector(x, yStart),
      monxiv,
      paint: gridPaint,
    );
  }
  for (int y = yStart.floor(); y <= yEnd; y++) {
    drawPoint(Vector(0, y), monxiv, paint: axisPaint);
    drawText(
      "$y",
      Vector(0, y) + Vector(-0.1, -0.1),
      12,
      500,
      monxiv,
      color: monxiv.axisLabelColor,
    );
    drawSegmentBy2P(
      Vector(xStart, y),
      Vector(xEnd, y),
      monxiv,
      paint: gridPaint,
    );
  }
  return true;
}

void drawDPoint(DPoint dP, Monxiv monxiv, {Paint? paint,double? size}) {
  drawPoint(dP.p1, monxiv, paint: paint, size: size ?? 3.5);
  drawPoint(dP.p2, monxiv, paint: paint, size: size ?? 3.5);
}

void drawQPoint(QPoint qP, Monxiv monxiv, {Paint? paint}) {
  drawPoint(qP.p1, monxiv, paint: paint??defaultQPointPaint);
  drawPoint(qP.p2, monxiv, paint: paint??defaultQPointPaint);
  drawPoint(qP.p3, monxiv, paint: paint??defaultQPointPaint);
  drawPoint(qP.p4, monxiv, paint: paint??defaultQPointPaint);
}

void drawDots(Dots ds, Monxiv monxiv, {Paint? paint}) {
  List<Vector> dots = ds.dots;
  final Paint usedPaint = paint ?? defaultPaint;
  for (int i = 0; i < dots.length; i++) {
    Vector item = dots[i];
    drawPoint(item, monxiv, paint: usedPaint);
  }
}

void drawPolygon(Polygon poly, Monxiv monxiv, {Paint? paint}) {
  final vertices = poly.vertices;
  if (vertices.isEmpty) return;
  final usedPaint = paint ?? defaultPaint;
  final path = Path();
  Vector v1 = monxiv.c2s(vertices[0]);
  path.moveTo(v1.x.toDouble(), v1.y.toDouble());
  for (int i = 1; i < vertices.length; i++) {
    Vector vi = monxiv.c2s(vertices[i]);
    path.lineTo(vi.x.toDouble(), vi.y.toDouble());
  }
  path.close();
  monxiv.canvas.drawPath(path, usedPaint);
}

void drawCircle(Circle circle, Monxiv monxiv, {Paint? paint}) {
  final Paint usedPaint = paint ?? defaultPaint;
  monxiv.canvas.drawCircle(
    monxiv.c2s(circle.p).offset,
    (circle.r * monxiv.lam).toDouble(),
    usedPaint,
  );
}

void drawLine(Line l, Monxiv monxiv, {Paint? paint}) {
  final Paint usedPaint = paint ?? defaultLinePaint;
  num long = 114514 / monxiv.lam;
  Offset p1 = monxiv.c2s(l.indexPoint(-long)).offset;
  Offset p2 = monxiv.c2s(l.indexPoint(long)).offset;
  monxiv.canvas.drawLine(p1, p2, usedPaint);
  if (monxiv.infoMode) {
    drawText(l.toString(), l.p, 12, 500, monxiv);
  }
}

void drawSegmentBy2P(Vector p1_, Vector p2_, Monxiv monxiv, {Paint? paint}) {
  final Paint usedPaint = paint ?? defaultPaint;
  Offset p1 = monxiv.c2s(p1_).offset;
  Offset p2 = monxiv.c2s(p2_).offset;
  monxiv.canvas.drawLine(p1, p2, usedPaint);
}

void drawConic0(Conic0 c0, Monxiv monxiv, {Paint? paint}) {
  final Paint usedPaint = paint ?? defaultPaint;
  Path p = Path();
  Vector initVector = monxiv.c2s(c0.indexPoint(0));
  p.moveTo(initVector.x.toDouble(), initVector.y.toDouble());
  for (double theta = 0.1; theta <= 2 * pi; theta += 0.1) {
    Vector nowVector = monxiv.c2s(c0.indexPoint(theta));
    p.lineTo(nowVector.x.toDouble(), nowVector.y.toDouble());
  }
  p.close();
  monxiv.canvas.drawPath(p, usedPaint);
}

void drawConic1(Conic1 c1, Monxiv monxiv, {Paint? paint}) {
  final Paint usedPaint = paint ?? defaultPaint;
  Path p = Path();
  Vector initVector = monxiv.c2s(c1.indexPoint(0));
  p.moveTo(initVector.x.toDouble(), initVector.y.toDouble());
  for (double theta = -10; theta <= 10; theta += 0.1) {
    Vector nowVector = monxiv.c2s(c1.indexPoint(theta));
    p.lineTo(nowVector.x.toDouble(), nowVector.y.toDouble());
  }
  p.close();
  monxiv.canvas.drawPath(p, usedPaint);
}

void drawConic2(Conic2 c2, Monxiv monxiv, {Paint? paint}) {
  final Paint usedPaint = paint ?? defaultPaint;
  num dt = 0.1;
  Path p1 = Path();
  Vector initVec1 = monxiv.c2s(c2.indexPoint(-(pow(e, dt) - 1) * .3));
  p1.moveTo(initVec1.x.toDouble(), initVec1.y.toDouble());
  for (num t = dt * .1; t <= 380 / monxiv.lam + 5; t += dt) {
    Vector nowVector = monxiv.c2s(c2.indexPoint(-(pow(e, t) - 1) * .3));
    p1.lineTo(nowVector.x.toDouble(), nowVector.y.toDouble());
  }
  monxiv.canvas.drawPath(p1, usedPaint);
  Path p2 = Path();
  Vector initVec2 = monxiv.c2s(c2.indexPoint(dt));
  p2.moveTo(initVec2.x.toDouble(), initVec2.y.toDouble());
  for (num t = dt; t <= 380 / monxiv.lam + 5; t += dt) {
    Vector nowVector = monxiv.c2s(c2.indexPoint((pow(e, t) - 1) * .3));
    p2.lineTo(nowVector.x.toDouble(), nowVector.y.toDouble());
  }
  monxiv.canvas.drawPath(p2, usedPaint);
}

void drawT2PFunction(Function f, Monxiv monxiv, {Paint? paint, num? from, num? to, num? dt}) {
  final Paint usedPaint = paint ?? defaultPaint;
  Path p = Path();
  Vector initVector = monxiv.c2s(f(0));
  p.moveTo(initVector.x.toDouble(), initVector.y.toDouble());
  for (num theta = (from??0); theta <= (to??5.0); theta += (dt??0.1)) {
    Vector nowVector = monxiv.c2s(f(theta));
    p.lineTo(nowVector.x.toDouble(), nowVector.y.toDouble());
  }
  //p.close();
  monxiv.canvas.drawPath(p, usedPaint);
}



void drawDottedLine(Line l, Monxiv monxiv, {Paint? paint}) {
  final Paint usedPaint = paint ?? defaultLinePaint;
  if (monxiv.lam>30) {
    for (num t = -30; t <= 31; t += 1/monxiv.lam) {
      Vector p = l.p + l.v.unit * t;
      drawPoint(p, monxiv, paint: usedPaint, size: 1.0);
    }
  } else {
    drawLine(l, monxiv,paint: usedPaint);
  }


}

