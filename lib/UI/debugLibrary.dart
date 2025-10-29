import 'package:flutter/material.dart';
import '../MathForest/main.dart';
import '../MathForest/Geometry/D2/GMK/Core/GMKCompiler.dart' as compiler;
import '../MathForest/Geometry/D2/GMK/Core/GMKLib.dart' as gLib;

Card debugZone(context, String title, String subTitle, Function todo) {
  return Card(
    margin: EdgeInsets.all(10),
    elevation: 3.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.ac_unit_rounded),
            title: Text(title),
            subtitle: Text(subTitle),
            trailing: IconButton(
              onPressed: () {
                String s = todo();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('调试台：\n$s'),
                    duration: const Duration(seconds: 10),
                  ),
                );
              },
              icon: const Icon(Icons.accessibility_new_rounded),
              tooltip: '调试',
            ),
          ),
          // ... 其他内容
        ],
      ),
    ),
  );
}

i(context){
  return IconButton(
    icon: const Icon(Icons.account_balance),
    tooltip: '调试',
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(title: const Text('Debug Library')),
              body: ListView(
                children: [
                  Card(
                    margin: EdgeInsets.all(10), // 建议添加外边距，使卡片间有间隔[1](@ref)
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.ac_unit_rounded),
                            title: const Text('你会点下它吗'),
                            subtitle: const Text('awa'),
                            trailing: IconButton(
                              onPressed: () {
                                String msg = '控制台';
                                void m(String str) {
                                  msg = '$msg\n$str';
                                }

                                m('欢迎找我玩');
                                m('Duo-113530014');
                                m('QQ-Group-663251235');
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(msg)));
                              },
                              icon: const Icon(Icons.accessibility_new_rounded),
                              tooltip: '调试',
                            ),
                          ),
                          // ... 其他内容
                        ],
                      ),
                    ),
                  ),

                  Card(
                    margin: EdgeInsets.all(10),
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.ac_unit_rounded),
                            title: const Text('参数列解析器'),
                            subtitle: const Text('GMKCompiler.str2Factor'),
                            trailing: IconButton(
                              onPressed: () {
                                String msg = '控制台';
                                void m(String str) {
                                  msg = '$msg\n$str';
                                }

                                void lll([String? str]) {
                                  msg =
                                  '$msg\n-----------|${str ?? ''}|-----------';
                                }

                                String str =
                                    '1 1.23 .PI .NAN .INF a <b> .T <3 4> <1.23 4.56> <.PI .PI> <.NAN .INF> .I';
                                m('-----------原始-----------');
                                m(str);

                                m('-----------参数列-----------');
                                List<dynamic> fac = compiler.str2Factor(str);
                                for (var item in fac) {
                                  m('$item, type:${item.runtimeType}');
                                }

                                m('-----------还原-----------');
                                m(compiler.factor2Str(fac));
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(msg)));
                              },
                              icon: const Icon(Icons.accessibility_new_rounded),
                              tooltip: '调试',
                            ),
                          ),
                          // ... 其他内容
                        ],
                      ),
                    ),
                  ),

                  debugZone(context, 'GMK编译', 'GMKCompiler', () {
                    String msg = '控制台';
                    void m(String str) {
                      msg = '$msg\n$str';
                    }

                    void lll([String? str]) {
                      msg = '$msg\n-----------|${str ?? ''}|-----------';
                    }

                    String code = '''
@A is P of 1 1
@c is C of .O <.PI 0>
@l is L of <A> .I
                                                  ''';
                    lll();
                    m('gmk源代码\n$code');
                    GMKCore gmkCore = GMKCore();
                    gmkCore.loadCode(code);
                    lll('结构');
                    m('printStructure:\n${gmkCore.printStructure()}');
                    lll('生成代码');
                    m('generatedCode:\n${gmkCore.generatedCode()}');
                    return msg;
                  }),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
