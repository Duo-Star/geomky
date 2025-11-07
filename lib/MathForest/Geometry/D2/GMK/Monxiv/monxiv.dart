import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

//
import 'basicPainter.dart';
import 'gOBJPainter.dart' as g_obj_painter;
//
import '../../../../Algebra/Functions/Main.dart' as funcs;
//
import 'graphOBJ.dart';
import '../Core/GMKData.dart';
import '../Core/GMKStructure.dart';
import '../Core/GMKCompiler.dart' as compiler;
import '../Core/GMKCommand.dart';

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
  Vector size = Vector();
  late Canvas canvas;

  //
  bool frameAxis = false;
  bool frameGrid = false;
  //
  GMKData gmkData = GMKData.none();
  GMKStructure gmkStructure = GMKStructure.newBlank();

  // 用于处理手势
  Vector _startLocalPosition = Vector.zero; //
  Vector _startMonxivP = Vector(); //
  double _startMonxivLam = 1.0; //
  bool _isDragging = false; //
  List<num> monxivLamRestriction = [5, 1e3]; //

  //
  bool isObjDragging = false; //
  String objDraggingLabel = ''; //

  //选中的对象标签
  String selectLabel = ''; //

  //选中的工具
  String toolSelect = ''; //
  int toolStepSum = 0; //
  List<dynamic> toolTemp = []; //

  //
  num get xStart => -p.x / lam; //
  num get xEnd => (size.x - p.x) / lam; //
  num get yStart => -(size.y - p.y) / lam; //
  num get yEnd => p.y / lam; //

  //初始化时要设置size
  void setSize(Size size_) {
    size = Vector(size_.width, size_.height);
  }

  //设置绘制信息
  void setGMKData(GMKData gd) {
    gmkData = gd;
  }

  //设置画布
  void setCanvas(Canvas c) {
    canvas = c;
  }

  //
  Color bgc = Color.fromARGB(255, 255, 255, 255);
  Color axisLabelColor = Colors.black54;

  //坐标变换
  Vector c2s(Vector c) {
    // 坐标系坐标转屏幕坐标
    return Vector(c.x * lam + p.x, -c.y * lam + p.y);
  }

  Vector s2c(Vector s) { // 屏幕坐标转坐标系坐标
    return Vector((s.x - p.x) / lam, -(s.y - p.y) / lam);
  }

  // 重置视图
  void reset([Vector? v]) {
    p = Vector(size.x * .12, size.y * .85);
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
    if (toolSelect == '') {
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
        toolSelect = '';
      }
    }
  }

  // 处理缩放更新（同时处理平移和缩放）
  void handleScaleUpdate(ScaleUpdateDetails details) {
    print('handleScaleUpdate');
    if (details.scale != 1.0) {
    } else if (details.localFocalPoint != _startLocalPosition.offset) {
      // 平移
      Vector sp = Vector(
        details.localFocalPoint.dx,
        details.localFocalPoint.dy,
      );
      Vector cp = s2c(sp);
      if (isObjDragging) {
        //print(gmkStructure.step[objDraggingLabel]?.type);
        switch (gmkStructure.step[objDraggingLabel]?.type) {
          case const ('Vector'):
            switch (gmkStructure.step[objDraggingLabel]?.method) {
              case const ('P'):
                gmkStructure.alterFactor(objDraggingLabel, [cp.x, cp.y]);
              case const ('P:v'):
                gmkStructure.alterFactor(objDraggingLabel, [
                  Vector(cp.x, cp.y),
                ]);
              case const ('IndexP'):
                String labelR = gmkStructure.step[objDraggingLabel]?.factor[0];
                String label_ = compiler.subStringBetween(labelR, '<', '>');
                gmkStructure.alterFactor(objDraggingLabel, [
                  labelR,
                  gmkData.data[label_]?.obj.thetaClosestP(Vector(cp.x, cp.y)),
                ]);
              default:
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
      // 获取鼠标指针的屏幕坐标
      Vector pointerScreenPos = Vector(event.position.dx, event.position.dy);
      // 转换为世界坐标
      Vector pointerWorldPos = s2c(pointerScreenPos);
      // 计算缩放因子
      num zoomFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
      num newLam = lam * zoomFactor;
      newLam = newLam.clamp(monxivLamRestriction[0], monxivLamRestriction[1]);
      // 调整 p，使得 pointerWorldPos 的屏幕坐标不变
      p.x = pointerScreenPos.x - pointerWorldPos.x * newLam;
      p.y = pointerScreenPos.y + pointerWorldPos.y * newLam;
      // 更新缩放因子
      lam = newLam;
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

    String newLabel() => DateTime.now().millisecondsSinceEpoch.toString();

    print("单击：${tapCP.toString()}");
    if (toolSelect == 'Point') {
      //点工具
      if (lb == '') {
        //自由点
        gmkStructure.addStep(
          GMKCommand('P:v', 'P{${newLabel()}}', [tapCP.copy()]),
        );
      } else {
        //对象上取点
        num index = gmkData.data[lb]?.obj.thetaClosestP(tapCP.copy());
        gmkStructure.addStep(
          GMKCommand('IndexP', 'P{${newLabel()}}', ['#label<$lb>', index]),
        );
      }
    } else if (toolSelect == 'Line') {
      //直线工具
      toolStepSum = 2;
      if (lb == '') {
        //新建点作直线
        String p1Label = newLabel();
        gmkStructure.addStep(GMKCommand('P:v', 'P{$p1Label}', [tapCP.copy()]));
        toolTemp.add('#label<P{$p1Label}>');
        selectLabel = p1Label;
        if (toolTemp.length == toolStepSum) {
          String lLabel = newLabel();
          print(toolTemp);
          gmkStructure.addStep(GMKCommand('L', 'L{$lLabel}', toolTemp));
          toolTemp = [];
          selectLabel = 'L{$lLabel}';
        }
      } else {
        //对象上取点
        toolTemp.add('#label<$lb>');
        selectLabel = lb;
        if (toolTemp.length == toolStepSum) {
          gmkStructure.addStep(GMKCommand('L', 'L{${newLabel()}}', toolTemp));
          toolTemp = [];
          selectLabel = 'L{${newLabel()}}';
        }
      }
    } else if (toolSelect == 'Circle') {
      //圆工具
      toolStepSum = 2;
      if (lb == '') {
        //新建点作圆
        toolTemp.add(tapCP.copy());
        selectLabel = lb;
        if (toolTemp.length == toolStepSum) {
          gmkStructure.addStep(
            GMKCommand('C:op', 'C{${newLabel()}}', toolTemp),
          );
          toolTemp = [];
          selectLabel = 'C{${newLabel()}}';
        }
      } else {
        //对象上取点
        toolTemp.add('#label<$lb>');
        selectLabel = lb;
        if (toolTemp.length == toolStepSum) {
          gmkStructure.addStep(
            GMKCommand('C:op', 'C{${newLabel()}}', toolTemp),
          );
          toolTemp = [];
          selectLabel = 'L{${newLabel()}}';
        }
      }
    } else if (toolSelect == 'Triangle') {
      toolStepSum = 3;
      if (lb == '') {
        toolTemp.add(tapCP.copy());
        selectLabel = lb;
        if (toolTemp.length == toolStepSum) {
          gmkStructure.addStep(
            GMKCommand('Tri', 'Tri{${newLabel()}}', toolTemp),
          );
          toolTemp = [];
          selectLabel = 'Tri{${newLabel()}}';
        }
      } else {
        //对象上取点
        toolTemp.add('#label<$lb>');
        selectLabel = lb;
        if (toolTemp.length == toolStepSum) {
          gmkStructure.addStep(
            GMKCommand('Tri', 'Tri{${newLabel()}}', toolTemp),
          );
          toolTemp = [];
          selectLabel = 'Tri{${newLabel()}}';
        }
      }
    } else {
      selectLabel = lb;
    }
  }

  String select(tcp) {
    num maxDx = size.len / 100;
    num dx = 1e5; //spx
    num ldx = dx;
    String lb = '';
    gmkData.forEach((String key, GraphOBJ gObj) {
      if (gObj.style.show) {
        switch (gObj.type) {
          case const ("Vector"):
            dx = 1 + (tcp - gObj.obj).len * lam;
          case const ('Circle'):
            dx = 6 + gObj.obj.disP(tcp) * lam;
          case const ('Line'):
            dx = 5 + gObj.obj.disP(tcp) * lam;
          case const ('DPoint'):
            dx = gObj.obj.disP(tcp).min * lam;
          case const ('Polygon'):
            dx = 3 + gObj.obj.disP(tcp) * lam;
          case const ('Triangle'):
            dx = 3 + gObj.obj.disP(tcp) * lam;
          case const ('Conic0'):
            dx = 5 + gObj.obj.disP(tcp) * lam;
          case const ('Conic2'):
            dx = 5 + gObj.obj.disP(tcp) * lam;
          case const ('XLine'):
            dx = 3 + gObj.obj.disP(tcp) * lam;
        }
        if (dx < maxDx && dx < ldx) {
          ldx = dx;
          lb = gObj.label;
        }
      }
    });
    return lb;
  }

  bool draw() {
    //drawText('drawGMKData - error', c2s(Vector(10,10)), 12, 500, canvas);
    drawFramework(this);
    if (gmkData.count != 0) {
      for (var key in gmkData.data.keys) {
        final graphObj = gmkData.data[key];
        if (graphObj != null) {
          final painter = g_obj_painter.gPainter[graphObj.type];
          if (painter != null) {
            painter(key, graphObj, this);
          } else {
            // 默认处理或错误提示
            // drawText('error: $key', Vector(0, 0), 12, 500, this);
          }
        }
      }
    }
    return true;
  }
}
