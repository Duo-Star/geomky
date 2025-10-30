library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../Monxiv/gOBJStyle.dart' as gStyle;

import 'GMKCommand.dart';
import 'GMKStructure.dart';
import 'GMKLib.dart' as g_lib;

import '../../Linear/Vector.dart';
import '../../Conic/Circle.dart';
import '../../../../Algebra/Functions/Main.dart' as funcs;

// 匹配删除 ``任意内容`` 格式的注释
String removeComments(String input) {
  // .*? 表示非贪婪匹配，可以跨行匹配（因为使用了 dotAll: true）
  String result = '';
  result = input.replaceAll(RegExp(r'``.*?``', multiLine: true, dotAll: true), '');
  result = result.replaceAll(RegExp(r'/\*.*?\*/', multiLine: true, dotAll: true), '');
  result = result.replaceAll(RegExp(r'//.*$', multiLine: true), '');
  return result;
}

// 截取字符
// print(GMKCompiler.subStringBetween('input', 'i', 't'));
// -> npu
String subStringBetween(String input, String startChar, String endChar) {
  int startIndex = input.indexOf(startChar);
  int endIndex = input.indexOf(endChar);
  if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
    return ''; // 如果没找到起始或结束字符，返回空字符串
  }
  return input.substring(startIndex + startChar.length, endIndex);
}

/*
解析参数列  即：用逗号隔开的元素，传入 string 输出 List<dynamic>
这是一个运行实例
List<dynamic> fac = GMKCompiler.str2Factor(
'1, 3.14, a, <b>, .T, <3,4>, <.PI,.PI>, .I');
for (var item in fac) {
   print('$item, type:${item.runtimeType}');
}

1,                             type:int
3.14,                          type:double
a,                             type:String
#label<b>,                     type:String
true,                          type:bool
Vector(3, 4),                  type:Vector
Vector(3.141592653589793, 3.141592653589793), type:Vector
Vector(1, 0.0),                type:Vector
                         */
/*
String.trim 移除字符串首尾的所有空白字符
返回一个新的字符串，原始字符串不会被修改。仅移除首尾空白字符，字符串中间的任何空白字符都会保留
空白字符定义: 包括空格、制表符(\t)、换行符(\n)等
 */

List<dynamic> str2Factor(String str) {
  List<dynamic> factors = [];
  str = str.trim();
  // 按逗号分割，但要处理 < > 内的逗号
  List<String> parts = [];
  StringBuffer currentPart = StringBuffer();
  bool inAngleBrackets = false;
  //
  for (int i = 0; i < str.length; i++) {
    String char = str[i];
    if (char == '<') {
      inAngleBrackets = true;
      currentPart.write(char);
    } else if (char == '>') {
      inAngleBrackets = false;
      currentPart.write(char);
    } else if (char == ' ' && !inAngleBrackets) {
      // 不在尖括号内的逗号作为分隔符
      String part = currentPart.toString().trim();
      if (part.isNotEmpty) {
        parts.add(part);
      }
      currentPart.clear();
    } else {
      currentPart.write(char);
    }
  }
  // 添加最后一部分
  String lastPart = currentPart.toString().trim();
  if (lastPart.isNotEmpty) {
    parts.add(lastPart);
  }
  // 解析每个部分
  for (String part in parts) {
    part = part.trim();
    if (part.isEmpty) continue;
    if (part.startsWith('<') && part.endsWith('>')) {
      String content = part.substring(1, part.length - 1);
      if (content.contains(' ')) {
        //向量
        var f = str2Factor(content.trim());
        factors.add(Vector(f[0], f[1]));
      } else {
        //标签
        factors.add('#label<${content.trim()}>');
      }
    } else {
      // 尝试解析为布尔值、数字或保持原字符串
      dynamic value = _parseValue(part);
      factors.add(value);
    }
  }
  return factors;
}

