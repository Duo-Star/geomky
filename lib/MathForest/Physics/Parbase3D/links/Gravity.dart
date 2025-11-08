import '../Particle3D.dart';
import '../../../Geometry/D3/Linear/Vec3.dart';

class Gravity {
  num G = 6.67e-11;
  Vec3 g = Vec3(0,0,-9.8);

  Gravity(this.G);

  Vec3 pLINKp(Particle3D pa, Particle3D pb){
    Vec3 dp = pa.p - pb.p;
    num f = G * (pa.m * pb.m) / (dp.pow2);
    return dp.unit * f;
  }

  Vec3 pLINKEarth(Particle3D p){
    return g * p.m;
  }



}