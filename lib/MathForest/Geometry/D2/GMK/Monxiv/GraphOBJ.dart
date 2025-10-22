import 'dart:ui';

class GraphOBJ {
  dynamic obj ;
  num size = 1;
  Color color = Color.fromARGB(0, 0, 0, 0);
  String label = '';
  String type = '';
  String shape = '';
  bool select = false;

  GraphOBJ(this.obj, this.label, this.type);

}