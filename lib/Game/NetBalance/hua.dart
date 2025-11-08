import 'dart:math';
import '../../MathForest/main.dart';

class Hua {
  Particle p1 = Particle(Vector(), Vector(), Vector());
  Particle p2 = Particle(Vector(), Vector(), Vector());
  //
  DNum dTheta = DNum(.5 * pi, .5 * pi);
  DNum dFire = DNum(1, 1);
  //
  Spring sp = Spring(1e4, 1);

  // 私有构造函数
  Hua();

  //
  factory Hua.newHua(Vector p, num l) {
    Hua hua = Hua();
    hua.p1.p = p + Vector(-l / 2);
    hua.p2.p = p + Vector(l / 2);
    hua.sp.l = l;
    return hua;
  }

  //
  Vector getFireForce(int n) {
    if (n == 1) {
      return Vector.newAL(dTheta.n1, dFire.n1);
    }
    return Vector.newAL(dTheta.n2, dFire.n2);
  }

  //
  void update(PEnv env) {
    Vector f12 = sp.pLINKp(p1, p2);
    p1.setF(-f12 + getFireForce(1) + env.g);
    p2.setF(f12 + getFireForce(2) + env.g);
    p1.update(env.dt);
    p2.update(env.dt);
  }
}
