//Triangle
import 'dart:math';
import 'Vec3.dart';

class Triangle{
  Vec3 a;
  Vec3 b;
  Vec3 c;

  Triangle([Vec3? a, Vec3? b, Vec3? c]): //三个点
        a = a ?? Vec3.i,
        b = b ?? Vec3.j,
        c = c ?? Vec3.k;

  Vec3 get u => a-c;
  Vec3 get v => b-c;

  num get dotUV => u.dot(v);
  num get powU => u.pow2;
  num get powV => v.pow2;

  num get aLen => (b - c).len;// 边a的长度
  num get bLen => (a - c).len;// 边b的长度
  num get cLen => (a - b).len;// 边c的长度

  get area => u.cross(v).len / 2;
  get cir => aLen + bLen + cLen;

  Vec3 get iO { //内心
    return (a * aLen + b * bLen + c * cLen) / cir;
  }

  Vec3 get oO { //外心
    num m = 2 * ( pow(dotUV,2) - powV*powU );
    num uL = (powV*(dotUV-powU)) / m;
    num vL = (powU*(dotUV-powV)) / m;
    return c + u*uL + v*vL;
  }
  Vec3 get hO { //垂心
    num m =  pow(dotUV,2) - powV*powU;
    num uL = (dotUV*(dotUV-powV)) / m;
    num vL = (dotUV*(dotUV-powU)) / m;
    return c + u*uL + v*vL;
  }
  Vec3 get gO { //重心
    return (a + b + c)*(1/3);
  }


}