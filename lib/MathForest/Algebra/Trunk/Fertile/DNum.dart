//
import 'dart:math' as math;

/*

 */
import 'dart:math' as math;

class DNum {
  dynamic n1;
  dynamic n2;

  DNum([dynamic n1, dynamic n2]) : n1 = n1 ?? -1, n2 = n2 ?? 1;

  num get min => math.min(n1 as num, n2 as num);

  num get max => math.max(n1 as num, n2 as num);

  DNum operator +(DNum other) {
    return DNum(n1 + other.n1, n2 + other.n2);
  }

  DNum operator -(DNum other) {
    return DNum(n1 - other.n1, n2 - other.n2);
  }

  DNum operator *(DNum other) {
    return DNum(n1 * other.n1, n2 * other.n2);
  }

  DNum operator /(DNum other) {
    return DNum(n1 / other.n1, n2 / other.n2);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DNum &&
          runtimeType == other.runtimeType &&
          n1 == other.n1 &&
          n2 == other.n2;

  @override
  int get hashCode => n1.hashCode ^ n2.hashCode;

  @override
  String toString() {
    return 'DNum(${n1.toString()}, ${n2.toString()})';
  }
}
