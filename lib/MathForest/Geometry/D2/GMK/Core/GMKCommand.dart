import '../Monxiv/gOBJStyle.dart' as g_style;
import 'GMKLib.dart' as g_lib;

class GMKCommand {
  String method = "";
  String label = "";
  String type = '?';
  List<dynamic> factor = [];
  g_style.GOBJStyle style = g_style.GOBJStyle.none();

  GMKCommand(this.method, this.label, this.factor) {
    type  = (g_lib.lib[method]?[0]) ?? '?unType';
  }
}
