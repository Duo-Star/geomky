library;

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

import '../../Linear/Vector.dart';
import '../../Linear/Line.dart';

dynamic getVar(itemFactor, gmkData) {
  if (itemFactor.runtimeType == String) {
    String label = compiler.subStringBetween(itemFactor, '<', '>');
    return gmkData.data[label]?.obj;
  } else {
    return itemFactor;
  }
}

dynamic run(GMKCommand gmkCommand, GMKData gmkData) {
  switch (gmkCommand.method) {
    case 'P':
      num x = getVar(gmkCommand.factor[0], gmkData);
      num y = getVar(gmkCommand.factor[1], gmkData);
      return Vector(x, y);
    case 'P:v':
      return getVar(gmkCommand.factor[0], gmkData);
    case 'L':
      Vector p1 = getVar(gmkCommand.factor[0], gmkData);
      Vector p2 = getVar(gmkCommand.factor[1], gmkData);
      return Line.new2P(p1, p2);
    case 'L:pv':
      Vector p = getVar(gmkCommand.factor[0], gmkData);
      Vector v = getVar(gmkCommand.factor[1], gmkData);
      return Line(p,v);
    case 'N':
      return getVar(gmkCommand.factor[0], gmkData);






    case 'P:mid':
      Vector p1 = getVar(gmkCommand.factor[0], gmkData);
      Vector p2 = getVar(gmkCommand.factor[1], gmkData);
      return p1.mid(p2);

    default :
      return null;
  }
}



String getTypeByMethod(String method) {
  switch (method) {
    case 'P':
      return 'Vector';
    case 'N':
      return 'num';
    default :
      return '?type';
  }
}











/*
Map<String, dynamic> doc = {
  'P': {
    'in_type': 'num',
    'out_type': 'Vector',
    'father': 'P',
    'facNum': 2,
    'demo': '@A is P of 1, 1;',
  },
  'P_byVec': {'type': 'Vector', 'facNum': 1, 'demo': '@A is P of <1, 1>;'},
};
void main(){
  print(doc['P']);
}
 */
