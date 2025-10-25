//
import 'dart:ui';

//
Color red = Color.fromARGB(255, 255, 0, 36);
Color blue = Color.fromARGB(255, 0, 153, 255);
Color cyan = Color.fromARGB(255, 51, 255, 204);
Color amber = Color.fromARGB(255, 255, 204, 51);
Color pakoo = Color.fromARGB(255, 153, 102, 255);
Color brown = Color.fromARGB(255, 153, 102, 0);
Color gray = Color.fromARGB(255, 128, 128, 128);
Color teal = Color.fromARGB(255, 0, 128, 128);
Color forest = Color.fromARGB(255, 0, 153, 0);
Color yduo = Color.fromARGB(255, 102, 204, 255);
Color rust = Color.fromARGB(255, 128, 12, 12);
Color hacker = Color.fromARGB(255, 0, 0, 255);
Color cinnabar = Color.fromARGB(255, 205, 0, 32);
Color dazzling = Color.fromARGB(255, 255, 255, 56);
Color indigo = Color.fromARGB(255, 75, 0, 130);
Color purple = Color.fromARGB(255, 127, 0, 255);
Color black = Color.fromARGB(255, 8, 8, 8);
Color white = Color.fromARGB(255, 246, 246, 246);

// shape
String nShape = 'nShape';
String dotted = 'dotted';
String wave = 'wave';
String sloid = 'sloid';
String hollow = 'hollow';
String xDot = 'xDot';
String biasDot = 'biasDot';

//
class GOBJStyle {
  Color color = black;
  bool show = false;
  num size = 1;
  bool labelShow = false;
  String shape = 'nShape';
  bool trace = false;
  bool fertileWaveLink = false;

  GOBJStyle();

  static GOBJStyle none() {
    return GOBJStyle();
  }

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
