
import 'GMKCommand.dart';

class GMKStructure {
  List<GMKCommand> step = [];

  GMKStructure(this.step);

  static GMKStructure newBlank() {
    return GMKStructure([]);
  }


  int get stepCount => step.length;

  GMKCommand indexStep(int n){
    return step[n-1];
  }

  bool addStep(GMKCommand gmkProcess){
    step.add(gmkProcess);
    return true;
  }



}