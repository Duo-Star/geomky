//

import '../Linear/Line.dart';
import '../Linear/Vector.dart';
//
import '../Fertile/DPoint.dart';
//
import '../../../Algebra/Trunk/Fertile/DNum.dart';

/*

 */

class XLine {
  Vector  p;
  Vector  u;
  Vector  v;

  //XLine: Line(p, u) ^^ Line(p, v)
  XLine([Vector ? p, Vector ? u, Vector ? v]):
        p = p ?? Vector (),
        u = u ?? Vector (1,  1),
        v = v ?? Vector (1, -1);

  Line get l1 => Line(p, u);
  Line get l2 => Line(p, v);

  static newPDP(Vector  p, DPoint dp) => XLine(p, dp.p1-p, dp.p2-p);


}