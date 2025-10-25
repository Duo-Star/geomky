import '../Monxiv/GOBJStyle.dart' as gStyle;

class GMKCommand {
  String method = "";
  String label = "";
  String type = '?';
  List<dynamic> factor = [];
  gStyle.GOBJStyle style = gStyle.GOBJStyle.none();

  GMKCommand(this.method, this.label, this.factor);

}