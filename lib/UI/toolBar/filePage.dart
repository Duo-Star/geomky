library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../MathForest/main.dart';
//
import '../../demoGMK.dart' as demo_gmk;
import '../../MathForest/Geometry/D2/GMK/Core/GMKCompiler.dart' as compiler;
import '../../MathForest/Geometry/D2/GMK/Core/GMKLib.dart' as g_lib;

SingleChildScrollView page(context, GMKCore gmkCore, Monxiv monxiv) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('加载哪个demo'),
                    content: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 400,
                      ), // 限制最大高度
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: demo_gmk.demo.entries.map((entry) {
                            return ListTile(
                              title: Text(entry.key),
                              onTap: () {
                                if (kDebugMode) {
                                  print(entry.value);
                                }
                                gmkCore.clear();
                                gmkCore.loadCode(entry.value);
                                Navigator.of(context).pop();
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 45),
              foregroundColor: Colors.black,
              side: const BorderSide(
                color: Color.fromARGB(0, 0, 0, 0),
                width: 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: Text(
              'Demo',
              style: TextStyle(
                color: gmkCore.gmkStructure.gmkStyle.onPrimaryContainer,
              ),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.black54),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () {
                  String code = gmkCore.generateCode(); // 假设这是你生成的一段代码或字符串
                  if (kDebugMode) {
                    print(code);
                  }

                  // 显示 SnackBar，带有一个“复制”按钮
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('调试台：$code'),
                      duration: const Duration(seconds: 10), // SnackBar 显示时长
                      action: SnackBarAction(
                        label: '复制', // 按钮文字
                        onPressed: () {
                          // 点击“复制”按钮时执行的逻辑
                          Clipboard.setData(ClipboardData(text: code))
                              .then((_) {
                                // 可选：复制成功后提示用户
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('已复制到剪贴板！'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              })
                              .catchError((error) {
                                // 可选：处理复制失败的情况
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('复制失败！'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              });
                        },
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 45),
                  foregroundColor: Colors.black,
                  side: const BorderSide(
                    color: Color.fromARGB(0, 0, 0, 0),
                    width: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text(
                  '导出代码',
                  style: TextStyle(
                    color: gmkCore.gmkStructure.gmkStyle.onPrimaryContainer,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  // 导航到 GML 编辑器页面
                  Navigator.pushNamed(
                    context,
                    '/gml-editor',
                    arguments: {'initialCode': '初始代码内容'}, // 可选：传递初始代码
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 45),
                  foregroundColor: Colors.black,
                  side: const BorderSide(
                    color: Color.fromARGB(0, 0, 0, 0),
                    width: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text(
                  '导入代码',
                  style: TextStyle(
                    color: gmkCore.gmkStructure.gmkStyle.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
