import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//
import '../../MathForest/main.dart';
import '../../MathForest/Geometry/D2/GMK/Core/GMKCompiler.dart' as compiler;
import '../../MathForest/Geometry/D2/GMK/Core/GMKLib.dart' as g_lib;

//
import '../../MathForest/Geometry/D2/GMK/Monxiv/basicPainter.dart' as painter;
//
import 'hua.dart';

void main() {
  runApp(const MyApp());
}

// 状态类 - 用于在GMK运算和绘图之间传递数据
class GameState {
  GMKData gmkData = GMKData({});
  double time = 0.0;
  List<Hua> huas = [];

  GameState();

  // 复制方法，用于在状态更新时保持引用不变
  GameState copy() {
    final newState = GameState();
    newState.gmkData = gmkData;
    newState.time = time;
    newState.huas = huas;
    return newState;
  }
}

class MyPainter extends CustomPainter {
  final Monxiv monxiv;
  final GameState gameState; // 接收GMK状态

  MyPainter({required this.monxiv, required this.gameState});

  @override
  void paint(Canvas canvas, Size size) {
    monxiv.setSize(size);
    if (monxiv.p.x == 0) {
      monxiv.reset();
    }
    monxiv.setCanvas(canvas);
    GMKData gmkData = gameState.gmkData;
    monxiv.setGMKData(gmkData);
    monxiv.frameAxis = true;
    monxiv.frameGrid = true;
    monxiv.draw();
    //

    /*
   num  R = 6.0;
    num  r = 2.2;
   int  lineCount = 100;
    for (int i = 0; i < lineCount; i++) {
      num  d = 1.0 + (i / lineCount) * 5.0;
      x(t) => (R - r) * cos(t) + d * cos(((R - r) / r) * t);
      y(t) => (R - r) * sin(t) - d * sin(((R - r) / r) * t);
      painter.drawT2PFunction((t){
        return Vector(x(t), y(t));
      }, monxiv, from: 0, to: 88,dt: 0.1, paint: Paint()..color=
      Color(Random().nextInt(0xaaFFFFFF) + 0xaa000000)..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
      );
    }
     */

    /*
    for (num theta = 0; theta < 2 * pi; theta += 0.01) {
      painter.drawT2PFunction((t){


        return Vector.newAL(theta, 1)+Vector.newAL(theta+pi*.5, 1)*t;
      }, monxiv, from: -100, to: 100, paint: Paint()..color=
         Color(Random().nextInt(0xaaFFFFFF) + 0xaa000000)..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
      );
    }

    painter.drawT2PFunction((t){
      return Vector.newAL(10*t,t);
    }, monxiv, from: 0, to: 100,dt: 0.01, paint: Paint()..color=
    Color(Random().nextInt(0xFFFFFFFF) + 0xFF000000)..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
    );
*/

    //
    for (Hua itemHua in gameState.huas) {
      painter.drawSegmentBy2P(
        itemHua.p1.p,
        itemHua.p2.p,
        monxiv,
        paint: Paint()
          ..color = Color(0xaa000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
      //  painter.drawSegmentBy2P(itemHua.p1.p+, p2_, monxiv)
    }
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
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
  GameState gameState = GameState();
  GMKCore gmkCore = GMKCore();

  // 物理模拟参数
  static const double physicsTimeStep = 0.008;

  @override
  void initState() {
    super.initState();

    for (var i in List.generate(5, (index) => index)) {
      gameState.huas.add(
        Hua.newHua(
            Vector.randomXY(
              RandomMaster.normal(mean: 0, stddev: 1.0),
              RandomMaster.normal(mean: 0, stddev: 1.0),
            ),
            1,
          )
          ..dFire.n1 = 10
          ..dFire.n2 = 10,
      );
    }

    try {
      String code = widget.code;
      code = '''
>style castle

      ''';
      print(code);
      gmkCore.loadCode(code);
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
    GameState newState = gameState.copy();

    // GMK 运行
    _runGMK(newState, physicsTimeStep);

    PEnv env = PEnv();
    env.dt = physicsTimeStep;
    for (Hua itemHua in gameState.huas) {
      itemHua.update(env);
    }

    // 更新状态（在下一帧绘制时生效）
    setState(() {
      gameState = newState;
    });
  }

  void _runGMK(GameState state, double dt) {
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
                      painter: MyPainter(monxiv: monxiv, gameState: gameState),
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
                length: 2,
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
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [],
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [],
                              ),
                            ),
                          ),
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
                        /*
                         const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () {},
                              child: Text(
                                '取消',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: gmkCore.gmkStructure.gmkStyle.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    gmkCore.gmkStructure.gmkStyle.primary,
                              ),
                              child: Text(
                                '确定',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      gmkCore.gmkStructure.gmkStyle.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
            */
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
