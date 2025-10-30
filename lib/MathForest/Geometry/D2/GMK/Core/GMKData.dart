import '../Monxiv/graphOBJ.dart';

class GMKData {
  Map<String, GraphOBJ> data = <String, GraphOBJ>{};

  GMKData(this.data);

  int get count => data.length;

  GraphOBJ? index(String k) => data[k];

  static none() => GMKData({});

  void forEach(Function f) {
    for (var key in data.keys) {
      f(key, data[key]);
    }
  }
}
