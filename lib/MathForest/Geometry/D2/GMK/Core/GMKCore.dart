
//
import 'GMKData.dart';

//
import 'GMKStructure.dart';

//
import 'GMKCommand.dart';

//
import 'GMKCompiler.dart';

//
import 'GMKLib.dart';

//
import '../Monxiv/GraphOBJ.dart';


class GMKCore {
  String code = '';
  GMKStructure gmkStructure = GMKStructure();
  GMKData gmkData = GMKData();

  bool loadCode(String code) {
    return true;
  }

  String generatedCode() {
    return '';
  }

}