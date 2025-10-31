library;

import 'dart:math' as math;

//求交算法库
import '../../../../Algebra/Functions/Main.dart' as funcs;
import '../../Intersection/Line520.dart' as l520;
import '../../Intersection/Other2DInsSolver.dart' as other_ins_solver;

//几何对象
import '../../Linear/Vector.dart';
import '../../Linear/Polygon.dart';
import '../../Linear/Line.dart';
import '../../Linear/Triangle.dart';
import '../../Conic/Circle.dart';
import '../../Conic/Conic0.dart';
import '../../Conic/Conic1.dart';
import '../../Conic/Conic2.dart';
import '../../Conic/XLine.dart';
import '../../Conic/HLine.dart';
import '../../../../Algebra/Trunk/Fertile/DNum.dart';
import '../../../../Algebra/Trunk/Fertile/QNum.dart';
import '../../../../Algebra/Trunk/Fertile/TNum.dart';
import '../../Fertile/DPoint.dart';
import '../../Fertile/TPoint.dart';
import '../../Fertile/QPoint.dart';
import '../../Fertile/DXLine.dart';

// 几何数据
import 'GMKData.dart';
// 几何结构
import 'GMKStructure.dart';
// 单步命令
import 'GMKCommand.dart';
// 编译器
import 'GMKCompiler.dart' as compiler;
// 几何对象
import '../Monxiv/graphOBJ.dart';


//整理的解析库
import 'Lib/conic.dart' as conic_lib;
import 'Lib/fertileNum.dart' as fertile_num_lib;
import 'Lib/fertilePoint.dart' as fertile_point_lib;
import 'Lib/index.dart' as index_lib;
import 'Lib/ins.dart' as ins_lib;
import 'Lib/linear.dart' as linear_lib;
import 'Lib/num.dart' as num_lib;
import 'Lib/point.dart' as point_lib;
import 'Lib/tan.dart' as tan_lib;

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

//接口库
Map<String, List<dynamic>> lib = {
  //圆锥曲线
  ...conic_lib.lib,
  //复生数字
  ...fertile_num_lib.lib,
  //复生点
  ...fertile_point_lib.lib,
  //索引
  ...index_lib.lib,
  //交点
  ...ins_lib.lib,
  //线性对象
  ...linear_lib.lib,
  //数字
  ...num_lib.lib,
  //点
  ...point_lib.lib,
  //切线
  ...tan_lib.lib,
} ;
