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
import '../Monxiv/GraphOBJ.dart';

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
  'DN': [
    //駢数
    'DNum',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      num n2 = getVar(factor[1], data);
      return DNum(n1, n2);
    },
  ],
  'TN': [
    //汆数
    'TNum',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      num n2 = getVar(factor[1], data);
      num n3 = getVar(factor[2], data);
      return TNum(n1, n2, n3);
    },
  ],
  'QN': [
    //合数
    'QNum',
    (factor, data) {
      num n1 = getVar(factor[0], data);
      num n2 = getVar(factor[1], data);
      num n3 = getVar(factor[2], data);
      num n4 = getVar(factor[3], data);
      return QNum(n1, n2, n3, n4);
    },
  ],
  'P': [
    //点（坐标创建）
    'Vector',
    (factor, data) {
      num x = getVar(factor[0], data);
      num y = getVar(factor[1], data);
      return Vector(x, y);
    },
  ],
  'P:v': [
    //从向量创建点
    'Vector',
    (factor, data) {
      Vector p = getVar(factor[0], data);
      return p;
    },
  ],
  'P^mid': [
    //中点
    'Vector',
    (factor, data) {
      Vector p1 = getVar(factor[0], data);
      Vector p2 = getVar(factor[1], data);
      return p1.mid(p2);
    },
  ],
  'L': [
    //直线（点向创建）
    'Line',
        (factor, data) {
      Vector p = getVar(factor[0], data);
      Vector v = getVar(factor[1], data);
      return Line(p, v);
    },
  ],
  'L:2p': [
    //直线（两点创建）
    'Line',
    (factor, data) {
      Vector p1 = getVar(factor[0], data);
      Vector p2 = getVar(factor[1], data);
      return Line.new2P(p1, p2);
    },
  ],
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
  'Tan^c0dp': [
    //椭圆上骈点的切线（得到交叉直线）
    'XLine',
    (factor, data) {
      Conic0 c0 = getVar(factor[0], data);
      DPoint dp = getVar(factor[1], data);
      return c0.tangentLineByDP(dp);
    },
  ],
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
  'QP': [
    //创建合点
    'QPoint',
    (factor, data) {
      DPoint dp1 = getVar(factor[0], data);
      DPoint dp2 = getVar(factor[1], data);
      return QPoint.new2DP(dp1, dp2);
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
  'XL^p': [
    //计算叉线中心
    'Vector',
    (factor, data) {
      XLine xl = getVar(factor[0], data);
      return xl.p;
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
  'Poly': [
    //多边形
    'Polygon',
    (factor, data) {
      List ds = getVarList(factor, data);
      return Polygon(ds.cast<Vector>());
    },
  ],
};
