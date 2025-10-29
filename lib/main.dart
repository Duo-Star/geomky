import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//
import 'MathForest/main.dart';
import 'MathForest/Geometry/D2/GMK/Core/GMKCompiler.dart' as compiler;
import 'MathForest/Geometry/D2/GMK/Core/GMKLib.dart' as gLib;

import 'MathForest/Geometry/D2/GMK/Monxiv/painter.dart' as painter;

//
import 'UI/debugLibrary.dart' as debug_library;

void main() {
  runApp(const MyApp());
}

// 状态类 - 用于在GMK运算和绘图之间传递数据
class GMKState {
  GMKData gmkData = GMKData({});
  double time = 0.0;
  String toolSelect = '';
  GMKState();

  // 复制方法，用于在状态更新时保持引用不变
  GMKState copy() {
    final newState = GMKState();
    newState.gmkData = gmkData;
    newState.time = time;
    newState.toolSelect = toolSelect;
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
  Monxiv monxiv = Monxiv();

  // 物理状态
  GMKState _gmkState = GMKState();
  GMKCore gmkCore = GMKCore();

  // 物理模拟参数
  static const double physicsTimeStep = 0.008;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      _inputValue = _inputController.text;
    });

    // print(_gmkState.time);
    // 加载源码

    try {
      gmkCore.loadCode("""
``@A is P of 1 1
@x is N of .E
@B is P of <x> .PI
@C is P:v of <2 2>
@D is P^mid of <C> <A>
@n1 is N^mul of <time> .E
@qn1 is QN of 1 2 <n1> <time>
@c1 is C:pr of <1 1> 1
@qp1 is IndexQP of <c1> <qn1>
@p1 is QP^heart of <qp1>
@l1 is QP^deriveL of <qp1>
``
``
@p00 is P of 1 1
@p01 is P of 2 1
@n1 is N of 1
@n2 is N of 2
@n3 is N of 3
@n4 is N of 5
@c1 is C:op of <p00> <p01>
@p1 is IndexP of <c1> <n1>
@p2 is IndexP of <c1> <n2>
@p3 is IndexP of <c1> <n3>
@p4 is IndexP of <c1> <n4>
@l12 is L of <p1> <p2>
@l34 is L of <p3> <p4>
@l23 is L of <p2> <p3>
@l14 is L of <p1> <p4>
@p5 is Ins^ll of <l12> <l34>
@p6 is Ins^ll of <l23> <l14>
@准线 is L1 of <p5> <p6>
@p is IndexP of <c1> 1.2
``

/*
@p1 is P of 4 -1
@p2 is P of 5 -1
@c2 is C:op of <p1> <p2>
@p3 is P:v of <1 1>

@p4 is P of 3 4
@p5 is P of 4 4
@p6 is P of 2 5
@c0_1 is C0 of <p4> <p5> <p6>

#c2 red dotted 2
#p1 indigo
#p2 blue
#p3 forest
*/

``
[lua].|*
this is a lua script
c2 = gmk.getVar('c2')
c2.setColor(0xffffff00)
*|``


@c1 is C of .O 1
@c2 is C of .I 1
@xL is L of .O .I
@yL is L of .O .J
@dp1 is Ins^cc of <c1> <c2>
@l1 is DP^l of <dp1>
@p1 is Ins^ll of <l1> <xL>
@c3 is C:op of <p1> .J
@p2 is Ins^cl_index of <c3> <xL> 2
@c4 is C:op of .J <p2>
@dp2 is Ins^cc of <c4> <c1>
@p3 is DP^index of <dp2> 1
@p4 is DP^index of <dp2> 2
@c5 is C:op of <p3> .J
@c6 is C:op of <p4> .J
@p5 is Ins^cc_index of <c5> <c1> 1
@p6 is Ins^cc_index of <c6> <c1> 2
@poly1 is Poly of .J <p3> <p5> <p6> <p4>
@p7 is P of 3 4
@p8 is P of 4 4
@p9 is P of 2 5
@c0_1 is C0 of <p7> <p8> <p9>
#poly1 amber 1.2
#p7 labelShow

@p10 is P of 1.1975308641975309 -3.1049382716049383
@p11 is P of 6.382716049382716 -1.154320987654321
@l2 is L of <p10> <p11>
@p12 is P of 3.3683889650967833 -0.9297363206828225
@p13 is P of 4.37037037037037 -2.746913580246914
@c7 is C:op of <p12> <p13>
@dp3 is Ins^cl of <c7> <l2>
#l2 dotted
#dp1 fertileWaveLink
#dp2 fertileWaveLink
#dp3 fertileWaveLink


/*
// 椭圆
@p1 is P of 5 4
@p2 is P of 2.2 3.3
@p3 is P of 5 2
@c0 is C0 of <p1> <p2> <p3>
#c0 brown
// 准备连线
@F is P of 8.1 1.5
@G is P of 7.5 2.5
@H is P of 7.8 2.7
// 连接
@f is L of <F> <G>
@g is L of <F> <H>
// 染色 虚线
#f red dotted
#g forest dotted
// 交骈点
@dp1 is Ins^c0l of <c0> <f>
@dp2 is Ins^c0l of <c0> <g>
// 保持骈点视觉连接
#dp1 fertileWaveLink
#dp2 fertileWaveLink
// 骈点处切线
@xl1 is Tan^c0dp of <c0> <dp1>
@xl2 is Tan^c0dp of <c0> <dp2>
// 染色
#xl1 red
#xl2 forest
// 叉线中心
@M is XL^p of <xl1>
@N is XL^p of <xl2>
// 使用合点
@qp is QP of <dp1> <dp2>
#qp hide
//
@xla is QP^xl1 of <qp>
@xlb is QP^xl2 of <qp>
#xla gray
#xlb gray
//
@Q is XL^p of <xla>
@P is XL^p of <xlb>
//
@Temple is L of <Q> <P>
#Temple amber 1.5
*/

""");

      //print(gLib.method2type['C']);
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
    _inputController.dispose();
    super.dispose();
  }

  // 1. 新增状态：控制左下角浮动卡片的可见性
  bool toolCardVisible = false;
  double tabBarH = 34;
  double tabPageH = 80;
  double toolCardTitleSize = 22;
  double toolCardTextSize = 18;
  //
  // 新增状态变量：用于浮动卡片中的输入和下拉菜单
  String _inputValue = 'name';
  String _unitValue = 'P1';
  String _modeValue = 'P1';
  final List<String> _units = ['P1', 'P2', 'P3'];
  final List<String> _modes = ['P1', 'P2', 'P3'];

  // 输入框控制器
  final TextEditingController _inputController = TextEditingController(
    text: 'name',
  );

  // 2. 新增函数：切换卡片状态
  void _toggleCardVisibility() {
    setState(() {
      toolCardVisible = !toolCardVisible;
    });
  }

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
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleCardVisibility,
          tooltip: toolCardVisible ? '隐藏卡片' : '显示卡片',
          child: Icon(
            toolCardVisible ? Icons.visibility_off : Icons.visibility,
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
              color: Theme.of(context).colorScheme.surface,
              child: DefaultTabController(
                initialIndex: (){
                  return selectLabel==''?1:6;
                }(),
                length: 8,
                child: Column(
                  children: [
                    Container(
                      height: tabBarH,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: TabBar(
                        isScrollable: true,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Theme.of(
                          context,
                        ).colorScheme.primary,
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
                          const Tab(text: '视图'),
                          Tab(text: '属性:$selectLabel'),
                          const Tab(text: '关于'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // 文件选项卡内容 (水平滚动工具栏)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // 第一个按钮
                                  OutlinedButton(
                                    onPressed: () {
                                      print('保存被点击');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 45),
                                      foregroundColor: Colors.black,
                                      side: const BorderSide(
                                        color: Color.fromARGB(0, 0, 0, 0),
                                        width: 0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text('保存'),
                                  ),
                                  // 按钮组 1
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 45),
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                            color: Color.fromARGB(0, 0, 0, 0),
                                            width: 0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                        ),
                                        child: const Text('按钮1A'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 45),
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                            color: Color.fromARGB(0, 0, 0, 0),
                                            width: 0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                        ),
                                        child: const Text('按钮1B'),
                                      ),
                                    ],
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    color: Colors.black54,
                                  ),
                                  // 按钮组 2
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 45),
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                            color: Color.fromARGB(0, 0, 0, 0),
                                            width: 0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                        ),
                                        child: const Text('按钮2A'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 45),
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                            color: Color.fromARGB(0, 0, 0, 0),
                                            width: 0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                        ),
                                        child: const Text('按钮2B'),
                                      ),
                                    ],
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    color: Colors.black54,
                                  ),
                                  // 按钮组 3
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 45),
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                            color: Color.fromARGB(0, 0, 0, 0),
                                            width: 0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                        ),
                                        child: const Text('按钮3A'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 45),
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                            color: Color.fromARGB(0, 0, 0, 0),
                                            width: 0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                        ),
                                        child: const Text('按钮3B'),
                                      ),
                                    ],
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 线性选项卡内容
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      _gmkState.toolSelect = '点';
                                      toolCardVisible = true;
                                    },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 45),
                                      foregroundColor: Colors.black,
                                      side: const BorderSide(
                                        color: Color.fromARGB(0, 0, 0, 0),
                                        width: 0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: const Text('点'),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          print('按钮4A被点击');
                                        },
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 45),
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                            color: Color.fromARGB(0, 0, 0, 0),
                                            width: 0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                        ),
                                        child: const Text('按钮4A'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          print('按钮4B被点击');
                                        },
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 45),
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                            color: Color.fromARGB(0, 0, 0, 0),
                                            width: 0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                        ),
                                        child: const Text('按钮4B'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 其他选项卡
                          Center(
                            child: Text(
                              '二次内容页',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Center(
                            child: Text(
                              '复生内容页',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Center(
                            child: Text(
                              '组件内容页',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Center(
                            child: Text(
                              '视图内容页',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Center(
                            child: Text(
                              '属性内容页',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Center(
                            child: Text(
                              '关于内容页',
                              style: TextStyle(fontSize: 12),
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
            if (toolCardVisible) // 使用条件渲染控制显示/隐藏
              Positioned(
                left: 16.0,
                bottom: 16.0,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    width: 275, // 增加宽度以适应新控件
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '新建',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: toolCardTitleSize,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 替换后的横向输入和选择控件
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 1. 输入框
                            Text(
                              '@',
                              style: TextStyle(fontSize: toolCardTextSize),
                            ),
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: _inputController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: toolCardTextSize),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 3,
                                    horizontal: 3,
                                  ),
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),

                            // 2. 文字和下拉选项 1 (单位)
                            Text(
                              ' is C:op of ',
                              style: TextStyle(fontSize: toolCardTextSize),
                            ),
                            SizedBox(
                              height: 24, // 限制高度以压缩空间
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _unitValue,
                                  isDense: true,
                                  iconSize: 16,
                                  style: TextStyle(
                                    fontSize: toolCardTextSize,
                                    color: Colors.black,
                                  ),
                                  items: _units.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: toolCardTextSize,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _unitValue = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Text(
                              ',',
                              style: TextStyle(fontSize: toolCardTextSize),
                            ),
                            SizedBox(
                              height: 24,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _modeValue,
                                  isDense: true,
                                  iconSize: 16,
                                  style: TextStyle(
                                    fontSize: toolCardTextSize,
                                    color: Colors.black,
                                  ),
                                  items: _modes.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: toolCardTextSize,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _modeValue = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 结束替换
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(onPressed: () {}, child: Text('取消')),
                            SizedBox(width: 4),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                              child: Text(
                                '确定',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  //fontSize: toolCardTextSize,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
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
