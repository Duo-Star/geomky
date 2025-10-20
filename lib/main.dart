import 'dart:async';
import 'package:flutter/material.dart';

import 'MathForest/main.dart';
import 'MathForest/Geometry/D2/GMK/Core/GMKCompiler.dart' as GMKCompiler;

void main() {
  runApp(const MyApp());
}

// 物理状态类 - 用于在物理模拟和绘图之间传递数据
class PhysicsState {
  List<Particle> particles = [];
  List<Polygon> shapes = [];
  double time = 0.0;

  // 添加其他你需要的物理变量...
  Vector gravity = Vector(0, -1);
  List<Dots> dynamicDots = [];

  PhysicsState();

  // 复制方法，用于在状态更新时保持引用不变
  PhysicsState copy() {
    final newState = PhysicsState();
    newState.particles = List<Particle>.from(particles);
    newState.shapes = List<Polygon>.from(shapes);
    newState.time = time;
    newState.gravity = gravity;
    newState.dynamicDots = List<Dots>.from(dynamicDots);
    return newState;
  }
}

class MyPainter extends CustomPainter {
  final Monxiv monxiv;
  final PhysicsState physicsState; // 接收物理状态

  MyPainter({required this.monxiv, required this.physicsState});

  @override
  void paint(Canvas canvas, Size size) {
    monxiv.setSize(size);
    monxiv.drawFramework(canvas);

    // 绘制静态内容
    Dots ds = Dots.randomFill(
      5,
      RandomMaster.normal(mean: 0, stddev: 1.0),
      RandomMaster.normal(mean: 0, stddev: 1.0),
    );
    // Polygon polygon = ds.tight;
    // monxiv.drawDots(ds, canvas);
    // monxiv.drawPolygon(polygon, canvas);

    // monxiv.drawPolygon(Polygon([Vector(), Vector(1), Vector(0, 1)]), canvas);
    monxiv.drawPoint(Vector(), canvas);

    // 绘制物理模拟的动态内容
    _drawPhysicsContent(canvas);
  }

