//
import 'dart:math' as math;

/*

 */

class DNum {
  dynamic n1;
  dynamic n2;

  DNum([dynamic n1, dynamic n2]):
        n1 = n1 ?? -1,
        n2 = n2 ?? 1;

  num get min => math.min(n1, n2);
  num get max => math.max(n1, n2);

@override
  String toString() {
    return 'DNum(${n1.toString()}, ${n2.toString()})';
  }

}