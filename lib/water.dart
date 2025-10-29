import 'dart:math';
import 'package:flutter/foundation.dart';
import 'MathForest/main.dart';

void main() {
  Am a1 = Am.symbol('x');
  Am a2 = a1.add(1/7+4/5);
  print(a2.toString());

}
