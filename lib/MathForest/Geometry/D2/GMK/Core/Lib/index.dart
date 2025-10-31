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
  'IndexP': [
    //对象上取点（直线，二次对象，共生对象）
    'Vector',
        (factor, data) {
      dynamic obj = getVar(factor[0], data);
      num index = getVar(factor[1], data);
      return obj.indexPoint(index);
    },
  ],

  'IndexDP': [
    //由駢数索引到骈点
    'DPoint',
        (factor, data) {
      dynamic obj = getVar(factor[0], data);
      DNum index = getVar(factor[1], data);
      return obj.indexDPoint(index);
    },
  ],

  'IndexQP': [
    //由合数索引到合点
    'QPoint',
        (factor, data) {
      dynamic obj = getVar(factor[0], data);
      QNum index = getVar(factor[1], data);
      return obj.indexQPoint(index);
    },
  ],

  'Index^getN': [
    //获取索引
    'num',
        (factor, data) {
      dynamic obj = getVar(factor[0], data);
      Vector p = getVar(factor[1], data);
      return obj.getPIndex(p);
    },
  ],
};