// 解析值
dynamic _parseValue(String value) {
  if (value == '.T') return true;
  if (value == '.F') return false;
  if (value == '.O') return Vector.zero;
  if (value == '.I') return Vector.i;
  if (value == '.J') return Vector.j;
  if (value == '.uC') return Circle(Vector.zero, 1);
  if (value == '.PI') return math.pi;
  if (value == '.E') return math.e;
  if (value == '.INF') return 1 / 0;
  if (value == '.NAN') return 0 / 0;
  // 尝试解析为 int
  int? intValue = int.tryParse(value);
  if (intValue != null) return intValue;
  // 尝试解析为 double
  double? doubleValue = double.tryParse(value);
  if (doubleValue != null) return doubleValue;
  // 无法解析，返回原始字符串
  return value;
}


String extractAfter(String input, String? sign) {
  String sign_ = sign??' of ';
  final index = input.indexOf(sign_);
  if (index == -1) return '';
  final startIndex = index + sign_.length;
  if (startIndex >= input.length) return '';
  return input.substring(startIndex);
}


GMKStructure goCompiler(String source) {
  String source_ = removeComments(source);
  GMKStructure structure = GMKStructure.newBlank();
  List<String> lines = source_.split('\n');
  for (var line in lines) {
    if (line.startsWith('@')) {
      try {
        String label = subStringBetween(line, '@', ' is ').trim();
        String method = subStringBetween(line, ' is ', ' of ').trim();
        List<dynamic> factor = str2Factor(extractAfter(line, ' of '));
        //
        GMKCommand cmd = GMKCommand(method, label, factor);
        cmd.type = (g_lib.lib[method]?[0]) ?? '?unType';
        gStyle.GOBJStyle style = gStyle.GOBJStyle.apply(cmd.type);
        cmd.style = style;
        structure.addStep(cmd);
      }  catch (e, stackTrace) {
        Exception('错误: $e');
        Exception('堆栈跟踪: $stackTrace');
      }
    } else if (line.startsWith('-@')) {
      try {
        String label = subStringBetween(line, '@', ' is ').trim();
        String method = subStringBetween(line, ' is ', ' of ').trim();
        List<dynamic> factor = str2Factor(extractAfter(line, ' of '));
        //
        GMKCommand cmd = GMKCommand(method, label, factor);
        cmd.type = (g_lib.lib[method]?[0]) ?? '?unType';
        gStyle.GOBJStyle style = gStyle.GOBJStyle.apply(cmd.type);
        cmd.style = style..show=false;
        structure.addStep(cmd);
      }  catch (e, stackTrace) {
        Exception('错误: $e');
        Exception('堆栈跟踪: $stackTrace');
      }
    } else if (line.startsWith('#')) {
      String label = subStringBetween(line, '#', ' ').trim();
      gStyle.GOBJStyle? oldStyle = structure.step[label]?.style;
      gStyle.GOBJStyle style = styleCompiler(oldStyle!, line);

      structure.step[label]?.style = style;
      if (kDebugMode) {
        print('set style<$label>:${style.toString()}');
      }
    }
  }

  return structure;
}

// 吸附到数字
String adsorbConstNum(num n) {
  if (funcs.abs(n - math.pi) < 1e-10) {
    return '.PI';
  } else if (funcs.abs(n - math.e) < 1e-10) {
    return '.E';
  }
  String s = n.toString();
  if (s == 'NaN') {
    return '.NAN';
  } else if (s == 'Infinity') {
    return '.INF';
  } else {
    return s;
  }
}

// 吸附到常向量，以及分量数字
String adsorbConstVec(Vector v) {
  if (v.x == 1.0 && v.y == 0.0) {
    return '.I';
  } else if (v.x == 0.0 && v.y == 1.0) {
    return '.J';
  } else if (v.x == 0.0 && v.y == 0.0) {
    return '.O';
  } else {
    return '<${adsorbConstNum(v.x)} ${adsorbConstNum(v.y)}>';
  }
}

