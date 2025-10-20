import 'package:flutter/material.dart';

// GML的关键字和类型
const Set<String> gmlKeywords = {'is', 'of'};

const Set<String> gmlTypes = {
  'N',
  'P',
  'Cir',
  'MidP',
  'L',
  'Ins',
  'C0',
  'F',
  'QNum',
  'Index',
};

// =========================================================================
// 自定义TextEditingController
// =========================================================================

class GmlSyntaxHighlighterController extends TextEditingController {
  final BuildContext context;

  GmlSyntaxHighlighterController(this.context);

  // 令牌定义
  static const String identifier = r'@([a-zA-Z0-9_]+)';
  static const String number = r'-?\d+(\.\d+)?';
  static const String comment = r'``.*?``'; // 简化后的注释
  static const String access = r'<\.?[a-zA-Z0-9_]+>'; // <...>访问
  static const String array = r'\[.*?\]'; // [...]数组

  // 高亮显示样式
  TextStyle defaultStyle = TextStyle(
    color: Colors.black,
    fontFamily: 'Consolas',
    fontSize: 18,
  );
  TextStyle keywordStyle = TextStyle(
    color: Colors.black87,
    fontWeight: FontWeight.w800,
    fontFamily: 'Consolas',
    fontSize: 18,
  );
  TextStyle typeStyle = TextStyle(
    color: Colors.amber[700],
    fontWeight: FontWeight.bold,
    fontFamily: 'Consolas',
    fontSize: 18,
  );
  TextStyle identifierStyle = TextStyle(
    color: Colors.indigo[400],
    fontWeight: FontWeight.bold,
    fontFamily: 'Consolas',
    fontSize: 18,
  );
  TextStyle numberStyle = TextStyle(
    color: Colors.teal,
    fontWeight: FontWeight.bold,
    fontFamily: 'Consolas',
    fontSize: 18,
  );
  TextStyle commentStyle = TextStyle(
    color: Colors.green,
    //fontStyle: FontStyle.italic,
    fontFamily: 'Consolas',
    fontSize: 18,
  );
  TextStyle errorStyle = TextStyle(
    color: Colors.black,
    decorationStyle: TextDecorationStyle.wavy,
    decoration: TextDecoration.underline,
    decorationColor: Colors.red,
    fontFamily: 'Consolas',
    fontSize: 18,
  );

  TextStyle factorStyle = TextStyle(
    color: Colors.black87,
    decoration: TextDecoration.underline,
    decorationColor: Colors.green,
    fontFamily: 'Consolas',
    fontSize: 18,
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

      // 闭包检查（简单的<>和[]平衡检查）
      // 要进行更精确的检查，需要基于堆栈的解析器
      int angleBracketBalance = 0;
      int squareBracketBalance = 0;

      for (int j = 0; j < line.length; j++) {
        final char = line[j];
        if (char == '<') angleBracketBalance++;
        if (char == '>') angleBracketBalance--;
        if (char == '[') squareBracketBalance++;
        if (char == ']') squareBracketBalance--;
      }

      // 将平衡被破坏的整行标记为错误
      bool lineHasClosureError =
          angleBracketBalance != 0 || squareBracketBalance != 0;
      if (lineHasClosureError) {
        hasError = true;
      }

      // 按令牌单位处理（基于正则表达式的简易解析器）
      // 这种基于正则表达式的方法并不完美，但对于高亮显示是有效的
      final pattern = RegExp(
        '($comment)|($identifier)|($access)|($array)|($number)|([a-zA-Z]+)',
      );

      pattern.allMatches(line).forEach((match) {
        // 处理未匹配的部分（空格等）
        if (match.start > offset) {
          final plainText = line.substring(offset, match.start);
          lineChildren.add(TextSpan(text: plainText, style: baseStyle));
        }

        // 处理匹配的令牌
        final token = match.group(0)!;
        TextStyle currentStyle = baseStyle;

        // 注释
        if (RegExp(comment).hasMatch(token)) {
          currentStyle = commentStyle;
        } else {
          if (RegExp(identifier).hasMatch(token)) {
            // 标识符（@a, @b等）
            currentStyle = identifierStyle;
          }
          // 值的访问（<A>, <.o>等）// <...> 和 [...] 保持原样
          else if (RegExp(access).hasMatch(token) ||
              RegExp(array).hasMatch(token)) {
            currentStyle = factorStyle;
          }
          // 数值
          else if (RegExp(number).hasMatch(token)) {
            currentStyle = numberStyle;
          }
          // 关键字和类型名
          else if (gmlKeywords.contains(token)) {
            currentStyle = keywordStyle;
          } else if (gmlTypes.contains(token)) {
            currentStyle = typeStyle;
          }
          // 如果存在闭包错误，对整个行应用错误下划线
          if (lineHasClosureError || !line.contains('@')) {
            currentStyle = errorStyle;
          }
        }
        lineChildren.add(TextSpan(text: token, style: currentStyle));
        offset = match.end;
      });



      // 行的剩余文本
      if (line.length > offset) {
        final remainingText = line.substring(offset);
        if (lineHasClosureError) {
          lineChildren . add(TextSpan(text: remainingText, style: errorStyle));
        } else {
          lineChildren . add(TextSpan(text: remainingText, style: baseStyle));
        }
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
@a is N of 1;
@b is N of 1;
@A is P of <a>, 1;
@B is P of 2, -1;
@cir is Cir of <A>, <B>;
@M is MidP of <A>, <B>;
@l is L of <A>,<B>;
@dP1 is Ins of <l>,<cir>;
@QNum_1 is QNum of [1, 1.5, 2, 2.5];
``错误检查``
@l is L of <A>,<B ;

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
    return Scaffold(
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
                  'GML测试文本输入',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                child: TextField(
                  controller: _controller,
                  maxLines: null, // 无限制行数
                  expands: true, // 填充父级的Expanded
                  cursorWidth: 2.5, // 光标宽度
                  cursorRadius: const Radius.circular(3.0), // 光标圆角
                  decoration: const InputDecoration(
                    border: InputBorder.none, // 移除边框
                    hintText: '在此输入GML代码...',
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
      ),
      home: const GmlEditorPage(),
    );
  }
}
