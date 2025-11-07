import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart';

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
    bool _ = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      int offset = 0;
      final lineChildren = <TextSpan>[];

      // 按令牌单位处理（基于正则表达式的简易解析器）
      final pattern = RegExp(
        '($comment)|($label)|($accessL)|($accessR)|($array)|($methodC)|($methodM)|($number)|($constV)|([a-zA-Z]+)',
      );

      pattern.allMatches(line).forEach((match) {
        // 处理未匹配的部分（空格等）
        if (match.start > offset) {
          final plainText = line.substring(offset, match.start);
          lineChildren.add(TextSpan(text: plainText, style: baseStyle));
        }

        // 处理匹配的令牌
        String token = match.group(0)!;
        TextStyle currentStyle = baseStyle;

        if (RegExp(comment).hasMatch(token)) {
          currentStyle = commentStyle;
        } else if (RegExp(label).hasMatch(token)) {
          currentStyle = labelStyle;
        } else if (RegExp(access).hasMatch(token)) {
          // 对访问符号不做特殊样式处理
        } else if (RegExp(accessL).hasMatch(token)) {
          currentStyle = labelStyle;
        } else if (RegExp(accessR).hasMatch(token)) {
          currentStyle = labelStyle;
        } else if (RegExp(number).hasMatch(token)) {
          currentStyle = numberStyle;
        } else if (gmlKeywords.contains(token)) {
          currentStyle = keywordStyle;
        } else if (gmlTypes.contains(token) &&
            (!RegExp(notMethod).hasMatch(token))) {
          currentStyle = methodStyle;
        } else if (gmkConst.contains(token)) {
          currentStyle = constStyle;
        }

        lineChildren.add(TextSpan(text: token, style: currentStyle));
        offset = match.end;
      });

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
// GML编辑器子页面
// =========================================================================

class GmkEditorPage extends StatefulWidget {
  const GmkEditorPage({super.key});

  @override
  State<GmkEditorPage> createState() => _GmkEditorPageState();
}

class _GmkEditorPageState extends State<GmkEditorPage> {
  late GmlSyntaxHighlighterController _controller;
  String _currentGmlCode = '''
@slider is L of <0 0> <1 0>
@thumb is IndexP of <slider> 0
@t is Index^getN of <slider> <thumb>
@A is P of 1 1
@B is P of 2 2
@dp1 is DP of <A> <B>
-@l is L of <A> <B>
@dp2 is Harm:dpt of <dp1> <t>
#dp2 red
@c1 is C:diameter of <dp1>
@c2 is C:diameter of <dp2>
#c1 purple
#c2 red
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
    print('222');
    Navigator.pushNamed(
      context,
      '/gmk',
      arguments: {'code': _currentGmlCode}, // ✅ 传入
    );
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
