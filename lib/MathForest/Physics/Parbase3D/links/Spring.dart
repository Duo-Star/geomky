import '../Particle3D.dart';
import '../../../Geometry/D3/Linear/Vec3.dart';

class Spring {
  num k = 5e3;
  num l = 1;

  Spring(this.k, this.l);

  Vec3 pLINKp(Particle3D pa, Particle3D pb){
    Vec3 dp = pa.p - pb.p;
    num f = (dp.len-l)*k;
    return dp.unit * f;
  }
}