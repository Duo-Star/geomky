import '../../Linear/Vector.dart';

/*
这里是几何结构
 */


import 'GMKCommand.dart';
import 'GMKStyle.dart';

class GMKStructure {
  //步序标签
  List<String> stepLabel = [];
  //从步序到指令
  Map<String, GMKCommand> step = <String, GMKCommand>{};
  //信息
  String name = '未闻花名';
  String author = '江湖隐士';
  String style = 'banana';
  Vector o = Vector(300, 300);
  num lam = 200;

  //使用的主题
  GMKStyle gmkStyle = GMKStyle();

  //创建结构
  GMKStructure();

  // 记得手动应用主题！
  void applyStyle() {
    gmkStyle.apply(style);
  }

  //新建空白结构
  static GMKStructure newBlank() {
    return GMKStructure()
      ..stepLabel = []
      ..step = {};
  }

  //更改参数
  void alterFactor(String label, List<dynamic> factor) {
    step[label]?.factor = factor;
  }

  //步序计数
  int get stepCount => step.length;

  //根据第几步索引到标签
  String indexStepLabel(int n) {
    return stepLabel[n - 1];
  }

  //根据第几步索引到命令
  GMKCommand? indexStep(int n) {
    return step[indexStepLabel(n)];
  }

  //增加一步
  bool addStep(GMKCommand gmkCommand) {
    stepLabel.add(gmkCommand.label);
    step[gmkCommand.label] = gmkCommand;
    return true;
  }

  //对于每一个
  void forEach(Function f) {
    for (var key in step.keys) {
      f(key, step[key]);
    }
  }

  //使用标签删除对象
  bool deleteStepByLabel(String label) {
    stepLabel.remove(label);
    step.remove(label);
    return true;
  }
}
