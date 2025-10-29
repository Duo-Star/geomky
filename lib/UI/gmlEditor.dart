import 'dart:ui';

import 'package:flutter/material.dart';

// GML的关键字和类型
const Set<String> gmlKeywords = {'is', 'of'};

const Set<String> gmlTypes = {
  'N',
  'N^mul',
  'P',
  'P:v',
  'P^mid',
  'QP^heart',
  'QP^deriveL',
  'C',
  'C:pr',
  'MidP',
  'L',
  'Ins',
  'C0',
  'F',
  'QN',
  'IndexP',
  'IndexQP',
};

const Set<String> gmkConst = {'.T', '.E', '.PI'};

// =========================================================================
// 自定义TextEditingController
// =========================================================================

class GmlSyntaxHighlighterController extends TextEditingController {
  final BuildContext context;

  GmlSyntaxHighlighterController(this.context);

  // 令牌定义
  static const String label = r'@(\w+)';
  static const String number = r'(?<![a-zA-Z])-?\d+(?:\.\d+)?(?![a-zA-Z])';
  static const String comment = r'``.*?``'; // 简化后的注释
  static const String access = r'<(\w+)>'; // <...>访问
  static const String accessL = r'<'; //
  static const String accessR = r'>'; //
  static const String array = r'\[.*?\]'; // [...]数组
  static const String notMethod = r'<(\w+)>';
  static const String methodC = r'(\w+):(\w+)'; //
  static const String methodM = r'(\w+)\^(\w+)'; //
  static const String constV = r'\.(\w+)'; //

  // 高亮显示样式
  TextStyle defaultStyle = TextStyle(
    color: Colors.white70,
    fontFamily: 'Maple',
    fontSize: 24,
  );
  TextStyle keywordStyle = TextStyle(
    color: Colors.red[400],
    //fontWeight: FontWeight.w800,
    fontFamily: 'Maple',
    fontSize: 24,
  );
  TextStyle methodStyle = TextStyle(
    color: Colors.teal,
    fontWeight: FontWeight.bold,
    fontFamily: 'Maple',
    fontSize: 24,
  );
  TextStyle labelStyle = TextStyle(
    color: Colors.amber[400],
    fontWeight: FontWeight.bold,
    fontFamily: 'Maple',
    fontSize: 24,
  );
  TextStyle numberStyle = TextStyle(
    color: Colors.blue[300],
    fontWeight: FontWeight.bold,
    fontFamily: 'Maple',
    fontSize: 24,
  );
  TextStyle commentStyle = TextStyle(
    color: Colors.green,
    fontStyle: FontStyle.italic,
    fontFamily: 'Maple',
    fontSize: 24,
  );
  TextStyle errorStyle = TextStyle(
    color: Colors.black,
    decorationStyle: TextDecorationStyle.wavy,
    decoration: TextDecoration.underline,
    decorationColor: Colors.red,
    fontFamily: 'Maple',
    fontSize: 24,
  );

  TextStyle factorStyle = TextStyle(
    color: Colors.red,
    fontWeight: FontWeight.bold,
    fontFamily: 'Maple',
    fontSize: 24,
  );

  TextStyle constStyle = TextStyle(
    color: Colors.purple,
    fontWeight: FontWeight.bold,
    fontFamily: 'Maple',
    fontSize: 24,
  );

  // 处理文本高亮显示的方法
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // 基于现有样式
    final baseStyle = defaultStyle;

    // GML代码的行分割和处理
    final lines = text.split('\n');
    final children = <TextSpan>[];

    // 闭包检查的错误标志
    bool hasError = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      int offset = 0;
      final lineChildren = <TextSpan>[];

      // 按令牌单位处理（基于正则表达式的简易解析器）
      // 这种基于正则表达式的方法并不完美，但对于高亮显示是有效的
      final pattern = RegExp(
        '($comment)|($label)|($accessL)|($accessR)|($array)|($methodC)|($methodM)|($number)|($constV)|([a-zA-Z]+)',
      );

