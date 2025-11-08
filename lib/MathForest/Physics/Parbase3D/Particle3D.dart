import '../../Geometry/D3/Linear/Vec3.dart';

class Particle3D {
  Vec3 p = Vec3();
  Vec3 v = Vec3();
  Vec3 a = Vec3();
  num m = 1;
  num q = 1;

  Particle3D(this.p, this.v, this.a);

  bool update(num dt) {
    v = v  + a * dt;
    p = p  + v * dt;
    return true;
  }

  bool setF (Vec3 f){
    a = f * (1/m);
    return true;
  }


}