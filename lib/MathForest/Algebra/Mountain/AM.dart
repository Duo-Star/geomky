//
import 'dart:math' as math;
import '../Functions/Main.dart' as funcs;
import 'AMlib.dart' as am_lib;

// Algebra Mountain
// 代数系统
class Am {
  // F - 函数名
  // factor - 因子
  String F = '-unk_function';
  List<dynamic> factor = [];

  // 构造函数
  Am(this.F, this.factor);

  // 新建符号
  static symbol(String s) {
    return Am("#symbol", [s]);
  }

  // 新建数字
  static number(num x) {
    return Am('#num', [am_lib.decimalToFraction(x)]);
  }

  static isAtom(dynamic v) {
    switch (v.runtimeType) {
      case const (int):
        return true;
      case const (double):
        return true;
      case const (String):
        return true;
    }
    return false;
  }


  get isAtomAm {
    bool is_ = true;
    for (var i in factor) {
      is_ = isAtom(i);
    }
    return is_;
  }

  static toAm(dynamic v) {
    dynamic r;
    switch (v.runtimeType) {
      case const (Am):
        r = v;
      case const (int):
        r = number(v);
      case const (double):
        r = number(v);
      case const (String):
        r = symbol(v);
    }
    return r;
  }

  Am fm(String f, List<dynamic> fac) {
    List<Am> newF = [];
    for (var i in fac) {
      newF.add(toAm(i));
    }
    return Am(f, newF);
  }

  Am add(dynamic x) {
    return fm('add', [this, x]);
  }

  @override
  String toString() {
    String fs = '';
    for (var i in factor) {
      fs = '$fs ${i.toString()} ';
    }
    return 'Am[$F, <$fs>]';
  }
}


