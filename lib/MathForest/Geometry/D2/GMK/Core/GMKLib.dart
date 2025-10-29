library;

import 'dart:math' as math;

import '../../../../Algebra/Functions/Main.dart' as funcs;
import '../../Intersection/Line520.dart' as l520;
import '../../Intersection/Other2DInsSolver.dart' as other_ins_solver;

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
// 方法集合
import 'GMKLib.dart' as lib;
// 几何对象
import '../Monxiv/GraphOBJ.dart';

dynamic getVar(dynamic itemFactor, gmkData) {
  if (itemFactor.runtimeType == String) {
    String label = compiler.subStringBetween(itemFactor, '<', '>');
    return gmkData.data[label]?.obj;
  } else {
    return itemFactor;
  }
}

List<dynamic> getVarList(List<dynamic> factorList, gmkData) {
  List<dynamic> result = [];
  for (var item in factorList) {
    result.add(getVar(item, gmkData));
  }
  return result;
}

dynamic analysis(GMKCommand gmkCommand, GMKData gmkData) {
  String method = gmkCommand.method;
  switch (method) {
    case 'N':
      return (getVar(gmkCommand.factor[0], gmkData), method2type[method]);

    case 'N^add':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      return (n1 + n2, method2type[method]);

    case 'N^sub':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      return (n1 - n2, method2type[method]);

    case 'N^ops':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      return (-n1, method2type[method]);

    case 'N^mul':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      return (n1 * n2, method2type[method]);

    case 'N^div':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      return (n1 / n2, method2type[method]);

    case 'N^sin':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      return (math.sin(n1), method2type[method]);

    case 'N^cos':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      return (math.cos(n1), method2type[method]);

    case 'N^tan':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      return (math.tan(n1), method2type[method]);

    case 'N^abs':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      return (funcs.sin(n1), method2type[method]);

    case 'N^sgn':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      return (funcs.sgn(n1), method2type[method]);

    case 'DN':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      return (DNum(n1, n2), method2type[method]);

    case 'TN':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      num n3 = getVar(gmkCommand.factor[2], gmkData);
      return (TNum(n1, n2, n3), method2type[method]);

    case 'QN':
      num n1 = getVar(gmkCommand.factor[0], gmkData);
      num n2 = getVar(gmkCommand.factor[1], gmkData);
      num n3 = getVar(gmkCommand.factor[2], gmkData);
      num n4 = getVar(gmkCommand.factor[3], gmkData);
      return (QNum(n1, n2, n3, n4), method2type[method]);

    case 'P':
      num x = getVar(gmkCommand.factor[0], gmkData);
      num y = getVar(gmkCommand.factor[1], gmkData);
      return (Vector(x, y), method2type[method]);

    case 'P:v':
      Vector p = getVar(gmkCommand.factor[0], gmkData);
      return (p, method2type[method]);

    case 'Ins^ll':
      Line l1 = getVar(gmkCommand.factor[0], gmkData);
      Line l2 = getVar(gmkCommand.factor[1], gmkData);
      return (l520.xLineLine(l1, l2), method2type[method]);

    case const ('Ins^cl'):
      Circle c = getVar(gmkCommand.factor[0], gmkData);
      Line l = getVar(gmkCommand.factor[1], gmkData);
      return (l520.xCircleLine(c, l), method2type[method]);

    case const ('Ins^lc'):
      Line l = getVar(gmkCommand.factor[0], gmkData);
      Circle c = getVar(gmkCommand.factor[1], gmkData);
      return (l520.xCircleLine(c, l), method2type[method]);

    case const ('Ins^cl_index'):
      Circle c = getVar(gmkCommand.factor[0], gmkData);
      Line l = getVar(gmkCommand.factor[1], gmkData);
      int index = getVar(gmkCommand.factor[2], gmkData);
      DNum dn = l520.xCircleLineTheta(c, l);
      return (c.indexPoint((index == 1) ? dn.min : dn.max), method2type[method]);

    case const ('Ins^cc'):
      Circle c1 = getVar(gmkCommand.factor[0], gmkData);
      Circle c2 = getVar(gmkCommand.factor[1], gmkData);
      return (other_ins_solver.xCircleCircle(c1, c2), method2type[method]);

    case const ('Ins^cc_index'):
      Circle c1 = getVar(gmkCommand.factor[0], gmkData);
      Circle c2 = getVar(gmkCommand.factor[1], gmkData);
      int index = getVar(gmkCommand.factor[2], gmkData);
      DNum dn = other_ins_solver.xCircleCircleTheta(c1, c2);
      return (c2.indexPoint((index == 1) ? dn.min : dn.max), method2type[method]);

    case const ('Ins^lc0'):
      Line l = getVar(gmkCommand.factor[0], gmkData);
      Conic0 c0 = getVar(gmkCommand.factor[1], gmkData);
      return (l520.xConic0Line(c0, l), method2type[method]);

    case const ('Ins^c0l'):
      Conic0 c0 = getVar(gmkCommand.factor[0], gmkData);
      Line l = getVar(gmkCommand.factor[1], gmkData);
      return (l520.xConic0Line(c0, l), method2type[method]);

    case const ('Tan^c0dp'):
      Conic0 c0 = getVar(gmkCommand.factor[0], gmkData);
      DPoint dp = getVar(gmkCommand.factor[1], gmkData);
      return (c0.tangentLineByDP(dp), method2type[method]);

    case 'L':
      Vector p1 = getVar(gmkCommand.factor[0], gmkData);
      Vector p2 = getVar(gmkCommand.factor[1], gmkData);
      return (Line.new2P(p1, p2), method2type[method]);

    case 'L:pv':
      Vector p = getVar(gmkCommand.factor[0], gmkData);
      Vector v = getVar(gmkCommand.factor[1], gmkData);
      return (Line(p, v), method2type[method]);

    case 'C':
      Vector p = getVar(gmkCommand.factor[0], gmkData);
      num r = getVar(gmkCommand.factor[1], gmkData);
      return (Circle(p, r), method2type[method]);

    case 'C:op':
      Vector o = getVar(gmkCommand.factor[0], gmkData);
      Vector p = getVar(gmkCommand.factor[1], gmkData);
      return (Circle.new2P(o, p), method2type[method]);

    case 'P^mid':
      Vector p1 = getVar(gmkCommand.factor[0], gmkData);
      Vector p2 = getVar(gmkCommand.factor[1], gmkData);
      return (p1.mid(p2), method2type[method]);

    case 'IndexP':
      dynamic obj = getVar(gmkCommand.factor[0], gmkData);
      num index = getVar(gmkCommand.factor[1], gmkData);
      return (obj.indexPoint(index), method2type[method]);

    case 'IndexDP':
      dynamic obj = getVar(gmkCommand.factor[0], gmkData);
      DNum index = getVar(gmkCommand.factor[1], gmkData);
      return (obj.indexDPoint(index), method2type[method]);

    case 'IndexQP':
      dynamic obj = getVar(gmkCommand.factor[0], gmkData);
      QNum index = getVar(gmkCommand.factor[1], gmkData);
      return (obj.indexQPoint(index), method2type[method]);

    case 'QP^deriveL':
      QPoint qp = getVar(gmkCommand.factor[0], gmkData);
      return (qp.deriveL, method2type[method]);

    case 'QP^heart':
      QPoint qp = getVar(gmkCommand.factor[0], gmkData);
      return (qp.heart, method2type[method]);

    case const ('DP^l'):
      DPoint dp = getVar(gmkCommand.factor[0], gmkData);
      return (dp.l, method2type[method]);

    case const ('DP^index'):
      DPoint dp = getVar(gmkCommand.factor[0], gmkData);
      int index = getVar(gmkCommand.factor[1], gmkData);
      return ((index == 1) ? dp.p1 : dp.p2, method2type[method]);

    case const ('QP'):
      DPoint dp1 = getVar(gmkCommand.factor[0], gmkData);
      DPoint dp2 = getVar(gmkCommand.factor[1], gmkData);
      return (QPoint.new2DP(dp1, dp2), method2type[method]);

    case const ('QP^xl1'):
      QPoint qp = getVar(gmkCommand.factor[0], gmkData);
      return (qp.xl1, method2type[method]);

    case const ('QP^xl2'):
      QPoint qp = getVar(gmkCommand.factor[0], gmkData);
      return (qp.xl2, method2type[method]);

    case const ('XL^p'):
      XLine xl = getVar(gmkCommand.factor[0], gmkData);
      return (xl.p, method2type[method]);

    case 'C0':
      Vector p0 = getVar(gmkCommand.factor[0], gmkData);
      Vector p1 = getVar(gmkCommand.factor[1], gmkData);
      Vector p2 = getVar(gmkCommand.factor[2], gmkData);
      return (Conic0(p0, p1 - p0, p2 - p0), method2type[method]);

    case const ('Poly'):
      List ds = getVarList(gmkCommand.factor, gmkData);
      for (var key in ds) {
        // print(key.toString());
      }
      return (Polygon(ds.cast<Vector>()), method2type[method]);

    default:
      return (null, 'e-findMethod:none');
  }
}