      if (1 == 1) {
        pattern.allMatches(line).forEach((match) {
          // 处理未匹配的部分（空格等）
          if (match.start > offset) {
            final plainText = line.substring(offset, match.start);
            lineChildren.add(TextSpan(text: plainText, style: baseStyle));
          }

          // 处理匹配的令牌
          String token = match.group(0)!;
          TextStyle currentStyle = baseStyle;
          //print(token);

          // 注释
          if (RegExp(comment).hasMatch(token)) {
            currentStyle = commentStyle;
          } else {
            if (RegExp(label).hasMatch(token)) {
              // 标识符（@a, @b等）
              currentStyle = labelStyle;
            }
            // 值的访问（<A>, <.o>等）// <...> 和 [...] 保持原样
            else if (RegExp(access).hasMatch(token)) {
              //currentStyle = factorStyle;
            } else if (RegExp(accessL).hasMatch(token)) {
              currentStyle = labelStyle;
            } else if (RegExp(accessR).hasMatch(token)) {
              currentStyle = labelStyle;
            } else if (RegExp(number).hasMatch(token)) {
              currentStyle = numberStyle;
            }
            // 关键字和类型名
            else if (gmlKeywords.contains(token)) {
              currentStyle = keywordStyle;
            } else if (gmlTypes.contains(token) &&
                (!RegExp(notMethod).hasMatch(token))) {
              currentStyle = methodStyle;
            } else if (gmkConst.contains(token)) {
              currentStyle = constStyle;
            }
            // 如果存在闭包错误，对整个行应用错误下划线
            if (false || !line.contains('@')) {
              currentStyle = errorStyle;
            }
          }
          lineChildren.add(TextSpan(text: token, style: currentStyle));
          offset = match.end;
        });
      }

      // 行的剩余文本
      if (line.length > offset) {
        final remainingText = line.substring(offset);
        lineChildren.add(TextSpan(text: remainingText, style: baseStyle));
      }

      // 添加行尾换行（最后一行除外）
      if (i < lines.length - 1) {
        lineChildren.add(TextSpan(text: '\n', style: baseStyle));
      }

      children.addAll(lineChildren);
    }

    return TextSpan(style: baseStyle, children: children);
  }
}

// =========================================================================
// 主布局Widget
// =========================================================================

class GmlEditorPage extends StatefulWidget {
  const GmlEditorPage({super.key});

  @override
  State<GmlEditorPage> createState() => _GmlEditorPageState();
}

class _GmlEditorPageState extends State<GmlEditorPage> {
  late GmlSyntaxHighlighterController _controller;
  String _currentGmlCode = '''
``this is a gml file , enjoy the gmk``
@A is P of 1 1
@x is N of .E
@B is P of <x> .PI
@C is P:v of <2 2>
@D is P^mid of <C> <A>

@n1 is N^mul of <time> .E
@qn1 is QN of 1 2 <n1> <time>
@c1 is C:pr of <1 1> 1
@qp1 is IndexQP of <c1> <qn1>
@p1 is QP^heart of <qp1>
@l1 is QP^deriveL of <qp1>

''';

  // 添加统计变量
  int _lineCount = 1;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = GmlSyntaxHighlighterController(context);
    _controller.text = _currentGmlCode;
    _controller.addListener(_updateCode);
    _controller.addListener(_updateTextInfo);
    // 初始化统计信息
    _updateTextInfo();
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCode);
    _controller.removeListener(_updateTextInfo);
    _controller.dispose();
    super.dispose();
  }

  void _updateCode() {
    // 实时更新代码
    _currentGmlCode = _controller.text;
    // print(_currentGmlCode); // 用于调试
  }

  // 添加文本信息更新方法
  void _updateTextInfo() {
    final text = _controller.text;
    setState(() {
      _charCount = text.length;
      _lineCount = text.isEmpty ? 1 : text.split('\n').length;
    });
  }

  // 浮动按钮点击事件
  void _onFabPressed() {
    // 在这里进行语法解析（解析）或执行处理
    final snackBar = SnackBar(
      content: Text(
        '执行/检查GML代码:\n'
        '当前代码长度: ${_currentGmlCode.length}\n'
        '行数: $_lineCount | 字符数: $_charCount',
      ),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = false;
    return MaterialApp(
      // 根据状态选择主题
      theme: darkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        backgroundColor: Color.fromARGB(35, 255, 255, 255),
        appBar: AppBar(
          title: const Text('GML编辑器'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 修改为Row布局，添加统计信息
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'write gmk code here',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '行数: $_lineCount | 字符: $_charCount',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 5e3, // 足够大的固定宽度
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          style: TextStyle(height: 2.4),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '在此输入GML代码...',
                            isDense: true, // 减少垂直间距
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onFabPressed,
          tooltip: '执行',
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}

// =========================================================================
// 应用程序入口点（相当于main.dart）
// =========================================================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GML Editor Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        useSystemColors: true,
        //fontFamily: 'Maple'
      ),
      home: const GmlEditorPage(),
    );
  }
}
