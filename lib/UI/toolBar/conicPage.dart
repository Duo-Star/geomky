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
          state_btn.combStateBtn(
            monxiv,
            ["圆", 'C:op'],
            [
              ["圆心和半径", 'C'],
              ["三点圆", 'C:3p'],
              ["圆心和半径线段", 'C:orl'],
            ],
          ),
          state_btn.combStateBtn(
            monxiv,
            ["椭圆", 'C0'],
            [
              ["焦点和一点", 'CO:fp'],
            ],
          ),
          state_btn.combStateBtn(
            monxiv,
            ["抛物线", 'C1'],
            [
              ['顶点和焦点', 'C1:of'],
              ['准线和焦点', 'C1:lf'],
            ],
          ),
          state_btn.combStateBtn(
            monxiv,
            ["双曲线", 'C2'],
            [
              ['焦点和一点', 'C2:fp'],
            ],
          ),
          state_btn.combStateBtn(
            monxiv,
            ["轨道", 'HL'],
            [
              ['两直线', 'HL:2l'],
            ],
          ),
          state_btn.combStateBtn(
            monxiv,
            ["叉线", 'XL'],
            [
              ['两直线', 'XL:2l'],
            ],
          ),
          state_btn.combStateBtn(monxiv, ["虚空", ''], []),
        ],
      ),
    ),
  );
}