Map<String, String> method2type = {
  'N': 'num',
  'N^add': 'num',
  'N^sub': 'num',
  'N^ops': 'num',
  'N^mul': 'num',
  'N^div': 'num',
  'N^sin': 'num',
  'N^cos': 'num',
  'N^tan': 'num',
  'N^abs': 'num',
  'N^sgn': 'num',
  'DN': 'DNum',
  'TN': 'TNum',
  'QN': 'QNum',
  'P': 'Vector',
  'P:v': 'Vector',
  'P^mid': 'Vector',
  'L': 'Line',
  'L:pv': 'Line',
  'Ins^ll': 'Vector',
  'Ins^cl_index': 'Vector',
  'Ins^c0l': 'DPoint',
  'Ins^lc0': 'DPoint',
  'Tan^c0dp': 'XLine',
  'C': 'Circle',
  'C:op': 'Circle',
  'Ins^cc': 'DPoint',
  'Ins^lc': 'DPoint',
  'Ins^cl': 'DPoint',
  'Ins^cc_index': 'Vector',
  'IndexP': 'Vector',
  'IndexDP': 'DPoint',
  'IndexQP': 'QPoint',
  'DP^index': 'Vector',
  'QP^deriveL': 'Line',
  'QP^heart': 'Vector',
  'DP^l': 'Line',
  'QP': 'QPoint',
  'QP^xl1': 'XLine',
  'QP^xl2': 'XLine',
  'XL^p': 'Vector',
  'C0': 'Conic0',
  'Poly': 'Polygon',
};



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
