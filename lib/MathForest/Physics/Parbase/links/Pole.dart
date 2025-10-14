import '../Particle.dart';
import '../../../Geometry/D3/Linear/Vec3.dart';
import '../../../Algebra/Functions/Main.dart' as funcs;

class Pole {
  num k = 5e3;
  num l = 1;

  Pole(this.k, this.l);

  Vec3 pLINKp(Particle pa, Particle pb){
    Vec3 dp = pa.p - pb.p;
    num f = funcs.openNNum(dp.len-l)*k;
    return dp.unit * f;
  }
}