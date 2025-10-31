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
  'DP': [
    //骈点
    'DPoint',
        (factor, data) {
      Vector p1 = getVar(factor[0], data);
      Vector p2 = getVar(factor[1], data);
      return DPoint(p1, p2);
    },
  ],

  'TP': [
    //汆点
    'TPoint',
        (factor, data) {
      Vector p1 = getVar(factor[0], data);
      Vector p2 = getVar(factor[1], data);
      Vector p3 = getVar(factor[2], data);
      return TPoint(p1, p2, p3);
    },
  ],

  'QP:4p': [
    //合点
    'QPoint',
        (factor, data) {
      Vector p1 = getVar(factor[0], data);
      Vector p2 = getVar(factor[1], data);
      Vector p3 = getVar(factor[2], data);
      Vector p4 = getVar(factor[3], data);
      return QPoint(p1, p2, p3, p4);
    },
  ],

  'QP': [
    //创建合点
    'QPoint',
        (factor, data) {
      DPoint dp1 = getVar(factor[0], data);
      DPoint dp2 = getVar(factor[1], data);
      return QPoint.new2DP(dp1, dp2);
    },
  ],
  'DP^index': [
    //駢点的索引
    'Vector',
        (factor, data) {
      DPoint dp = getVar(factor[0], data);
      int index = getVar(factor[1], data);
      return (index == 1) ? dp.p1 : dp.p2;
    },
  ],

  'QP^deriveL': [
    //计算合点的衍线
    'Line',
        (factor, data) {
      QPoint qp = getVar(factor[0], data);
      return qp.deriveL;
    },
  ],

  'QP^heart': [
    //计算合点的心点
    'Vector',
        (factor, data) {
      QPoint qp = getVar(factor[0], data);
      return qp.heart;
    },
  ],

  'DP^l': [
    //连接骈点
    'Line',
        (factor, data) {
      DPoint dp = getVar(factor[0], data);
      return dp.l;
    },
  ],

  'DP^mid': [
    //连接骈点
    'Vector',
        (factor, data) {
      DPoint dp = getVar(factor[0], data);
      return dp.mid;
    },
  ],

  'QP^xl1': [
    //合点 两种连接-1（交叉直线）
    'XLine',
        (factor, data) {
      QPoint qp = getVar(factor[0], data);
      return qp.xl1;
    },
  ],

  'QP^xl2': [
    //合点 两种连接-2（交叉直线）
    'XLine',
        (factor, data) {
      QPoint qp = getVar(factor[0], data);
      return qp.xl2;
    },
  ],
  'Harm:dpt': [
    //计算调和点
    'DPoint',
        (factor, data) {
      DPoint dp = getVar(factor[0], data);
      num t = getVar(factor[1], data);
      return dp.harmonic(t);
    },
  ],
};
