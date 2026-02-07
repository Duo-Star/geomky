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

//
import 'Btn.dart' as btn;

SingleChildScrollView page(context, GMKCore gmkCore, Monxiv monxiv) {
  String type = monxiv.getSelectType();
  GMKCommand? cmd = monxiv.getSelectCMD();
  GraphOBJ? va = monxiv.getSelectOBJ();
  if (type == 'Triangle') {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${va?.obj.toString()}, ${cmd.toString()}',
                  style: TextStyle(
                    color: monxiv.gmkStructure.gmkStyle.onPrimaryContainer,
                  ),
                ),
                Text(
                  '${va?.obj.toString()}, ${cmd.toString()}',
                  style: TextStyle(
                    color: monxiv.gmkStructure.gmkStyle.onPrimaryContainer,
                  ),
                ),
              ],
            ),

            btn.simpleBtn(monxiv, 's', () {
              print(0);
            }),
          ],
        ),
      ),
    );
  }
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: IntrinsicHeight(
      child: Center(child: Text('属性内容页', style: TextStyle(fontSize: 12))),
    ),
  );
}
