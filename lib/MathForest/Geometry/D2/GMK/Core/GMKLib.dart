library;

import 'dart:math' as math;
import '../../../../Algebra/Functions/Main.dart' as funcs;
import '../../Intersection/Line520.dart' as l520;


import '../../Linear/Vector.dart';
import '../../Linear/Line.dart';
import '../../Linear/Triangle.dart';
import '../../Conic/Circle.dart';
import '../../Conic/Conic0.dart';
import '../../Conic/Conic1.dart';
import '../../Conic/Conic2.dart';
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
// 方法集合
import 'GMKLib.dart' as lib;
// 几何对象
import '../Monxiv/GraphOBJ.dart';

dynamic getVar(itemFactor, gmkData) {
  if (itemFactor.runtimeType == String) {
    String label = compiler.subStringBetween(itemFactor, '<', '>');
    return gmkData.data[label]?.obj;
  } else {
    return itemFactor;
  }
}

dynamic analysis(GMKCommand gmkCommand, GMKData gmkData) {
  switch (gmkCommand.method) {
    case 'N':
      return (getVar(gmkCommand.factor[0], gmkData), 'num');

    case 'N^add':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      return (n1+n2, 'num');

    case 'N^sub':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      return (n1-n2, 'num');

    case 'N^ops':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      return (-n1, 'num');

    case 'N^mul':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      return (n1*n2, 'num');

    case 'N^div':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      return (n1/n2, 'num');

    case 'N^sin':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      return (math.sin(n1), 'num');

    case 'N^cos':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      return (math.cos(n1), 'num');

    case 'N^tan':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      return (math.tan(n1), 'num');

    case 'N^abs':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      return (funcs.sin(n1), 'num');

    case 'N^sgn':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      return (funcs.sgn(n1), 'num');

    case 'DN':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      return (DNum(n1, n2), 'DNum');

    case 'TN':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      num n3 = getVar(gmkCommand.factor[2], gmkData);
      return (TNum(n1, n2, n3), 'TNum');

    case 'QN':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      num n3 = getVar(gmkCommand.factor[2], gmkData);
      num n4 = getVar(gmkCommand.factor[3], gmkData);
      return (QNum(n1, n2, n3, n4), 'QNum');

    case 'P':
      num x = getVar(gmkCommand.factor[0], gmkData);
      num y = getVar(gmkCommand.factor[1], gmkData);
      return (Vector(x, y), 'Vector');

    case 'P:v':
      Vector p = getVar(gmkCommand.factor[0], gmkData);
      return (p, 'Vector');

    case 'Ins^ll':
      Line l1 = getVar(gmkCommand.factor[0], gmkData);
      Line l2 = getVar(gmkCommand.factor[1], gmkData);
      return (l520.xLineLine(l1, l2), 'Vector');

    case 'L':
      Vector p1 = getVar(gmkCommand.factor[0], gmkData);
      Vector p2 = getVar(gmkCommand.factor[1], gmkData);
      return (Line.new2P(p1, p2), 'Line');

    case 'L:pv':
      Vector p = getVar(gmkCommand.factor[0], gmkData);
      Vector v = getVar(gmkCommand.factor[1], gmkData);
      return (Line(p, v), 'Line');

    case 'C:pr':
      Vector p = getVar(gmkCommand.factor[0], gmkData);
      num r = getVar(gmkCommand.factor[1], gmkData);
      return (Circle(p, r), 'Circle');

    case 'P^mid':
      Vector p1 = getVar(gmkCommand.factor[0], gmkData);
      Vector p2 = getVar(gmkCommand.factor[1], gmkData);
      return (p1.mid(p2), 'Vector');

    case 'IndexP':
      dynamic obj = getVar(gmkCommand.factor[0], gmkData);
      num index = getVar(gmkCommand.factor[1], gmkData);
      return (obj.indexPoint(index), 'Vector');

    case 'IndexDP':
      dynamic obj = getVar(gmkCommand.factor[0], gmkData);
      DNum index = getVar(gmkCommand.factor[1], gmkData);
      return (obj.indexDPoint(index), 'DPoint');

    case 'IndexQP':
      dynamic obj = getVar(gmkCommand.factor[0], gmkData);
      QNum index = getVar(gmkCommand.factor[1], gmkData);
      return (obj.indexQPoint(index), 'QPoint');

    case 'QP^deriveL':
      QPoint qp = getVar(gmkCommand.factor[0], gmkData);
      return (qp.deriveL, 'Line');

    case 'QP^heart':
      QPoint qp = getVar(gmkCommand.factor[0], gmkData);
      return (qp.heart, 'Vector');


    default:
      return (null, '?type');
  }
}

/*
Map<String, dynamic> doc = {
  'P': {
    'in_type': 'num',
    'out_type': 'Vector',
    'father': 'P',
    'facNum': 2,
    'demo': '@A is P of 1, 1;',
  },
  'P_byVec': {'type': 'Vector', 'facNum': 1, 'demo': '@A is P of <1, 1>;'},
};
void main(){
  print(doc['P']);
}
 */
