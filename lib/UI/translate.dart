class Translator {
  String language = 'zh-cn';

  //
  String translate(String s) {
    if (language == 'zh-cn') {
      return s;
    }
    return dictionary[language]?[s] ?? '<tran-e>';
  }
}

Map<String, Map<String, String>> dictionary = {
  'ch-cn': {'？': '！'},
  'en': {
    '点': 'Point',
    '直线': '',
    '圆': '',
    '圆周': '',
    '线段': '',
    '三角形': '',
    '多边形': '',
    '周长': '',
    '半径': '',
    '直径': '',
  },
};
