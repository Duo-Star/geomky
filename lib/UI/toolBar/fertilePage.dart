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
import 'Btn.dart' as state_btn;

SingleChildScrollView page(context, GMKCore gmkCore, Monxiv monxiv) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          state_btn.combStateBtn(
            monxiv,
            ["骈点", 'DP'],
            [
              ['中心和一点', 'DP:cp'],
            ],
          ),
          state_btn.combStateBtn(monxiv, ["汆点", 'TP'], []),
          state_btn.combStateBtn(monxiv, ["合点", 'QP'], []),
          state_btn.combStateBtn(monxiv, ["骈叉线", 'DXL'], []),
        ],
      ),
    ),
  );
}
