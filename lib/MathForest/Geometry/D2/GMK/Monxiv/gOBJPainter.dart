library;

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

//
import 'basicPainter.dart';
import 'graphOBJ.dart';
import 'gOBJStyle.dart';
import 'monxiv.dart';

//
import '../../../../Algebra/Functions/Main.dart' as funcs;
//

import '../Core/GMKData.dart';
import '../Core/GMKStructure.dart';
import '../Core/GMKCompiler.dart' as compiler;

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
import '../../Linear/Triangle.dart';

//

// 定义绘图函数映射
final Map<String, Function> gPainter = {
  'Vector': (String label, GraphOBJ gOBJ, Monxiv monxiv) {
    if (gOBJ.style.show) {
      Vector p = gOBJ.obj;
      Paint paint = Paint()
        ..color = gOBJ.style.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * gOBJ.style.size;
      drawPoint(p, monxiv, paint: paint);

      if (monxiv.selectLabel == gOBJ.label) {
        Paint sPaint = Paint()
          ..color = gOBJ.style.color.withAlpha(88)
          ..style = PaintingStyle.fill
          ..strokeWidth = 2.5 * gOBJ.style.size;
        drawPoint(p, monxiv, size: 10, paint: sPaint);
      }

      if (gOBJ.style.labelShow) {
        drawText('Point: $label', p, 12, 500, monxiv);
      }
    }
  },

  'DPoint': (String label, GraphOBJ gOBJ, Monxiv monxiv) {
    if (gOBJ.style.show) {
      DPoint dp = gOBJ.obj;
      Paint paint = Paint()
        ..color = gOBJ.style.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * gOBJ.style.size;
      drawDPoint(dp, monxiv, paint: paint);

      bool fertileWaveLink = gOBJ.style.fertileWaveLink;
      bool fertileWaveLinkSelect = false;

      if (monxiv.selectLabel == gOBJ.label) {
        Paint sPaint = Paint()
          ..color = gOBJ.style.color.withAlpha(88)
          ..style = PaintingStyle.fill
          ..strokeWidth = 2.5 * gOBJ.style.size;
        drawDPoint(dp, monxiv, size: 10, paint: sPaint);
        fertileWaveLink = true;
        fertileWaveLinkSelect = true;
      }

      if (fertileWaveLink) {
        Vector v = (dp.p1 - dp.p2);
        Vector u = v.roll90();
        num time = monxiv.gmkData.data['time']?.obj ?? 0;

        Vector wave(t) {
          num h = (-1.0 * t * (t - 1));
          return u * (sin(10.0 * t * v.len + 2.5 * time) * 0.16 * h) +
              v * t +
              dp.p2;
        }

        drawT2PFunction(
          wave,
          monxiv,
          from: 0,
          to: 1,
          dt: (.02 / v.len).clamp(0.001, 0.01),
          paint: paint,
        );

        if (fertileWaveLinkSelect) {
          drawT2PFunction(
            wave,
            monxiv,
            from: 0,
            to: 1,
            dt: (.02 / v.len).clamp(0.001, 0.01),
            paint: Paint()
              ..color = gOBJ.style.color.withAlpha(80)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 10.0 * gOBJ.style.size,
          );
        }
      }

      if (gOBJ.style.labelShow) {
        drawText('DPoint: $label', dp.p1, 12, 500, monxiv);
      }
    }
  },

  'QPoint': (String label, GraphOBJ gOBJ, Monxiv monxiv) {
    if (gOBJ.style.show) {
      Paint paint = Paint()
        ..color = gOBJ.style.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * gOBJ.style.size;
      QPoint qp = gOBJ.obj;
      drawQPoint(qp, monxiv, paint: paint);

      if (gOBJ.style.labelShow) {
        drawText('QPoint: $label', qp.p1, 12, 500, monxiv);
      }
    }
  },

  'num': (String label, GraphOBJ gOBJ, Monxiv monxiv) {
    if (gOBJ.style.labelShow) {
      Vector p = Vector(gOBJ.obj);
      drawText('N: $label', p, 12, 500, monxiv);
    }
  },

  'Circle': (String label, GraphOBJ gOBJ, Monxiv monxiv) {
    Circle circle = gOBJ.obj;
    Paint paint = Paint()
      ..color = gOBJ.style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * gOBJ.style.size;
    drawCircle(circle, monxiv, paint: paint);

    if (monxiv.selectLabel == gOBJ.label) {
      Paint sPaint = Paint()
        ..color = gOBJ.style.color.withAlpha(88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0 * gOBJ.style.size;
      drawCircle(circle, monxiv, paint: sPaint);
    }

    if (gOBJ.style.labelShow) {
      drawText(
        'Circle: $label',
        circle.indexPoint(label.hashCode),
        12,
        500,
        monxiv,
      );
    }
  },

  'Line': (String label, GraphOBJ gOBJ, Monxiv monxiv) {
    if (gOBJ.style.show) {
      Line l = gOBJ.obj;
      Paint paint = Paint()
        ..color = gOBJ.style.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * gOBJ.style.size;

      if (gOBJ.style.shape == 'dotted') {
        drawDottedLine(l, monxiv, paint: paint);
      } else {
        drawLine(l, monxiv, paint: paint);
      }

      if (monxiv.selectLabel == gOBJ.label) {
        Paint sPaint = Paint()
          ..color = gOBJ.style.color.withAlpha(88)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9.0 * gOBJ.style.size;
        drawLine(l, monxiv, paint: sPaint);
      }

      if (gOBJ.style.labelShow) {
        drawText(
          'Line: $label',
          l.indexPoint(sin(label.hashCode)),
          12,
          500,
          monxiv,
        );
      }
    }
  },

  'Conic0': (String label, GraphOBJ gOBJ, Monxiv monxiv) {
    Conic0 c0 = gOBJ.obj;
    Paint paint = Paint()
      ..color = gOBJ.style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * gOBJ.style.size;
    drawConic0(c0, monxiv, paint: paint);

    if (monxiv.selectLabel == gOBJ.label) {
      Paint sPaint = Paint()
        ..color = gOBJ.style.color.withAlpha(88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0 * gOBJ.style.size;
      drawConic0(c0, monxiv, paint: sPaint);
    }

    if (gOBJ.style.labelShow) {
      drawText(
        'Conic0: $label',
        c0.indexPoint(label.hashCode),
        12,
        500,
        monxiv,
      );
    }
  },

  'Conic2': (String label, GraphOBJ gOBJ, Monxiv monxiv) {
    Conic2 c2 = gOBJ.obj;
    Paint paint = Paint()
      ..color = gOBJ.style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * gOBJ.style.size;
    drawConic2(c2, monxiv, paint: paint);

    if (monxiv.selectLabel == gOBJ.label) {
      Paint sPaint = Paint()
        ..color = gOBJ.style.color.withAlpha(88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0 * gOBJ.style.size;
      drawConic2(c2, monxiv, paint: sPaint);
    }

    if (gOBJ.style.labelShow) {
      drawText(
        'Conic2: $label',
        c2.indexPoint(label.hashCode),
        12,
        500,
        monxiv,
      );
    }
  },

  'XLine': (String label, GraphOBJ gOBJ, Monxiv monxiv) {
    XLine xl = gOBJ.obj;
    Paint paint = Paint()
      ..color = gOBJ.style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * gOBJ.style.size;
    drawLine(xl.l1, monxiv, paint: paint);
    drawLine(xl.l2, monxiv, paint: paint);

    if (monxiv.selectLabel == gOBJ.label) {
      Paint sPaint = Paint()
        ..color = gOBJ.style.color.withAlpha(88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0 * gOBJ.style.size;
      drawLine(xl.l1, monxiv, paint: sPaint);
      drawLine(xl.l2, monxiv, paint: sPaint);
    }

    if (gOBJ.style.labelShow) {
      drawText('XLine: $label', xl.p, 12, 500, monxiv);
    }
  },

  'Polygon': (String label, GraphOBJ gOBJ, Monxiv monxiv) {
    Polygon polygon = gOBJ.obj;
    Paint paint = Paint()
      ..color = gOBJ.style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * gOBJ.style.size;
    drawPolygon(polygon, monxiv, paint: paint);

    if (monxiv.selectLabel == gOBJ.label) {
      Paint sPaint = Paint()
        ..color = gOBJ.style.color.withAlpha(88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0 * gOBJ.style.size;
      drawPolygon(polygon, monxiv, paint: sPaint);
    }

    if (gOBJ.style.labelShow) {
      drawText('Polygon: $label', polygon.vertices.first, 12, 500, monxiv);
    }
  },

  'Triangle': (String label, GraphOBJ gOBJ, Monxiv monxiv) {

    Triangle tri = gOBJ.obj;
    Paint paint = Paint()
      ..color = gOBJ.style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * gOBJ.style.size;
    drawTriangle(tri, monxiv, paint: paint);

    if (monxiv.selectLabel == gOBJ.label) {
      Paint sPaint = Paint()
        ..color = gOBJ.style.color.withAlpha(88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0 * gOBJ.style.size;
      drawTriangle(tri, monxiv, paint: sPaint);
    }

    if (gOBJ.style.labelShow) {
      drawText('Polygon: $label', tri.a, 12, 500, monxiv);
    }
  },
};
