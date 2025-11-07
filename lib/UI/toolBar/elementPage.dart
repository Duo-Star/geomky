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
import 'stateBtn.dart' as state_btn;

SingleChildScrollView page(context, GMKCore gmkCore, Monxiv monxiv) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          state_btn.combStateBtn(monxiv, ["假装自己是个组件", 'zj'], []),
          state_btn.combStateBtn(monxiv, ["按钮", 'BTN'], []),
          state_btn.combStateBtn(monxiv, ["文字", 'TXT'], []),
          state_btn.combStateBtn(monxiv, ["选框", 'BOOL'], []),
          state_btn.combStateBtn(monxiv, ["图片", 'IMG'], []),
        ],
      ),
    ),
  );
}
