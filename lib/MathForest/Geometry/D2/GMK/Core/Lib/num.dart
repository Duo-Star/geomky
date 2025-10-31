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
  'N': [
    //数字
    'num',
    (factor, data) {
      return getVar(factor[0], data);
    },
  ],

  'N^add': [
    //数字相加
    'num',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      num n2 = getVar(factor[1], data);
      return n1 + n2;
    },
  ],

  'N^sub': [
    //数字相减
    'num',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      num n2 = getVar(factor[1], data);
      return n1 - n2;
    },
  ],

  'N^ops': [
    //数字取反
    'num',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      return -n1;
    },
  ],

  'N^mul': [
    //数字取反
    'num',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      num n2 = getVar(factor[1], data);
      return n1 * n2;
    },
  ],

  'N^div': [
    //数字相除
    'num',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      num n2 = getVar(factor[1], data);
      return n1 / n2;
    },
  ],

  'N^sin': [
    //数字正弦
    'num',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      return math.sin(n1);
    },
  ],

  'N^cos': [
    //数字余弦
    'num',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      return math.cos(n1);
    },
  ],

  'N^tan': [
    //数字正切
    'num',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      return math.tan(n1);
    },
  ],

  'N^abs': [
    //数字绝对值
    'num',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      return funcs.sin(n1);
    },
  ],

  'N^sgn': [
    //数字符号归一
    'num',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      return funcs.sgn(n1);
    },
  ],
};
