import 'dart:math';

// 随机数生成器
class RandomMaster {
  final String type;
  final Map<String, dynamic> factor;

  // 均匀分布 构造函数
  // [from]: 最小值
  // [to]: 最大值
  // [step]: 步长（可选，默认0.1）
  RandomMaster.uniform({
    required double from,
    required double to,
    double step = 0.1,
  }) : type = 'uniform',
       factor = {'from': from, 'to': to, 'step': step} {
    _validateUniformParams(from, to, step);
  }

  // 标准正态分布 构造函数（均值为0，标准差为1）
  RandomMaster.normalUnit() : type = 'normal_unit', factor = {};

  // 正态分布 构造函数 https://zh.wikipedia.org/wiki/%E6%AD%A3%E6%80%81%E5%88%86%E5%B8%83
  // [mean]: 均值
  // [stddev]: 标准差
  RandomMaster.normal({required double mean, required double stddev})
    : type = 'normal',
      factor = {'mean': mean, 'stddev': stddev} {
    _validateNormalParams(stddev);
  }

  // 指数分布 构造函数
  // [lambda]: 速率参数（必须大于0）
  RandomMaster.exponential({required double lambda})
    : type = 'exponential',
      factor = {'lambda': lambda} {
    if (lambda <= 0) {
      throw ArgumentError('速率参数lambda必须大于0');
    }
  }

  // 泊松分布 构造函数 https://zh.wikipedia.org/wiki/%E5%8D%9C%E7%93%A6%E6%9D%BE%E5%88%86%E5%B8%83
  // [lambda]: 平均发生率（必须大于0）
  RandomMaster.poisson({required double lambda})
    : type = 'poisson',
      factor = {'lambda': lambda} {
    if (lambda <= 0) {
      throw ArgumentError('平均发生率lambda必须大于0');
    }
  }

  // 二项分布 构造函数 https://zh.wikipedia.org/wiki/%E4%BA%8C%E9%A0%85%E5%BC%8F%E5%88%86%E5%B8%83
  // [n]: 试验次数（必须为正整数）
  // [p]: 成功概率（必须在0-1之间）
  RandomMaster.binomial({required int n, required double p})
    : type = 'binomial',
      factor = {'n': n, 'p': p} {
    _validateBinomialParams(n, p);
  }

  // 伽马分布 构造函数 https://zh.wikipedia.org/wiki/%E4%BC%BD%E7%8E%9B%E5%88%86%E5%B8%83
  // [shape]: 形状参数（必须大于0）
  // [scale]: 尺度参数（必须大于0）
  RandomMaster.gamma({required double shape, required double scale})
    : type = 'gamma',
      factor = {'shape': shape, 'scale': scale} {
    if (shape <= 0 || scale <= 0) {
      throw ArgumentError('形状参数和尺度参数都必须大于0');
    }
  }

  // 贝塔分布 构造函数 https://zh.wikipedia.org/wiki/%CE%92%E5%88%86%E5%B8%83
  // [alpha]: α参数（必须大于0）
  // [beta]: β参数（必须大于0）
  RandomMaster.beta({required double alpha, required double beta})
    : type = 'beta',
      factor = {'alpha': alpha, 'beta': beta} {
    if (alpha <= 0 || beta <= 0) {
      throw ArgumentError('α参数和β参数都必须大于0');
    }
  }

  // 参数验证方法
  void _validateUniformParams(double from, double to, double step) {
    if (from >= to) {
      throw ArgumentError('均匀分布: 最小值必须小于最大值');
    }
    if (step <= 0) {
      throw ArgumentError('均匀分布: 步长必须大于0');
    }
  }

  void _validateNormalParams(double stddev) {
    if (stddev <= 0) {
      throw ArgumentError('正态分布: 标准差必须大于0');
    }
  }

  void _validateBinomialParams(int n, double p) {
    if (n <= 0) {
      throw ArgumentError('二项分布: 试验次数必须为正整数');
    }
    if (p < 0 || p > 1) {
      throw ArgumentError('二项分布: 成功概率必须在0到1之间');
    }
  }

