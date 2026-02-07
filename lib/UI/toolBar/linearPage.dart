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
  return   SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          state_btn.combStateBtn(monxiv, ["点", 'P'], [
            ["中点",'P:midP'],
            ["交点",'Ins^dy'],
            ["消骈交点",'Ins^nf'],
          ]),
          state_btn.combStateBtn(monxiv, ["直线",'L'], [
            ["点向",'L:pv']
          ]),
          state_btn.combStateBtn(monxiv, ["线段",'S'], []),
          state_btn.combStateBtn(monxiv, ["三角形",'T'], []),
          state_btn.combStateBtn(monxiv, ["多边形",'Poly'], []),
        ],
      ),
    ),
  );
}
