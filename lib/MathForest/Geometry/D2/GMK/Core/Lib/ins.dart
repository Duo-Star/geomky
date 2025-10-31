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
  'Ins^ll': [
    //直线和直线交点
    'Vector',
        (factor, data) {
      Line l1 = getVar(factor[0], data);
      Line l2 = getVar(factor[1], data);
      return l520.xLineLine(l1, l2);
    },
  ],

  'Ins^cl_index': [
    //圆和直线的交点（索引消骈）
    'Vector',
        (factor, data) {
      Circle c = getVar(factor[0], data);
      Line l = getVar(factor[1], data);
      int index = getVar(factor[2], data);
      DNum dn = l520.xCircleLineTheta(c, l);
      return c.indexPoint((index == 1) ? dn.min : dn.max);
    },
  ],

  'Ins^c0l': [
    //椭圆和直线的交点
    'DPoint',
        (factor, data) {
      Conic0 c0 = getVar(factor[0], data);
      Line l = getVar(factor[1], data);
      return l520.xConic0Line(c0, l);
    },
  ],

  'Ins^lc0': [
    //直线和椭圆的交点
    'DPoint',
        (factor, data) {
      Line l = getVar(factor[0], data);
      Conic0 c0 = getVar(factor[1], data);
      return l520.xConic0Line(c0, l);
    },
  ],

  'Ins^lc2': [
    //直线和双曲线的交点
    'DPoint',
        (factor, data) {
      Line l = getVar(factor[0], data);
      Conic2 c2 = getVar(factor[1], data);
      return l520.xConic2Line(c2, l);
    },
  ],

  'Ins^c2l': [
    //直线和双曲线的交点
    'DPoint',
        (factor, data) {
      Conic2 c2 = getVar(factor[0], data);
      Line l = getVar(factor[1], data);
      return l520.xConic2Line(c2, l);
    },
  ],

  'Ins^lxl': [
    //直线和交叉直线的交点
    'DPoint',
        (factor, data) {
      Line l = getVar(factor[0], data);
      XLine xl = getVar(factor[1], data);
      return l520.xXLineLine(xl, l);
    },
  ],

  'Ins^xll': [
    //直线和交叉直线的交点
    'DPoint',
        (factor, data) {
      XLine xl = getVar(factor[0], data);
      Line l = getVar(factor[1], data);
      return l520.xXLineLine(xl, l);
    },
  ],

  'Ins^cc': [
    //两个圆的交点
    'DPoint',
        (factor, data) {
      Circle c1 = getVar(factor[0], data);
      Circle c2 = getVar(factor[1], data);
      return other_ins_solver.xCircleCircle(c1, c2);
    },
  ],

  'Ins^lc': [
    //直线和圆的交点
    'DPoint',
        (factor, data) {
      Line l = getVar(factor[0], data);
      Circle c = getVar(factor[1], data);
      return l520.xCircleLine(c, l);
    },
  ],

  'Ins^cl': [
    //圆和直线的交点
    'DPoint',
        (factor, data) {
      Circle c = getVar(factor[0], data);
      Line l = getVar(factor[1], data);
      return l520.xCircleLine(c, l);
    },
  ],

  'Ins^cc_index': [
    //两个圆的交点（索引消骈）
    'Vector',
        (factor, data) {
      Circle c1 = getVar(factor[0], data);
      Circle c2 = getVar(factor[1], data);
      int index = getVar(factor[2], data);
      DNum dn = other_ins_solver.xCircleCircleTheta(c1, c2);
      return c2.indexPoint((index == 1) ? dn.min : dn.max);
    },
  ],

};
