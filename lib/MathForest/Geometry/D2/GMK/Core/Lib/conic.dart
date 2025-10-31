library;

import 'dart:math' as math;

//求交算法库
import '../../../../../Algebra/Functions/Main.dart' as funcs;
import '../../../Intersection/Line520.dart' as l520;
import '../../../Intersection/Other2DInsSolver.dart' as other_ins_solver;

//几何对象
import '../../../Linear/Vector.dart';
import '../../../Linear/Polygon.dart';
import '../../../Linear/Line.dart';
import '../../../Linear/Triangle.dart';
import '../../../Conic/Circle.dart';
import '../../../Conic/Conic0.dart';
import '../../../Conic/Conic1.dart';
import '../../../Conic/Conic2.dart';
import '../../../Conic/XLine.dart';
import '../../../Conic/HLine.dart';
import '../../../../../Algebra/Trunk/Fertile/DNum.dart';
import '../../../../../Algebra/Trunk/Fertile/QNum.dart';
import '../../../../../Algebra/Trunk/Fertile/TNum.dart';
import '../../../Fertile/DPoint.dart';
import '../../../Fertile/TPoint.dart';
import '../../../Fertile/QPoint.dart';
import '../../../Fertile/DXLine.dart';

// 几何数据
import '../GMKData.dart';
// 几何结构
import '../GMKStructure.dart';
// 单步命令
import '../GMKCommand.dart';
// 编译器
import '../GMKCompiler.dart' as compiler;
// 几何对象
import '../../Monxiv/graphOBJ.dart';

//返回值，预制值或标签索引
dynamic getVar(dynamic itemFactor, gmkData) {
  if (itemFactor.runtimeType == String) {
    String label = compiler.subStringBetween(itemFactor, '<', '>');
    return gmkData.data[label]?.obj;
  } else {
    return itemFactor;
  }
}

//返回完整值列表
List<dynamic> getVarList(List<dynamic> factorList, gmkData) {
  List<dynamic> result = [];
  for (var item in factorList) {
    result.add(getVar(item, gmkData));
  }
  return result;
}

//解析单条指令
dynamic analysis(GMKCommand gmkCommand, GMKData gmkData) {
  String method = gmkCommand.method;
  List? libR = lib[method];
  if (libR != null) {
    return (libR[1](gmkCommand.factor, gmkData), libR[0]);
  }
  return (null, '???');
}

//

Map<String, List<dynamic>> lib = {
  'C': [
    //圆（圆心和半径）
    'Circle',
        (factor, data) {
      Vector p = getVar(factor[0], data);
      num r = getVar(factor[1], data);
      return Circle(p, r);
    },
  ],

  'C:op': [
    //圆（圆心和圆上一点）
    'Circle',
        (factor, data) {
      Vector o = getVar(factor[0], data);
      Vector p = getVar(factor[1], data);
      return Circle.new2P(o, p);
    },
  ],

  'C:diameter': [
    //圆（圆心和圆上一点）
    'Circle',
        (factor, data) {
      DPoint dp = getVar(factor[0], data);
      return Circle.newDiameter(dp);
    },
  ],
  'C0': [
    //椭圆（中心和共轭直径）
    'Conic0',
        (factor, data) {
      Vector p0 = getVar(factor[0], data);
      Vector p1 = getVar(factor[1], data);
      Vector p2 = getVar(factor[2], data);
      return Conic0(p0, p1 - p0, p2 - p0);
    },
  ],

  'C1': [
    //抛物线
    'Conic1',
        (factor, data) {
      Vector p0 = getVar(factor[0], data);
      Vector p1 = getVar(factor[1], data);
      Vector p2 = getVar(factor[2], data);
      return Conic0(p0, p1 - p0, p2 - p0);
    },
  ],

  'C2': [
    //双曲线
    'Conic2',
        (factor, data) {
      Vector p0 = getVar(factor[0], data);
      Vector p1 = getVar(factor[1], data);
      Vector p2 = getVar(factor[2], data);
      return Conic2(p0, p1 - p0, p2 - p0);
    },
  ],

  'Asym': [
    //二次曲线的渐近线
    'XLine',
        (factor, data) {
      dynamic c = getVar(factor[0], data);
      return c.asymptote;
    },
  ],

  'F': [
    //二次曲线的焦点
    'DPoint',
        (factor, data) {
      dynamic c = getVar(factor[0], data);
      return c.F;
    },
  ],
  'XL^p': [
    //计算叉线中心
    'Vector',
        (factor, data) {
      XLine xl = getVar(factor[0], data);
      return xl.p;
    },
  ],

};