// 参数转字符，用于数据序列化
String factor2Str(List<dynamic> factor) {
  String str = '';
  for (int i = 0; i < factor.length; i++) {
    dynamic item = factor[i];
    String division = (i + 1 == factor.length) ? "" : ' ';
    switch (item.runtimeType) {
      case const (String):
        if (item.startsWith('#label')) {
          str = '$str<${subStringBetween(item, '<', '>')}>$division';
        } else {
          str = '$str$item$division';
        }
      case const (Vector):
        str = '$str${adsorbConstVec(item)}$division';
      case const (double):
        String s = adsorbConstNum(item);
        str = '$str$s$division';
      case const (int):
        String s = adsorbConstNum(item);
        str = '$str$s$division';
      case const (bool):
        str = '$str${item ? '.T' : '.F'}$division';
      default:
        String s = item.toString();
        str = '$str$s$division';
    }
  }
  return str;
}

String gmkCommand2Str(GMKCommand gc) {
  return '@${gc.label} is ${gc.method} of ${factor2Str(gc.factor)}';
}


gStyle.GOBJStyle styleCompiler(gStyle.GOBJStyle oldStyle, String sCode) {
  gStyle.GOBJStyle result = oldStyle;
  String label = subStringBetween(sCode, '#', ' ').trim();
  String sFactor = extractAfter(sCode, '#$label');
  List<dynamic> factor = str2Factor(sFactor);
  for (int i = 0; i < factor.length; i++) {
    dynamic itemFactor = factor[i];
    //print(itemFactor.runtimeType);
    if (gStyle.color.contains(itemFactor)) {
      result.color = gStyle.colors[itemFactor]!;
    } else if (gStyle.shape.contains(itemFactor)) {
      result.shape = itemFactor;
    } else if (itemFactor.runtimeType == double || itemFactor.runtimeType == int) {
      result.size = itemFactor;
    }  else if (gStyle.show.contains(itemFactor)) {
      result.show = (itemFactor == 'show');
    } else if (gStyle.labelShow.contains(itemFactor)) {
      result.labelShow = (itemFactor == 'labelShow');
    } else if (gStyle.fertileWaveLink.contains(itemFactor)) {
      result.fertileWaveLink = (itemFactor == 'fertileWaveLink');
    }
  }
  return result;
}








/*
String str =
    '1, 1.23, .PI, .NAN, .INF,  a, <b>, .T, <3,4>, <1.23, 4.56>, <.PI, .PI>, <.NAN, .INF>, .I;';
print('-----------原始-----------');
print(str);

print('-----------参数列-----------');
List<dynamic> fac = GMKCompiler.str2Factor(str);
for (var item in fac) {
print('$item, type:${item.runtimeType}');
}

print('-----------还原-----------');
print(GMKCompiler.factor2Str(fac));


-----------原始-----------
1, 1.23, .PI, .NAN, .INF,  a, <b>, .T, <3,4>, <1.23, 4.56>, <.PI, .PI>, <.NAN, .INF>, .I;
-----------参数列-----------
1, type:int
1.23, type:double
3.141592653589793, type:double
NaN, type:double
Infinity, type:double
a, type:String
#label<b>, type:String
true, type:bool
Vector(3, 4), type:Vector
Vector(1.23, 4.56), type:Vector
Vector(3.141592653589793, 3.141592653589793), type:Vector
Vector(NaN, Infinity), type:Vector
Vector(1, 0.0), type:Vector
-----------还原-----------
1, 1.23, .PI, .NAN, .INF, a, <b>, .T, <3, 4>, <1.23, 4.56>, <.PI, .PI>, <.NAN, .INF>, .I;






 onPressed: () {
                        String msg = '';
                        void m(String str) {
                          msg = '$msg\n$str';
                        }

                        String str =
                            '1, 1.23, .PI, .NAN, .INF,  a, <b>, .T, <3,4>, <1.23, 4.56>, <.PI, .PI>, <.NAN, .INF>, .I;';
                        m('-----------原始-----------');
                        m(str);

                        m('-----------参数列-----------');
                        List<dynamic> fac = GMKCompiler.str2Factor(str);
                        for (var item in fac) {
                          m('$item, type:${item.runtimeType}');
                        }

                        m('-----------还原-----------');
                        m(GMKCompiler.factor2Str(fac));
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(msg)));
                      },

 */
