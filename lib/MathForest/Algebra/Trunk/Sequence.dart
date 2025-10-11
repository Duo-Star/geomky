// 数列

class Sequence {
  List<num> list = [];

  num operator [](int index) {
    if (index < 1 || index > list.length) {
      throw RangeError('Index $index out of range (1..${list.length})');
    }
    return list[index - 1];
  }

  void operator []=(int index, dynamic value) {
    list[index-1] = value;
  }

}