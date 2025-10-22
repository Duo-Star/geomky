// 几何数据
import 'GMKData.dart';
// 几何结构
import 'GMKStructure.dart';
// 单步命令
import 'GMKCommand.dart';
// 编译器
import 'GMKCompiler.dart' as compiler;
// 方法集合
import 'GMKLib.dart' as lib;
// 几何对象
import '../Monxiv/GraphOBJ.dart';

class GMKCore {
  GMKStructure gmkStructure = GMKStructure.newBlank();
  GMKData gmkData = GMKData({
    'time': GraphOBJ(0.5, 'time', 'num <TIME>')
  });
  num t = 0 ;

  bool init() {
    return true;
  }

  GMKStructure loadCode(String code) {
    gmkStructure = compiler.goCompiler(code);
    return gmkStructure;
  }

  String generatedCode() {
    String source = '``这是标准化生成的gmk-source``';
    int structureStepCount = gmkStructure.stepCount;
    Function factor2Str = compiler.factor2Str;
    for (var i = 1; i <= structureStepCount; i++) {
      GMKCommand igp = gmkStructure.indexStep(i);
      source =
          '$source\n@${igp.label} is ${igp.method} of ${factor2Str(igp.factor)}';
    }
    return source;
  }

  String printStructure() {
    String s = '';
    for (var item in gmkStructure.step) {
      String f = '';
      for (var fi in item.factor) {
        f = '$f[${fi.toString()}, ${fi.runtimeType}]  ';
      }
      s = '$s\nlabel:${item.label}, method:${item.method}, factor: $f';
    }
    return s;
  }

  GMKData run(num t) {
    int structureStepCount = gmkStructure.stepCount;
    for (var i = 1; i <= structureStepCount; i++) {
      GMKCommand itemGMKCommand = gmkStructure.indexStep(i);
      String label = itemGMKCommand.label;
      var (obj, type) = lib.analysis(itemGMKCommand, gmkData);
      gmkData.data[label] = GraphOBJ(obj, label, type);
    }
    gmkData.data['time'] = GraphOBJ(t, 'time', 'num <TIME>');
    return gmkData;
  }
}
