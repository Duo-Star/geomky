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
import '../Monxiv/graphOBJ.dart';
import '../Monxiv/gOBJStyle.dart' as gStyle;

class GMKCore {
  GMKStructure gmkStructure = GMKStructure.newBlank();
  //初始化时间
  GMKData gmkData = GMKData({'time': GraphOBJ(0.0, 'time', 'num <TIME>', gStyle.GOBJStyle.none())});
  num time = 0;

  bool setTime(num t){
    time = t;
    return true;
  }


  GMKStructure loadCode(String code) {
    gmkStructure = compiler.goCompiler(code);
    return gmkStructure;
  }

  String generatedCode() {
    String source = '//这是标准化生成的gmk-source';
    source = '$source\n.\$GeoMKY !Nature<Pakoo, Forest>';
    source = '$source\n//information';
    source = '$source\n//geo structure code';
    int structureStepCount = gmkStructure.stepCount;
    for (var i = 1; i <= structureStepCount; i++) {
      GMKCommand? igc = gmkStructure.indexStep(i);
      if (igc!=null) {
        String s = compiler.gmkCommand2Str(igc);
        source = '$source\n$s';
      }
    }
    source = '$source\n//style';
    return source;
  }

  String printStructure() {
    String s = '';
    gmkStructure.forEach((label, itemCommand){
      String f = '';
      for (var fi in itemCommand.factor) {
        f = '$f[${fi.toString()}, ${fi.runtimeType}]  ';
      }
      s = '$s\nlabel:${itemCommand.label}, method:${itemCommand.method}, factor: $f';
    });
    return s;
  }

  GMKData run() {
    gmkStructure.forEach((String label, GMKCommand itemCommand){
      String label = itemCommand.label;
      gStyle.GOBJStyle style = itemCommand.style;
      var (obj, type) = lib.analysis(itemCommand, gmkData);
      //itemCommand.type = type;
      // 改为编译时生成type
      if (obj == null) {
        if (type == 'e-findMethod:none') {
          Exception(
            '''runtime-error：e-findMethod:none 找不到方法，请检查拼写[method:${itemCommand.method}, label:$label, s-code:${compiler.gmkCommand2Str(itemCommand)}]''',
          );
        } else {
          Exception(
            '''runtime-error：e-getVar:null or getNullReturn 参数空值，上游依赖缺失或计算返回空值[method:${itemCommand.method}, label:$label, s-code:${compiler.gmkCommand2Str(itemCommand)}]''',
          );
        }
      } else {
        gmkData.data[label] = GraphOBJ(obj, label, type, style);
      }
    });
    //更新时间
    gmkData.data['time'] = GraphOBJ(time, 'time', 'num <TIME>', gStyle.GOBJStyle.none());
    return gmkData;
  }
}
