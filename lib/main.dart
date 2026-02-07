import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//
import 'UI/gmkCodeEditor.dart';
import 'UI/toolBar/Btn.dart' as state_btn;
import 'UI/toolBar/filePage.dart' as file_page;
import 'UI/toolBar/linearPage.dart' as linear_page;
import 'UI/toolBar/conicPage.dart' as conic_page;
import 'UI/toolBar/fertilePage.dart' as fertile_page;
import 'UI/toolBar/elementPage.dart' as element_page;
import 'UI/toolBar/attributePage.dart' as attribute_page;

//
import 'MathForest/main.dart';
import 'MathForest/Geometry/D2/GMK/Core/GMKCompiler.dart' as compiler;
import 'MathForest/Geometry/D2/GMK/Core/GMKLib.dart' as g_lib;

//
import 'MathForest/Geometry/D2/GMK/Monxiv/basicPainter.dart' as painter;

//
import 'UI/debugLibrary.dart' as debug_library;
import 'demoGMK.dart' as demo_gmk;

void main() {
  runApp(const MyApp());
}

// 状态类 - 用于在GMK运算和绘图之间传递数据
class GMKState {
  GMKData gmkData = GMKData({});
  double time = 0.0;
  GMKState();

  // 复制方法，用于在状态更新时保持引用不变
  GMKState copy() {
    final newState = GMKState();
    newState.gmkData = gmkData;
    newState.time = time;
    return newState;
  }
}

class MyPainter extends CustomPainter {
  final Monxiv monxiv;
  final GMKState gmkState; // 接收GMK状态

  MyPainter({required this.monxiv, required this.gmkState});

