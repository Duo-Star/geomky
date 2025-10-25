import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

//
import 'painter.dart';
//
import '../../../../Algebra/Functions/Main.dart' as funcs;
//
import 'GraphOBJ.dart';
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

class Monxiv {
  Vector p = Vector();
  num lam = 10;
  bool infoMode = false;
  Vector size = Vector();
  late Canvas canvas;
  //
  GMKData gmkData = GMKData.none();
  GMKStructure gmkStructure = GMKStructure.newBlank();
  //
  Function requestToModifyGMKStructure = (Function f) {};

  // 用于处理手势
  Vector _startLocalPosition = Vector.zero;
  Vector _startMonxivP = Vector();
  double _startMonxivLam = 1.0;
  bool _isDragging = false;
  List<num> monxivLamRestriction = [5, 1e3];

  //
  bool isObjDragging = false;
  String objDraggingLabel = '';

  //
  String selectLabel = '';

  //
  num get xStart => -p.x / lam;
  num get xEnd => (size.x - p.x) / lam;
  num get yStart => -(size.y - p.y) / lam;
  num get yEnd => p.y / lam;

  void setSize(Size size_) {
    size = Vector(size_.width, size_.height);
  }

  void setGMKData(GMKData gd) {
    gmkData = gd;
  }

  void setCanvas(Canvas c) {
    canvas = c;
  }

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
    print('开始移动');

    _isDragging = true;
    _startLocalPosition = Vector(
      details.localFocalPoint.dx,
      details.localFocalPoint.dy,
    );
    _startMonxivP = Vector(p.x, p.y); // 保存当前平移状态
    _startMonxivLam = lam.toDouble(); // 保存当前缩放状态
    Vector tapCP = s2c(_startLocalPosition);
    print(tapCP.toString());

