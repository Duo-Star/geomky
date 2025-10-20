/*
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
      Particle(Vec3(0,1), Vec3(.1), Vec3()),
      Particle(Vec3(0,2), Vec3(), Vec3())
    ]);

    // 添加测试形状
    _physicsState.shapes.add(Polygon([Vector(-1, -1), Vector(1, -1), Vector(1, 1), Vector(-1, 1)]),);


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

    Vec3 gf = Vec3(0,-3);
    Friction airFr = Friction(1, .08, 'Air');

    state.particles[0].p = Vec3();

    Vec3 f01 = sp.pLINKp(state.particles[0], state.particles[1]);
    Vec3 f12 = sp.pLINKp(state.particles[1], state.particles[2]);

    state.particles[1].setF(f01 - f12 + gf + airFr.pLINK(state.particles[1]));

    state.particles[2].setF(f12 + gf + airFr.pLINK(state.particles[2]));

    state.particles[1].update(dt);
    state.particles[2].update(dt);

    state.shapes[0] = Polygon([state.particles[0].p.vec2,
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
            height: 50,
            color: Colors.blueGrey[100],
            child: DefaultTabController(
              initialIndex: 3,
              length: 8,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('GeoMKY - welcome pakoo lib'),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.add_alert),
                      tooltip: 'Show Snackbar',
                      onPressed: () {
                        //hihi();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.file_copy_outlined),
                      tooltip: 'Show Snackbar',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('This is a snackbar')),
                        );

                        List<dynamic> fac = GMKCompiler.str2Factor('1,3.14,a,<b>,T,<1,2>');
                        for (var item in fac) {
                          print('$item: ${item.runtimeType}');
                        }




                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.navigate_next),
                      tooltip: 'Go to the next page',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return Scaffold(
                                appBar: AppBar(title: const Text('Next page')),
                                body: const Center(
                                  child: Text(
                                    'This is the next page',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

 */