  @override
  void paint(Canvas canvas, Size size) {
    monxiv.setSize(size);
    if (monxiv.p.x == 0) {
      monxiv.reset();
    }
    monxiv.setCanvas(canvas);
    GMKData gmkData = gmkState.gmkData;
    monxiv.setGMKData(gmkData);
    monxiv.draw();

/*
    painter.drawT2PFunction((t){
      num x= t;
      return Vector(t, (math.pow(x,(x+1)))/(math.pow((x+1), x)));
    },dt:0.005, monxiv);

 */



    /*
    Dots ds = Dots.randomFill(
      1000,
      RandomMaster.normal(mean: 5, stddev: 1.0),
      RandomMaster.normal(mean: 5, stddev: 1.0),
    );
    Polygon polygon = ds.tight;
    painter.drawDots(ds, monxiv);
    painter.drawPolygon(polygon, monxiv);
     */

    //print(gmkData.data['A']);
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    //return monxiv != oldDelegate.monxiv || physicsState != oldDelegate.physicsState;
    return true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoMKY',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 0, 228, 186),
        ),
      ),
      home: const MyHomePage(title: 'GeoMKY', code: ''),
      routes: {
        '/gml-editor': (context) => const GmkEditorPage(),

        '/gmk': (context) {
          // 从路由参数中获取传递的 code
          final args = ModalRoute.of(context)!.settings.arguments;
          String code = '';

          if (args is Map<String, String>) {
            code = args['code'] ?? '默认代码（未传参）';
          } else {
            code = '参数格式错误，使用默认代码';
          }

          // 返回你的目标页面，并传入动态 code
          return MyHomePage(
            title: 'GML 编辑器',
            code: code, // ✅ 动态代码内容
          );
        },
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.code});

  final String title;
  final String code;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer _physicsTimer;

  // 使用Monxiv管理视图变换
  Monxiv monxiv = Monxiv();

  // 物理状态
  GMKState _gmkState = GMKState();
  GMKCore gmkCore = GMKCore();

  // 物理模拟参数
  static const double physicsTimeStep = 0.008;

  @override
  void initState() {
    super.initState();

    try {
      // 加载源码

      String? code = widget.code;
      code = '''
>style deep-ocean
@c is C of .O 1
@tri1 is Tri of .O .I .J
#tri1 red

''';

      code = '''
@p1 is P of 1 1
@p2 is P of 2 1
@c1_1 is P of <p1> <p2>
''';
      code = demo_gmk.demo['regularPentagonal'];
      print(code);
      gmkCore.loadCode(code!);
      //
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('错误: $e');
        print('堆栈跟踪: $stackTrace');
      }
    }

    // 持续重绘的动画控制器
    _animationController = AnimationController(
      duration: const Duration(days: 114514),
      vsync: this,
    )..repeat();

    // 监听动画帧，用于重绘
    _animationController.addListener(() {
      setState(() {});
    });

    // 固定时间步长的物理定时器
    _physicsTimer = Timer.periodic(
      Duration(milliseconds: (physicsTimeStep * 1000).round()),
      _updateGMK,
    );
  }

  void _updateGMK(Timer timer) {
    // 更新物理状态
    GMKState newState = _gmkState.copy();

    // GMK 运行
    _runGMK(newState, physicsTimeStep);

    // 更新状态（在下一帧绘制时生效）
    setState(() {
      _gmkState = newState;
    });
  }

  void _runGMK(GMKState state, double dt) {
    monxiv.gmkStructure = gmkCore.gmkStructure;
    gmkCore.setTime(state.time);
    state.gmkData = gmkCore.run();
    state.time += dt;
  }

  @override
  void dispose() {
    _physicsTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // 1. 新增状态：控制左下角浮动卡片的可见性
  bool toolCardVisible = false;
  double tabBarH = 34;
  double tabPageH = 80;
  double toolCardTitleSize = 22;
  double toolCardTextSize = 18;

  //
  @override
  Widget build(BuildContext context) {
    // 你的原始变量
    String selectLabel = monxiv.selectLabel;
    //monxiv.bgc = Theme.of(context).colorScheme.surface..withAlpha(1);

    // 设置沉浸式 UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return SafeArea(
      child: Scaffold(
        // 新增：一个按钮来演示如何调用函数切换卡片
        floatingActionButton: Visibility(
          visible: (monxiv.toolSelect != ''),
          child: FloatingActionButton(
            onPressed: () {
              monxiv.toolSelect = '';
            },
            backgroundColor: gmkCore.gmkStructure.gmkStyle.primaryContainer,
            tooltip: '切换到移动工具',
            child: Icon(Icons.add_business_rounded),
          ),
        ),
        body: Stack(
          children: [
            // --- 绘图区 (第一层: 底部) ---
            Listener(
              onPointerSignal: monxiv.handlePointerSignal,
              child: GestureDetector(
                onScaleStart: monxiv.handleScaleStart,
                onScaleUpdate: monxiv.handleScaleUpdate,
                onScaleEnd: monxiv.handleScaleEnd,
                onDoubleTap: monxiv.handleDoubleTap,
                onTap: monxiv.onTap,
                onTapDown: monxiv.onTapDown,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      painter: MyPainter(monxiv: monxiv, gmkState: _gmkState),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    );
                  },
                ),
              ),
            ),

            // --- 顶部 TabBar & TabBarView (第二层) ---
            Container(
              height: tabBarH + tabPageH,
              color: gmkCore.gmkStructure.gmkStyle.secondaryContainer,
              child: DefaultTabController(
                initialIndex: () {
                  return selectLabel == '' ? 1 : 2;
                }(),
                length: 6,
                child: Column(
                  children: [
                    Container(
                      height: tabBarH,
                      color: gmkCore.gmkStructure.gmkStyle.secondaryContainer,
                      child: TabBar(
                        isScrollable: true,
                        indicatorColor:
                            gmkCore.gmkStructure.gmkStyle.onPrimaryContainer,
                        labelColor:
                            gmkCore.gmkStructure.gmkStyle.onPrimaryContainer,
                        unselectedLabelColor:
                            gmkCore.gmkStructure.gmkStyle.secondary,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabAlignment: TabAlignment.start,
                        dividerHeight: 1.0,
                        tabs: [
                          const Tab(text: '文件'),
                          const Tab(text: '线性'),
                          const Tab(text: '二次'),
                          const Tab(text: '复生'),
                          const Tab(text: '组件'),
                          Tab(text: '属性 - ${monxiv.getSelectType()}: $selectLabel'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          //1. 文件选项卡内容 (水平滚动工具栏)
                          file_page.page(context, gmkCore, monxiv),

                          //2. 线性选项卡内容
                          linear_page.page(context, gmkCore, monxiv),

                          //3. conic选项卡
                          conic_page.page(context, gmkCore, monxiv),

                          //4. 复生内容页
                          fertile_page.page(context, gmkCore, monxiv),

                          //5. 组件
                          element_page.page(context, gmkCore, monxiv),

                          //6. 属性内容页
                          attribute_page.page(context, gmkCore, monxiv),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- 3. 新增浮动卡片 (第三层: 左下角) ---
            if (monxiv.toolSelect != '') // 使用条件渲染控制显示/隐藏
              Positioned(
                left: 16.0,
                bottom: 16.0,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: gmkCore.gmkStructure.gmkStyle.surface,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    width: 275, // 增加宽度以适应新控件
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '新建: ${monxiv.toolSelect}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: toolCardTitleSize,
                            color: gmkCore
                                .gmkStructure
                                .gmkStyle
                                .onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 6),

                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
