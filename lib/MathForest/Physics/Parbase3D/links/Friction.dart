import '../Particle3D.dart';
import '../../../Geometry/D3/Linear/Vec3.dart';

class Friction {
  num f = .5;
  num s = 1;
  String mode = '';

  List<String> modeList = ['Static', 'Air', 'ResV', 'Silky'];

  Friction(this.f,this.s,this.mode);

  Vec3 pLINK(Particle3D p) {
    switch (mode){
      case 'Static':
        return -p.v.unit*f;
      case 'Air':
        return -p.v * p.v.len * s;
    }
    return Vec3();
  }
}