    String lb = select(tapCP);
    if (lb != '') {
      isObjDragging = true;
      objDraggingLabel = lb;
      selectLabel = lb;
      print('开始拖拽${lb}');
    } else {
      print('取消拖拽${objDraggingLabel}');
      isObjDragging = false;
      objDraggingLabel = '';
      selectLabel = '';
    }
  }

  // 处理缩放更新（同时处理平移和缩放）
  void handleScaleUpdate(ScaleUpdateDetails details) {
    print('handleScaleUpdate');
    if (details.scale != 1.0) {
      // 缩放
      double newScale = _startMonxivLam * details.scale;
      // 缩放范围
      lam = newScale.clamp(monxivLamRestriction[0], monxivLamRestriction[1]);
    } else if (details.localFocalPoint != _startLocalPosition.offset) {
      // 平移
      Vector sp = Vector(
        details.localFocalPoint.dx,
        details.localFocalPoint.dy,
      );
      Vector cp = s2c(sp);
      if (isObjDragging) {
        print(gmkStructure.step[objDraggingLabel]?.type);
        switch (gmkStructure.step[objDraggingLabel]?.type) {
          case const ('Vector'):
            switch (gmkStructure.step[objDraggingLabel]?.method) {
              case const ('P'):
                gmkStructure.alterFactor(objDraggingLabel, [cp.x, cp.y]);
              case const ('P:v'):
                gmkStructure.alterFactor(objDraggingLabel, [
                  Vector(cp.x, cp.y),
                ]);
            }
          case const ('Circle'):
          // 其他理论上不做处理
        }
      } else {
        Offset delta = details.localFocalPoint - _startLocalPosition.offset;
        p = Vector(_startMonxivP.x + delta.dx, _startMonxivP.y + delta.dy);
      }
    }
  }

  // 处理缩放结束
  void handleScaleEnd(ScaleEndDetails details) {
    _isDragging = false;
    if (isObjDragging) {
      print('stopDrag$objDraggingLabel');
      isObjDragging = false;
      objDraggingLabel = '';
    }
    print('handleScaleEnd');
  }

  // 处理滚轮缩放
  void handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      print('滚轮缩放');
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

    String lb = select(tapCP);
    if (lb != null) {
      selectLabel = lb;
    } else {
      selectLabel = '';
    }

    print("单击：${tapCP.toString()}");
  }

  String select(tcp) {
    num maxDx = size.len / 110;
    num dx = 1e5; //spx
    num ldx = dx;
    String lb = '';
    gmkData.forEach((String key, GraphOBJ gObj) {
      switch (gObj.type) {
        case const ("Vector"):
          dx = (tcp - gObj.obj).len * lam;
        case const ('Circle'):
          dx = 5 + gObj.obj.disP(tcp) * lam;
        case const ('Line'):
          dx = 5 + gObj.obj.disP(tcp) * lam;
        case const ('DPoint'):
          dx = gObj.obj.disP(tcp).min * lam;
        case const ('Polygon'):
          dx = 3 + gObj.obj.disP(tcp) * lam;
        case const ('Conic0'):
          dx = 5 + gObj.obj.disP(tcp) * lam;
      }
      if (dx < maxDx && dx < ldx) {
        ldx = dx;
        lb = gObj.label;
      }
    });
    return lb;
  }

  bool draw() {
    //drawText('drawGMKData - error', c2s(Vector(10,10)), 12, 500, canvas);
    if (gmkData.count != 0) {
      for (var key in gmkData.data.keys) {
        switch (gmkData.data[key]?.type) {
          case const ("Vector"):
            if (gmkData.data[key]!.style.show) {
              Vector p = gmkData.data[key]?.obj;
              Paint paint = Paint()
                ..color = gmkData.data[key]!.style.color
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.5 * gmkData.data[key]!.style.size;
              drawPoint(p, this, paint: paint);
              if (selectLabel == gmkData.data[key]?.label) {
                Paint sPaint = Paint()
                  ..color = gmkData.data[key]!.style.color.withAlpha(88)
                  ..style = PaintingStyle.fill
                  ..strokeWidth = 2.5 * gmkData.data[key]!.style.size;
                drawPoint(p, this, size: 10, paint: sPaint);
              }
              if (gmkData.data[key]!.style.labelShow) {
                drawText('Point: $key', p, 12, 500, this);
              }
            }
          case const ("DPoint"):
            if (gmkData.data[key]!.style.show) {
              DPoint dp = gmkData.data[key]?.obj;
              Paint paint = Paint()
                ..color = gmkData.data[key]!.style.color
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.5 * gmkData.data[key]!.style.size;
              drawDPoint(dp, this, paint: paint);
              bool fertileWaveLink = gmkData.data[key]!.style.fertileWaveLink;
              bool fertileWaveLinkSelect = false;
              if (selectLabel == gmkData.data[key]?.label) {
                Paint sPaint = Paint()
                  ..color = gmkData.data[key]!.style.color.withAlpha(88)
                  ..style = PaintingStyle.fill
                  ..strokeWidth = 2.5 * gmkData.data[key]!.style.size;
                drawDPoint(dp, this, size: 10, paint: sPaint);
                fertileWaveLink = true;
                fertileWaveLinkSelect = true;
              }
              if (fertileWaveLink) {
                Vector v = (dp.p1 - dp.p2);
                Vector u = v.roll90();
                num time = gmkData.data['time']?.obj??0;
                Vector wave(t) {
                  num h = -1.0*t*(t-1);
                  return u * (sin(10.0*t*v.len+2.5*time)*0.16*h) + v * t + dp.p2;
                }
                drawT2PFunction(wave, this, from: 0, to: 1, dt: 0.02/v.len, paint: paint);
                if (fertileWaveLinkSelect) {
                  drawT2PFunction(wave, this, from: 0, to: 1, dt: 0.02/v.len, paint: Paint()
                    ..color = gmkData.data[key]!.style.color.withAlpha(80)
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 10.0 * gmkData.data[key]!.style.size);
                }
              }
              if (gmkData.data[key]!.style.labelShow) {
                drawText('DPoint: $key', p, 12, 500, this);
              }
            }
          case const ("QPoint"):
            QPoint qp = gmkData.data[key]?.obj;
            drawQPoint(qp, this);
            if (gmkData.data[key]!.style.labelShow) {
              drawText('QPoint: $key', qp.p1, 12, 500, this);
            }
          case const ("num"):
            Vector p = Vector(gmkData.data[key]?.obj);
            drawPoint(p, this);
            if (gmkData.data[key]!.style.labelShow) {
              drawText('N: $key', p, 12, 500, this);
            }
          case const ("Circle"):
            Circle circle = gmkData.data[key]?.obj;
            Paint paint = Paint()
              ..color = gmkData.data[key]!.style.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5 * gmkData.data[key]!.style.size;
            drawCircle(circle, this, paint: paint);
            if (selectLabel == gmkData.data[key]?.label) {
              Paint sPaint = Paint()
                ..color = gmkData.data[key]!.style.color.withAlpha(88)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 9.0 * gmkData.data[key]!.style.size;
              drawCircle(circle, this, paint: sPaint);
            }
            if (gmkData.data[key]!.style.labelShow) {
              drawText('Circle: $key', circle.p, 12, 500, this);
            }
          case const ("Line"):
            Line l = gmkData.data[key]?.obj;
            Paint paint = Paint()
              ..color = gmkData.data[key]!.style.color
              ..style = PaintingStyle.fill
              ..strokeWidth = 2.5 * gmkData.data[key]!.style.size;
            drawLine(l, this, paint: paint);
            if (selectLabel == gmkData.data[key]?.label) {
              Paint sPaint = Paint()
                ..color = gmkData.data[key]!.style.color.withAlpha(88)
                ..style = PaintingStyle.fill
                ..strokeWidth = 9.0 * gmkData.data[key]!.style.size;
              drawLine(l, this, paint: sPaint);
            }
            if (gmkData.data[key]!.style.labelShow) {
              drawText('Line: $key', l.p, 12, 500, this);
            }
          case const ("Conic0"):
            Conic0 c0 = gmkData.data[key]?.obj;
            Paint paint = Paint()
              ..color = gmkData.data[key]!.style.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5 * gmkData.data[key]!.style.size;
            drawConic0(c0, this, paint: paint);
            if (selectLabel == gmkData.data[key]?.label) {
              Paint sPaint = Paint()
                ..color = gmkData.data[key]!.style.color.withAlpha(88)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 9.0 * gmkData.data[key]!.style.size;
              drawConic0(c0, this, paint: sPaint);
            }
            if (gmkData.data[key]!.style.labelShow) {
              drawText('Conic0: $key', c0.p, 12, 500, this);
            }
          case const ('Polygon'):
            Polygon polygon = gmkData.data[key]?.obj;
            Paint paint = Paint()
              ..color = gmkData.data[key]!.style.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5 * gmkData.data[key]!.style.size;
            drawPolygon(polygon, this, paint: paint);
            if (selectLabel == gmkData.data[key]?.label) {
              Paint sPaint = Paint()
                ..color = gmkData.data[key]!.style.color.withAlpha(88)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 9.0 * gmkData.data[key]!.style.size;
              drawPolygon(polygon, this, paint: sPaint);
            }
            if (gmkData.data[key]!.style.labelShow) {
              drawText('Polygon: $key', polygon.vertices.first, 12, 500, this);
            }

          default:
          // drawText('error: $key', Vector(0, 0), 12, 500, canvas);
        }
      }
    }
    return true;
  }

  bool drawFramework() {
    canvas.drawColor(bgc, BlendMode.srcOver);
    drawSegmentBy2P(Vector(xStart, 0), Vector(xEnd, 0), this, paint: axisPaint);
    drawSegmentBy2P(Vector(0, yStart), Vector(0, yEnd), this, paint: axisPaint);
    int drawX = xStart.floor() - 1;
    if (drawX < 1) drawX = 1;
    int drawX_ = xEnd.floor() + 1;
    if (drawX_ > 100) drawX_ = 100;
    int drawY = yStart.floor() - 1;
    if (drawY < 1) drawY = 1;
    int drawY_ = yEnd.floor() + 1;
    if (drawY_ > 100) drawY_ = 100;
    for (int x = xStart.floor(); x <= xEnd; x++) {
      drawPoint(Vector(x), this, paint: axisPaint, size: 3.0);
      drawText(
        "$x",
        Vector(x) + Vector(-0.1, -0.1),
        12,
        500,
        this,
        color: axisLabelColor,
      );
      drawSegmentBy2P(
        Vector(x, yEnd),
        Vector(x, yStart),
        this,
        paint: gridPaint,
      );
    }
    for (int y = yStart.floor(); y <= yEnd; y++) {
      drawPoint(Vector(0, y), this, paint: axisPaint);
      drawText(
        "$y",
        Vector(0, y) + Vector(-0.1, -0.1),
        12,
        500,
        this,
        color: axisLabelColor,
      );
      drawSegmentBy2P(
        Vector(xStart, y),
        Vector(xEnd, y),
        this,
        paint: gridPaint,
      );
    }
    return true;
  }
}
