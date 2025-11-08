import '../Particle.dart';
import '../../../Geometry/D2/Linear/Vector.dart';

class Electromagnetic {
  num k = 8.98e9;

  Electromagnetic(this.k);

  Vector pLINKp(Particle pa, Particle pb){
    Vector dp = pa.p - pb.p;
    num f = k * (pa.q * pb.q) / (dp.pow2);
    return dp.unit * f;
  }
}