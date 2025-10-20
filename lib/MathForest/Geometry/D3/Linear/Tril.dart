// Tril 空间汆角

import 'Vec3.dart';
import 'Triangle3.dart';

/*
空间中的基本元素，四面体的构件
汆的几何形状：在空间中共起点而不共面的三条射线
重要建模，为其他空间计算提供函数
 */

class Tril {
  Vec3 p;
  Vec3 a;
  Vec3 b;
  Vec3 c;

  // 创建汆角
  Tril([Vec3? p, Vec3? v1, Vec3? v2, Vec3? v3])
    : p = p ?? Vec3.zero,
      a = v1?.unit ?? Vec3.i,
      b = v2?.unit ?? Vec3.j,
      c = v3?.unit ?? Vec3.k;

  // 衡棱线
  Vec3 get balanceArrisV {
    return (c - a).cross(b - a);
  }

  // 衡面线
  /* 汆论记载：
        一个汆的衡面线，与其子汆的衡棱线重合
   */
  Vec3 get balancePlaneV {
    return child.balanceArrisV;
  }

  // 贯线（最好算的一集）
  Vec3 get throughV {
    return a + b + c;
  }

  // a的单位棱高平方
  num get hAPow2 {
    return 1;
  }

  // 子汆（你在期待孙汆吗）
  Tril get child {
    return Tril(p, c.cross(b).unit, b.cross(a).unit, a.cross(c).unit);
  }

  // 满足你！
  Tril get grandson {
    return child.child;
  }

  //
  Triangle3 get triangle {
    return Triangle3(p+a, p+b, p+c);
  }

}
