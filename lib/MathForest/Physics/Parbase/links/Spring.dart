import '../Particle.dart';
import '../../../Geometry/D2/Linear/Vector.dart';

class Spring {
  num k = 5e3;
  num l = 1;

  Spring(this.k, this.l);

  Vector pLINKp(Particle pa, Particle pb){
    Vector dp = pa.p - pb.p;
    num f = (dp.len-l)*k;
    return dp.unit * f;
  }
}