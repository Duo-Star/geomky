import 'dart:ui';
import 'GOBJStyle.dart' as gStyle;

class GraphOBJ {
  dynamic obj;
  String label = '';
  String type = '';
  late gStyle.GOBJStyle style;

  GraphOBJ(dynamic obj0, String label0, String type0, gStyle.GOBJStyle style0)
    : obj = obj0,
      label = label0,
      type = type0,
      style = style0;


}
