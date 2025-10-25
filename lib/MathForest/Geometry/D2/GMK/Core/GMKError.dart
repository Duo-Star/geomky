
class GMKError {
  String when = '';
  String label = '';
  int line = 0;
  String code = '';
  String info = '';
  String help = '';

  GMKError();

}



class GMKErrorList {
  List<GMKError> errors = [];

  GMKErrorList(this.errors);

  static GMKErrorList newBlank() {
    return GMKErrorList([]);
  }

  int get errorCount => errors.length;

  GMKError indexError(int n){
    return errors[n-1];
  }

  bool addError(GMKError error){
    errors.add(error);
    return true;
  }

}