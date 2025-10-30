//
import 'dart:math';
import 'DNum.dart';
/*

 */

class QNum {
  dynamic n1;
  dynamic n2;
  dynamic n3;
  dynamic n4;

  QNum([dynamic n1, dynamic n2, dynamic n3, dynamic n4])
    : n1 = n1 ?? -1,
      n2 = n2 ?? 1,
      n3 = n3 ?? 2,
      n4 = n4 ?? 3;



  static harmonic(DNum dn, num t) {
    num a = dn.n1;
    num b = dn.n2;
    num m = (t * b - a) / (t - 1);
    num n = (t * b + a) / (t + 1);
    return QNum(a, m, b, n);
  }

  @override
  String toString() {
    return 'QNum(${n1.toString()}, ${n2.toString()}, ${n3.toString()}, ${n4.toString()})';
  }
}