  void _drawPhysicsContent(Canvas canvas) {
    // 绘制粒子
    for (final particle in physicsState.particles) {
      monxiv.drawPoint(particle.p.vec2, canvas);
    }

    // 绘制形状
    for (final shape in physicsState.shapes) {
      monxiv.drawPolygon(shape, canvas);
    }
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    return monxiv != oldDelegate.monxiv ||
        physicsState != oldDelegate.physicsState;
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
          seedColor: Color.fromARGB(255,230,228,186),
        ),
      ),
      home: const MyHomePage(title: 'GeoMKY'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer _physicsTimer;

  // 使用Monxiv管理视图变换
  Monxiv monxiv = Monxiv()
    ..reset()
    ..infoMode = false;

  // 物理状态
  PhysicsState _physicsState = PhysicsState();

  // 物理模拟参数
  static const double fixedDt = 0.008;
  static const double physicsTimeStep = fixedDt;
  double _accumulator = 0.0;

  @override
  void initState() {
    super.initState();

    // 初始化物理状态
    _initializePhysics();

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
      _updatePhysics,
    );
  }

  void _initializePhysics() {
    // 在这里初始化你的物理世界
    // 例如：添加一些测试粒子
    _physicsState.particles.addAll([
      Particle(Vec3(), Vec3(), Vec3()),
      Particle(Vec3(0, 1), Vec3(.1), Vec3()),
      Particle(Vec3(0, 2), Vec3(), Vec3()),
    ]);

    // 添加测试形状
    _physicsState.shapes.add(
      Polygon([Vector(-1, -1), Vector(1, -1), Vector(1, 1), Vector(-1, 1)]),
    );
  }

  void _updatePhysics(Timer timer) {
    // 固定时间步长的物理更新
    _accumulator += physicsTimeStep;

    // 更新物理状态
    final newState = _physicsState.copy();

    // ===== 在这里编写你的物理模拟代码 =====
    _runPhysicsSimulation(newState, physicsTimeStep);
    // ===================================

    // 更新状态（在下一帧绘制时生效）
    setState(() {
      _physicsState = newState;
    });
  }

  void _runPhysicsSimulation(PhysicsState state, double dt) {
    Spring sp = Spring(1e4, 1);

    Vec3 gf = Vec3(0, -3);
    Friction airFr = Friction(1, .08, 'Air');

    state.particles[0].p = Vec3();

    Vec3 f01 = sp.pLINKp(state.particles[0], state.particles[1]);
    Vec3 f12 = sp.pLINKp(state.particles[1], state.particles[2]);

    state.particles[1].setF(f01 - f12 + gf + airFr.pLINK(state.particles[1]));

    state.particles[2].setF(f12 + gf + airFr.pLINK(state.particles[2]));

    state.particles[1].update(dt);
    state.particles[2].update(dt);

    state.shapes[0] = Polygon([
      state.particles[0].p.vec2,
      state.particles[1].p.vec2,
      state.particles[2].p.vec2,
      state.particles[1].p.vec2,
    ]);

    state.time += dt;
  }

  @override
  void dispose() {
    _physicsTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                    painter: MyPainter(
                      monxiv: monxiv,
                      physicsState: _physicsState, // 传递物理状态给绘图器
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  );
                },
              ),
            ),
          ),

          Container(
            height: 55,
            color: Colors.blueGrey[100],
            child: DefaultTabController(
              initialIndex: 3,
              length: 8,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('GeoMKY - 最小测试单元'),
                  actions: <Widget>[

                    PopupMenuButton<String>(
                      onSelected: (value) {
                        print('选择了: $value');
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'home',
                          child: Text('保存'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Text('导入'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('加载'),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary, // 按钮背景色
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: '文件',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 20),

                    PopupMenuButton<String>(
                      onSelected: (value) {
                        print('选择了: $value');
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'home',
                          child: Text('点'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Text('直线'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('圆周'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('亏-Conic0'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('齐-Conic1'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('超-Conic2'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('交叉'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('轨道'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('虚空'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('骈点'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('合点'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('骈叉'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('点集'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('三角'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('多边形'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('正矩形'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('文本'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('MD'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('按钮'),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: '新',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 6),

                    PopupMenuButton<String>(
                      onSelected: (value) {
                        print('选择了: $value');
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Text('交点'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'home',
                          child: Text('平行线'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Text('垂线'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Text('中垂线'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('角分线'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('中点'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('切线'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('极线'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('极点'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('对称'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('反演'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('投影'),
                        ),

                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: '构造',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 6),

                    PopupMenuButton<String>(
                      onSelected: (value) {
                        print('选择了: $value');
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'home',
                          child: Text('圆心-中心'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Text('焦点'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('准线'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('长轴端点'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('短轴端点'),
                        ),

                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: '属性',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 6),

                    IconButton(
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
                                              title: const Text('参数列解析器'),
                                              subtitle: const Text('GMKCompiler.str2Factor'),
                                              trailing: IconButton(
                                                onPressed: () {
                                                  String msg = '控制台';
                                                  void m(String str) {
                                                    msg = '$msg\n$str';
                                                  }

                                                  String str =
                                                      '1, 1.23, .PI, .NAN, .INF,  a, <b>, .T, <3,4>, <1.23, 4.56>, <.PI, .PI>, <.NAN, .INF>, .I;';
                                                  m('-----------原始-----------');
                                                  m(str);

                                                  m('-----------参数列-----------');
                                                  List<dynamic> fac = GMKCompiler.str2Factor(str);
                                                  for (var item in fac) {
                                                    m('$item, type:${item.runtimeType}');
                                                  }

                                                  m('-----------还原-----------');
                                                  m(GMKCompiler.factor2Str(fac));
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


                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                  /*
                  bottom: TabBar(
                    tabs: const <Widget>[
                      Tab(text: '文件'),
                      Tab(text: '工具'),
                      Tab(text: '属性'),
                      Tab(text: '线性'),
                      Tab(text: '经典'),
                      Tab(text: '退化'),
                      Tab(text: '共生'),
                      Tab(text: '元素'),
                    ],
                  ),
                   */
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
