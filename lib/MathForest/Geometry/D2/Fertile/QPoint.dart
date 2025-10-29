// 合点

/*

 */

import '../Linear/Line.dart';
import '../Linear/Vector.dart';
import 'DPoint.dart';
import '../Intersection/Line520.dart' as l520;
import 'DXLine.dart';
import '../Conic/XLine.dart';


class QPoint {
  //顺序四点
  Vector p1 = Vector ();
  Vector p2 = Vector ();
  Vector p3 = Vector ();
  Vector p4 = Vector ();

  //构建
  QPoint(this.p1, this.p2, this.p3, this.p4);

  static new2DP(DPoint dp1, DPoint dp2) => QPoint(dp1.p1, dp2.p1, dp1.p2, dp2.p2);

  //分对成为两个骈点
  DPoint get dP1 => DPoint(p1, p3);
  DPoint get dP2 => DPoint(p2, p4);

  //对定点连线
  Line get l1 => dP1.l;
  Line get l2 => dP2.l;

  //中心 - 对定点连线交点
  Vector get heart => l520.xLineLine(l1, l2);

  //四条直线
  Line get l12 => Line.new2P(p1, p2);
  Line get l14 => Line.new2P(p1, p4);
  Line get l32 => Line.new2P(p3, p2);
  Line get l34 => Line.new2P(p3, p4);

  // 两种连接
  XLine get xl1 => XLine.new2L(l14, l32);
  XLine get xl2 => XLine.new2L(l12, l34);

  //索引
  Vector indexPoint(num i){
    if (i==1) {
      return p1;
    }else if (i==2) {
      return p2;
    }else if (i==3) {
      return p3;
    }
    return p4;
  }

  //衍骈点
  DPoint get deriveDP => DPoint(l520.xLineLine(l14, l32), l520.xLineLine(l12, l34));

  //衍线
  Line get deriveL => deriveDP.l;

  //DXLine 骈叉线
  DXLine get net {
    Vector deriveDP1 = l520.xLineLine(l14, l32);
    Vector deriveDP2 = l520.xLineLine(l12, l34);
    return DXLine(
        XLine(deriveDP1, p1 - deriveDP1, p2 - deriveDP1),
        XLine(deriveDP2, p1 - deriveDP1, p4 - deriveDP1)
    );
  }



}


