import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'MathForest/main.dart';
import 'MathForest/Geometry/D2/GMK/Core/GMKCompiler.dart' as compiler;

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
    monxiv.drawFramework(canvas);
/*
    Dots ds = Dots.randomFill(
      1000,
      RandomMaster.normal(mean: 5, stddev: 1.0),
      RandomMaster.normal(mean: 5, stddev: 1.0),
    );
    Polygon polygon = ds.tight;
    monxiv.drawDots(ds, canvas);
    monxiv.drawPolygon(polygon, canvas);
 */

    monxiv.drawPoint(Vector(), canvas);

    GMKData gmkData = gmkState.gmkData;

    monxiv.drawGMKData(gmkData, canvas);

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
          seedColor: Color.fromARGB(255, 230, 228, 186),
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
    ..reset(Vector(250, 250))
    ..infoMode = false;

  // 物理状态
  GMKState _gmkState = GMKState();

  GMKCore gmkCore = GMKCore();

  // 物理模拟参数
  static const double physicsTimeStep = 0.008;

  @override
  void initState() {
    super.initState();

    // 加载源码
    gmkCore.loadCode('''
``@A is P of 1 1
@x is N of .E
@B is P of <x> .PI
@C is P:v of <2 2>
@D is P^mid of <C> <A>``

@qn1 is QN of 0 1 1.2 2
@c is C:pr of .O 1



''');

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
    state.gmkData = gmkCore.run();
    state.time += dt;
  }

  Card debugZone(String title, String subTitle, Function todo) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.ac_unit_rounded),
              title: Text(title),
              subtitle: Text(subTitle),
              trailing: IconButton(
                onPressed: () {
                  String s = todo();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('调试台：\n$s'),duration: const Duration(seconds: 10)));
                },
                icon: const Icon(Icons.accessibility_new_rounded),
                tooltip: '调试',
              ),
            ),
            // ... 其他内容
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _physicsTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    monxiv.bgc = Theme.of(context).colorScheme.primaryContainer.withAlpha(30);
    // 设置沉浸式状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return SafeArea(
      child: Scaffold(
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
                        gmkState: _gmkState, // 传递物理状态给绘图器
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
                          if (kDebugMode) {
                            print('选择了: $value');
                          }
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary, // 按钮背景色
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
                          if (kDebugMode) {
                            print('选择了: $value');
                          }
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text.rich(
                            TextSpan(
                              text: '新',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 6),

                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (kDebugMode) {
                            print('选择了: $value');
                          }
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text.rich(
                            TextSpan(
                              text: '构造',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 6),

                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (kDebugMode) {
                            print('选择了: $value');
                          }
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text.rich(
                            TextSpan(
                              text: '属性',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
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
                                  appBar: AppBar(
                                    title: const Text('Debug Library'),
                                  ),
                                  body: ListView(
                                    children: [
                                      Card(
                                        margin: EdgeInsets.all(
                                          10,
                                        ), // 建议添加外边距，使卡片间有间隔[1](@ref)
                                        elevation: 3.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6.0,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.ac_unit_rounded,
                                                ),
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
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(msg),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons
                                                        .accessibility_new_rounded,
                                                  ),
                                                  tooltip: '调试',
                                                ),
                                              ),
                                              // ... 其他内容
                                            ],
                                          ),
                                        ),
                                      ),

                                      Card(
                                        margin: EdgeInsets.all(10),
                                        elevation: 3.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6.0,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.ac_unit_rounded,
                                                ),
                                                title: const Text('参数列解析器'),
                                                subtitle: const Text(
                                                  'GMKCompiler.str2Factor',
                                                ),
                                                trailing: IconButton(
                                                  onPressed: () {
                                                    String msg = '控制台';
                                                    void m(String str) {
                                                      msg = '$msg\n$str';
                                                    }

                                                    void lll([String? str]) {
                                                      msg =
                                                          '$msg\n-----------|${str ?? ''}|-----------';
                                                    }

                                                    String str =
                                                        '1 1.23 .PI .NAN .INF a <b> .T <3 4> <1.23 4.56> <.PI .PI> <.NAN .INF> .I';
                                                    m(
                                                      '-----------原始-----------',
                                                    );
                                                    m(str);

                                                    m(
                                                      '-----------参数列-----------',
                                                    );
                                                    List<dynamic> fac =
                                                        compiler.str2Factor(
                                                          str,
                                                        );
                                                    for (var item in fac) {
                                                      m(
                                                        '$item, type:${item.runtimeType}',
                                                      );
                                                    }

                                                    m(
                                                      '-----------还原-----------',
                                                    );
                                                    m(
                                                      compiler.factor2Str(
                                                        fac,
                                                      ),
                                                    );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(msg),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons
                                                        .accessibility_new_rounded,
                                                  ),
                                                  tooltip: '调试',
                                                ),
                                              ),
                                              // ... 其他内容
                                            ],
                                          ),
                                        ),
                                      ),

                                      debugZone('GMK编译', 'GMKCompiler', () {
                                        String msg = '控制台';
                                        void m(String str) {
                                          msg = '$msg\n$str';
                                        }

                                        void lll([String? str]) {
                                          msg =
                                              '$msg\n-----------|${str ?? ''}|-----------';
                                        }

                                        String code = '''
@A is P of 1 1
@c is C of .O <.PI 0>
@l is L of <A> .I
                                                  ''';
                                        lll();
                                        m('gmk源代码\n$code');
                                        GMKCore gmkCore = GMKCore();
                                        gmkCore.loadCode(code);
                                        lll('结构');
                                        m(
                                          'printStructure:\n${gmkCore.printStructure()}',
                                        );
                                        lll('生成代码');
                                        m(
                                          'generatedCode:\n${gmkCore.generatedCode()}',
                                        );
                                        return msg;
                                      }),
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
                      Tab(text: '新'),
                      Tab(text: '构造'),
                      Tab(text: '属性'),
                      Tab(text: '操作')
                    ],
                  ),
                   */
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
