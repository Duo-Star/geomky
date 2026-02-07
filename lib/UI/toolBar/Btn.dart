library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../MathForest/main.dart';


Row combStateBtn(Monxiv monxiv, List<String> toolName, List<List<String>> list) {
  if (list.isEmpty) {
    return simpleStateBtn(monxiv, toolName);
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // 使用Container而不是Expanded，提供合理的宽度约束
      Container(
        constraints: BoxConstraints(
          minWidth: 60, // 最小宽度
          maxWidth: 100, // 最大宽度
        ),
        height: 60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 上方按钮
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  monxiv.toolSelect = toolName[1];
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 2.0), // 添加水平内边距
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Color.fromARGB(0, 0, 0, 0), width: 0),
                  backgroundColor: (monxiv.toolSelect == toolName[1])
                      ? monxiv.gmkStructure.gmkStyle.primary
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Center(
                  child: Text(
                    toolName[0],
                    style: TextStyle(
                      color: (monxiv.toolSelect == toolName[1])
                          ? monxiv.gmkStructure.gmkStyle.onPrimary
                          : monxiv.gmkStructure.gmkStyle.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
            ),

            // 下方弹出菜单按钮
            Container(
              height: 20,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (kDebugMode) {
                    print('选择了: $value');
                  }
                  monxiv.toolSelect = value;
                },
                tooltip:'',
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                color: monxiv.gmkStructure.gmkStyle.secondary,
                child: Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.transparent,
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: monxiv.gmkStructure.gmkStyle.onPrimaryContainer,
                  ),
                ),
                itemBuilder: (BuildContext context) => list.map((item) {
                  return PopupMenuItem<String>(
                    value: item[1],
                    height: 42,
                    child: Text(
                      item[0],
                      style: TextStyle(
                        fontSize: 15,
                        color: monxiv.gmkStructure.gmkStyle.onSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),

      // 垂直分隔线
      Container(
        width: 1,
        color: Colors.black54,
      ),
    ],
  );
}



//
//
Row simpleStateBtn(Monxiv monxiv, List<String> toolName) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      OutlinedButton(
        onPressed: () {
          monxiv.toolSelect = toolName[1];
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 45),
          foregroundColor: Colors.black,
          side: const BorderSide(color: Color.fromARGB(0, 0, 0, 0), width: 0),
          backgroundColor: (monxiv.toolSelect == toolName[1])
              ? monxiv.gmkStructure.gmkStyle.primary
              : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        child: Text(
          toolName[0],
          style: TextStyle(
            color: (monxiv.toolSelect == toolName[1])
                ? monxiv.gmkStructure.gmkStyle.onPrimary
                : monxiv.gmkStructure.gmkStyle.onPrimaryContainer,
          ),
        ),
      ),
      VerticalDivider(width: 1, color: Colors.black54),
    ],
  );
}


//
Row simpleBtn(Monxiv monxiv, String s, Function f) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      OutlinedButton(
        onPressed: f(),
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
            color: monxiv.gmkStructure.gmkStyle.onPrimaryContainer,
          ),
        ),
      ),
      VerticalDivider(width: 1, color: Colors.black54),
    ],
  );
}
