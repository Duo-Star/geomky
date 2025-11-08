import '../../Geometry/D2/Linear/Vector.dart';

class Particle {
  Vector p = Vector();
  Vector v = Vector();
  Vector a = Vector();
  num m = 1;
  num q = 1;

  Particle(this.p, this.v, this.a);

  bool update(num dt) {
    v = v  + a * dt;
    p = p  + v * dt;
    return true;
  }

  bool setF (Vector f){
    a = f * (1/m);
    return true;
  }


}