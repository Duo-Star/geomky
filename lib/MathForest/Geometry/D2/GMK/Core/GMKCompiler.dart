library;

import 'dart:math' as math;
import '../../Linear/Vector.dart';
import '../../Conic/Circle.dart';
import '../../../../Algebra/Functions/Main.dart' as funcs;

// 匹配删除 ``任意内容`` 格式的注释
String removeComments(String input) {
  // .*? 表示非贪婪匹配，可以跨行匹配（因为使用了 dotAll: true）
  final regex = RegExp(r'``.*?``', multiLine: true, dotAll: true);
  return input.replaceAll(regex, '');
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
List<dynamic> str2Factor(String str) {
  List<dynamic> factors = [];
  // 移除末尾的分号和空格
  str = str.trim(); // 移除空格
  if (str.endsWith(';')) {
    str = str.substring(0, str.length - 1).trim();
  }
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
    } else if (char == ',' && !inAngleBrackets) {
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
      // 字符串类型，去掉尖括号
      String content = part.substring(1, part.length - 1);
      if (content.contains(',')) {
        var f = str2Factor(content.trim());
        factors.add(Vector(f[0], f[1]));
      } else {
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

bool goCompiler(String source) {
  String source_ = removeComments(source);
  List<String> lines = source_.split('\n');
  for (var line in lines) {
    //GMKProcess(this.method, this.label, this.factor);
    if (line.startsWith('@')) {
      //剔除首尾空格 - trim()
      try {
        String label = subStringBetween(line, '@', ' is ').trim();
        String method = subStringBetween(line, ' is ', ' of ').trim();
        List<dynamic> factor = str2Factor(subStringBetween(line, ' of ', ';'));
        //  structure.addStep(GMKProcess(method, label, factor));
      } on RangeError catch (e) {
        Exception('字符串解析错误: 在行中找不到必要的分隔符');
        Exception('原始行: "$line"');
        Exception('错误详情: $e');
      } on NoSuchMethodError catch (e) {
        Exception('方法调用错误: 可能在 null 上调用方法');
        Exception('请检查 substringBetween 的返回值');
        Exception('错误详情: $e');
      } on ArgumentError catch (e) {
        Exception('参数错误: 传递给函数的参数无效');
        Exception('错误详情: $e');
      } on FormatException catch (e) {
        Exception('格式错误: 数据格式不符合预期');
        Exception('错误详情: $e');
      } on TypeError catch (e) {
        Exception('类型错误: 参数类型不匹配');
        Exception('错误详情: $e');
      } catch (e, stackTrace) {
        Exception('未知错误: $e');
        Exception('堆栈跟踪: $stackTrace');
      }
    }
  }

  return true;
}

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

String adsorbConstVec(Vector v) {
  if (v.x==1.0 && v.y==0.0){
    return '.I';
  } else if (v.x==0.0 && v.y==1.0){
    return '.J';
  } else if (v.x==0.0 && v.y==0.0){
    return '.O';
  } else {
    return '<${adsorbConstNum(v.x)}, ${adsorbConstNum(v.y)}>';
  }
}


String factor2Str(List<dynamic> factor) {
  String str = '';
  for (int i = 0; i < factor.length; i++) {
    dynamic item = factor[i];
    String division = (i + 1 == factor.length) ? ";" : ',';
    switch (item.runtimeType) {
      case const (String):
        if (item.startsWith('#label')) {
          str = '$str<${subStringBetween(item, '<', '>')}>$division ';
        } else {
          str = '$str$item$division ';
        }
      case const (Vector):
        str = '$str${adsorbConstVec(item)}$division ';
      case const (double):
        String s = adsorbConstNum(item);
        str = '$str$s$division ';
      case const (int):
        String s = adsorbConstNum(item);
        str = '$str$s$division ';
      case const (bool):
        str = '$str${item?'.T':'.F'}$division ';
      default:
        String s = item.toString();
        str = '$str$s$division ';
    }
  }
  return str;
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
