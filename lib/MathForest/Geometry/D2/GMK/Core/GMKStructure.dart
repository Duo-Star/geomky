import 'package:geomky/MathForest/Geometry/D2/Linear/Vector.dart';

import 'GMKCommand.dart';

class GMKStructure {
  List<String> stepLabel = [];
  Map<String, GMKCommand> step = <String, GMKCommand>{};
  //信息
  String name = '未闻花名';
  String author = '江湖隐士';
  String style = 'classic';
  Vector o = Vector(300, 300);
  num lam = 200;

  GMKStructure();

  static GMKStructure newBlank() {
    return GMKStructure()
      ..stepLabel = []
      ..step = {};
  }

  void alterFactor(String label, List<dynamic> factor) {
    step[label]?.factor = factor;
  }

  int get stepCount => step.length;

  String indexStepLabel(int n) {
    return stepLabel[n - 1];
  }

  GMKCommand? indexStep(int n) {
    return step[indexStepLabel(n)];
  }

  bool addStep(GMKCommand gmkCommand) {
    stepLabel.add(gmkCommand.label);
    step[gmkCommand.label] = gmkCommand;
    return true;
  }

  void forEach(Function f) {
    for (var key in step.keys) {
      f(key, step[key]);
    }
  }

  bool deleteStepByLabel(String label) {
    stepLabel.remove(label);
    step.remove(label);
    return true;
  }
}
