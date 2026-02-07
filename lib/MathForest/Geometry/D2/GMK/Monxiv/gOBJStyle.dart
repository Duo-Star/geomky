//
/*
这里对几何对象的样式进行设置
 */


//
import 'dart:ui';



//
Color red = Color.fromARGB(255, 224, 6, 12);
Color blue = Color.fromARGB(255, 21, 101, 192);
Color cyan = Color(0xFF00b8a3);
Color amber = Color.fromARGB(255, 248, 196, 46);
Color pakoo = Color.fromARGB(255, 153, 102, 255);
Color brown = Color.fromARGB(255, 153, 102, 0);
Color gray = Color.fromARGB(255, 123, 123, 123);
Color teal = Color.fromARGB(255, 0, 128, 128);
Color forest = Color.fromARGB(255, 0, 153, 0);
Color yduo = Color.fromARGB(255, 102, 204, 255);
Color rust = Color.fromARGB(255, 148, 15, 15);
Color hacker = Color.fromARGB(255, 0, 0, 255);
Color cinnabar = Color.fromARGB(255, 205, 0, 32);
Color dazzling = Color.fromARGB(255, 255, 255, 56);
Color indigo = Color.fromARGB(255, 85, 0, 150);
Color purple = Color.fromARGB(255, 102, 0, 204);
Color black = Color.fromARGB(246, 32, 32, 32);
Color white = Color.fromARGB(255, 246, 246, 246);

// shape
String nShape = 'nShape';
String dotted = 'dotted';
String wave = 'wave';
String sloid = 'sloid';
String hollow = 'hollow';
String xDot = 'xDot';
String biasDot = 'biasDot';

//show


//
class GOBJStyle {
  Color color = black; //
  bool show = true; //
  num size = 1; //
  num opacity = 0; //暧昧
  bool labelShow = false; //
  String shape = 'nShape'; //
  bool trace = false;
  bool fertileWaveLink = false;

  GOBJStyle();

  static GOBJStyle none() {
    return GOBJStyle();
  }

  static GOBJStyle apply(String type){
    GOBJStyle result = GOBJStyle();
    switch (type) {/*
      case const ('Vector'):
        result.color = gray;
      case const ('Line'):
        result.color = gray;
      case const ('Circle'):
        result.color = gray;*/
      case const ('DPoint'):
        result.color = purple;
      case const ('QPoint'):
        result.color = cyan;
      case const ('XLine'):
        result.color = rust;
      case const ('Conic0'):
        result.color = amber;
      default:
        result.color = gray;
    }
    return result;
  }

  String generateCode(){
    String code = '';
    // 写入color
    String colorCode = '';
    for (String key in colors.keys) {
      if (color.hashCode == colors[key].hashCode) {
        colorCode = key;
      }
    }
    code = '$code$colorCode';
    //写入显示&隐藏
    code = '$code${show?"":" hide"}';
    //大小
    code = '$code${(size==1)?"":" ${size.toString()}"}';
    //opacity

    //
    code = '$code${labelShow?" labelShow":""}';
    code = '$code${trace?" trace":""}';
    code = '$code${fertileWaveLink?" fertileWaveLink":""}';
    code = '$code${(shape=='nShape')?'':shape}';
    return code;
  }

  String get code => generateCode();

  @override
  String toString() {
    return 'color:${color.toString()}, show:$show, ...';
  }
}

List<String> color = [
  'red',
  'blue',
  'cyan',
  'amber',
  'pakoo',
  'brown',
  'gray',
  'teal',
  'forest',
  'yduo',
  'rust',
  'hacker',
  'cinnabar',
  'dazzling',
  'indigo',
  'purple',
  'black',
  'white',
];

Map<String, Color> colors = {
  'red': red,
  'blue': blue,
  'cyan': cyan,
  'amber': amber,
  'pakoo': pakoo,
  'brown': brown,
  'gray': gray,
  'teal': teal,
  'forest': forest,
  'yduo': yduo,
  'rust': rust,
  'hacker': hacker,
  'cinnabar': cinnabar,
  'dazzling': dazzling,
  'indigo': indigo,
  'purple': purple,
  'black': black,
  'white': white,
};

List<String> shape = [
  'line',
  'dotted',
  'wave',
  'sloid',
  'hollow',
  'xDot',
  'biasDot',
];

List<String> show = ['show', 'hide'];

List<String> labelShow = ['labelShow', 'labelHide'];

List<String> fertileWaveLink = ['fertileWaveLink', 'fertileWaveLinkHide'];