  // 在指定范围内生成随机数
  // [min]: 最小值
  // [max]: 最大值
  // [step]: 步长（可选，默认0.1）
  // 返回: 在[min, max]范围内的随机数，精度由step决定
  static double randomInRange(double min, double max, [double step = 0.1]) {
    if (min >= max) throw ArgumentError('最小值必须小于最大值');
    if (step <= 0) throw ArgumentError('步长必须大于0');
    final random = Random();
    final range = (max - min) / step;
    return min + (random.nextDouble() * range).floor() * step;
  }

  // 生成0到1之间的随机小数
  // 返回: [0, 1)范围内的随机小数
  static double rand() {
    return Random().nextDouble();
  }

  // 生成随机整数
  // [max]: 最大值（不包含）
  // 返回: [0, max)范围内的随机整数
  static int randomInt(int max) {
    return Random().nextInt(max);
  }

  // 根据分布类型生成随机数
  // 返回: 符合指定分布的随机数
  double compute() {
    switch (type) {
      case 'uniform':
        return _computeUniform();
      case 'normal_unit':
        return _computeNormalUnit();
      case 'normal':
        return _computeNormal();
      case 'exponential':
        return _computeExponential();
      case 'poisson':
        return _computePoisson().toDouble();
      case 'binomial':
        return _computeBinomial().toDouble();
      case 'gamma':
        return _computeGamma();
      case 'beta':
        return _computeBeta();
      default:
        throw UnsupportedError('不支持的分布类型: $type');
    }
  }

  // 均匀分布计算
  double _computeUniform() {
    return RandomMaster.randomInRange(
      factor['from'],
      factor['to'],
      factor['step'],
    );
  }

  // 标准正态分布计算（Box-Muller变换）
  double _computeNormalUnit() {
    final u1 = max(1e-10, rand()); // 避免log(0)
    final u2 = rand();
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }

  // 正态分布计算
  double _computeNormal() {
    final z0 = _computeNormalUnit();
    return z0 * factor['stddev'] + factor['mean'];
  }

  // 指数分布计算（逆变换法）
  double _computeExponential() {
    final u = rand();
    return -log(1 - u) / factor['lambda'];
  }

  // 泊松分布计算（Knuth算法）
  int _computePoisson() {
    final L = exp(-factor['lambda']);
    int k = 0;
    double p = 1.0;
    do {
      k++;
      p *= rand();
    } while (p > L);
    return k - 1;
  }

  // 二项分布计算（重复伯努利试验）
  int _computeBinomial() {
    int successes = 0;
    for (int i = 0; i < factor['n']; i++) {
      if (rand() < factor['p']) {
        successes++;
      }
    }
    return successes;
  }

  // 伽马分布计算（当形状参数为整数时使用Erlang分布）
  double _computeGamma() {
    if (factor['shape'] == factor['shape'].floor()) {
      // 整数形状参数：使用Erlang分布
      double product = 1.0;
      for (int i = 0; i < factor['shape']; i++) {
        product *= rand();
      }
      return -factor['scale'] * log(product);
    } else {
      // 非整数形状参数：使用近似方法
      // 这里使用一个简单的拒绝采样方法，实际应用中可能需要更复杂的算法
      throw UnsupportedError('非整数形状参数的伽马分布暂不支持');
    }
  }

  // 贝塔分布计算（使用伽马分布）
  double _computeBeta() {
    // Beta分布可以通过两个Gamma分布生成
    final gamma1 = RandomMaster.gamma(shape: factor['alpha'], scale: 1.0);
    final gamma2 = RandomMaster.gamma(shape: factor['beta'], scale: 1.0);
    final x = gamma1.compute();
    final y = gamma2.compute();
    return x / (x + y);
  }
}

// /*
void main() {
  try {
    // 均匀分布
    final uniform = RandomMaster.uniform(from: 0.0, to: 10.0, step: 0.1);
    print('均匀分布: ${uniform.compute()}');

    // 正态分布
    final normal = RandomMaster.normal(mean: 5.0, stddev: 2.0);
    print('正态分布: ${normal.compute()}');

    // 二项分布
    final binomial = RandomMaster.binomial(n: 10, p: 0.3);
    print('二项分布: ${binomial.compute()}');

    // 指数分布
    final exponential = RandomMaster.exponential(lambda: 0.5);
    print('指数分布: ${exponential.compute()}');

    // 泊松分布
    final poisson = RandomMaster.poisson(lambda: 3.0);
    print('泊松分布: ${poisson.compute()}');



  } catch (e) {
    print('e: $e');
  }
}
//*/
