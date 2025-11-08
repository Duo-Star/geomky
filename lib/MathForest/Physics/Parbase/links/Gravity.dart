import '../Particle.dart';
import '../../../Geometry/D2/Linear/Vector.dart';


class Gravity {
  num G = 6.67e-11;
  Vector g = Vector(0,-9.8);

  Gravity(this.G);

  Vector pLINKp(Particle pa, Particle pb){
    Vector dp = pa.p - pb.p;
    num f = G * (pa.m * pb.m) / (dp.pow2);
    return dp.unit * f;
  }

  Vector pLINKEarth(Particle p){
    return g * p.m;
  }



}