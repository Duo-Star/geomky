import '../Particle.dart';
import '../../../Geometry/D3/Linear/Vec3.dart';

class Electromagnetic {
  num k = 8.98e9;

  Electromagnetic(this.k);

  Vec3 pLINKp(Particle pa, Particle pb){
    Vec3 dp = pa.p - pb.p;
    num f = k * (pa.q * pb.q) / (dp.pow2);
    return dp.unit * f;
  }
}