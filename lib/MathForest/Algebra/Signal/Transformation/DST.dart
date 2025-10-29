import 'dart:math' as math;
import '../../Trunk/Complex.dart';
/// DST类型枚举
enum DSTType {
  DST_I,   // 类型I
  DST_II,  // 类型II（最常用）
  DST_III, // 类型III（DST-II的逆变换）
  DST_IV   // 类型IV
}

/// 离散正弦变换工具类
/// 支持多种DST类型：DST-I, DST-II, DST-III, DST-IV
class DST {
  // ====================
  // DST类型定义
  // ====================

  // ====================
  // 基础DST实现（直接计算）
  // ====================

  /// 一维DST变换
  static List<double> transform1D(List<double> input, {DSTType type = DSTType.DST_II}) {
  final int N = input.length;
  final List<double> output = List<double>.filled(N, 0.0);

  switch (type) {
  case DSTType.DST_I:
  return _dst1TypeI(input);
  case DSTType.DST_II:
  return _dst1TypeII(input);
  case DSTType.DST_III:
  return _dst1TypeIII(input);
  case DSTType.DST_IV:
  return _dst1TypeIV(input);
  }
  }

  /// DST-I 变换
  static List<double> _dst1TypeI(List<double> input) {
  final int N = input.length;
  final List<double> output = List<double>.filled(N, 0.0);
  final double scale = math.sqrt(2.0 / (N + 1));

  for (int k = 0; k < N; k++) {
  double sum = 0.0;
  for (int n = 0; n < N; n++) {
  // DST-I 公式: sin(π*(k+1)*(n+1)/(N+1))
  final angle = math.pi * (k + 1) * (n + 1) / (N + 1);
  sum += input[n] * math.sin(angle);
  }
  output[k] = scale * sum;
  }
  return output;
  }

  /// DST-II 变换（最常用）
  static List<double> _dst1TypeII(List<double> input) {
  final int N = input.length;
  final List<double> output = List<double>.filled(N, 0.0);
  final double scale = math.sqrt(2.0 / N);

  for (int k = 0; k < N; k++) {
  double sum = 0.0;
  for (int n = 0; n < N; n++) {
  // DST-II 公式: sin(π*(k+1)*(2n+1)/(2N))
  final angle = math.pi * (k + 1) * (2 * n + 1) / (2 * N);
  sum += input[n] * math.sin(angle);
  }
  output[k] = scale * sum;
  }
  return output;
  }

  /// DST-III 变换（DST-II的逆变换）
  static List<double> _dst1TypeIII(List<double> input) {
  final int N = input.length;
  final List<double> output = List<double>.filled(N, 0.0);
  final double scale = math.sqrt(2.0 / N);

  for (int n = 0; n < N; n++) {
  double sum = 0.0;
  // 第一个分量特殊处理（k=0）
  for (int k = 0; k < N; k++) {
  // DST-III 公式: sin(π*(2n+1)*(k+1)/(2N))
  final angle = math.pi * (2 * n + 1) * (k + 1) / (2 * N);
  // 最后一个分量有特殊权重
  final weight = (k == N - 1) ? 0.5 : 1.0;
  sum += input[k] * math.sin(angle) * weight;
  }
  output[n] = scale * sum;
  }
  return output;
  }

  /// DST-IV 变换
  static List<double> _dst1TypeIV(List<double> input) {
  final int N = input.length;
  final List<double> output = List<double>.filled(N, 0.0);
  final double scale = math.sqrt(2.0 / N);

  for (int k = 0; k < N; k++) {
  double sum = 0.0;
  for (int n = 0; n < N; n++) {
  // DST-IV 公式: sin(π*(2k+1)*(2n+1)/(4N))
  final angle = math.pi * (2 * k + 1) * (2 * n + 1) / (4 * N);
  sum += input[n] * math.sin(angle);
  }
  output[k] = scale * sum;
  }
  return output;
  }

  // ====================
  // 逆变换实现
  // ====================

  /// 一维逆DST变换
  static List<double> inverseTransform1D(List<double> input, {DSTType type = DSTType.DST_II}) {
  switch (type) {
  case DSTType.DST_I:
  // DST-I是自逆的（除了缩放因子）
  return _dst1TypeI(input);
  case DSTType.DST_II:
  // DST-II的逆是DST-III
  return _dst1TypeIII(input);
  case DSTType.DST_III:
  // DST-III的逆是DST-II
  return _dst1TypeII(input);
  case DSTType.DST_IV:
  // DST-IV是自逆的
  return _dst1TypeIV(input);
  }
  }

  // ====================
  // 二维DST实现
  // ====================

  /// 二维DST变换
  static List<List<double>> transform2D(List<List<double>> input, {DSTType type = DSTType.DST_II}) {
  final int rows = input.length;
  final int cols = input[0].length;

  // 先对每一行做一维DST
  final List<List<double>> rowTransformed = [];
  for (int i = 0; i < rows; i++) {
  rowTransformed.add(transform1D(input[i], type: type));
  }

  // 转置矩阵
  final List<List<double>> transposed = _transposeMatrix(rowTransformed);

  // 对转置后的每一行（即原矩阵的列）做一维DST
  final List<List<double>> colTransformed = [];
  for (int j = 0; j < cols; j++) {
  colTransformed.add(transform1D(transposed[j], type: type));
  }

  // 再次转置回原始方向
  return _transposeMatrix(colTransformed);
  }

  /// 二维逆DST变换
  static List<List<double>> inverseTransform2D(List<List<double>> input, {DSTType type = DSTType.DST_II}) {
  final int rows = input.length;
  final int cols = input[0].length;

  // 先对每一行做一维逆DST
  final List<List<double>> rowTransformed = [];
  for (int i = 0; i < rows; i++) {
  rowTransformed.add(inverseTransform1D(input[i], type: type));
  }

  // 转置矩阵
  final List<List<double>> transposed = _transposeMatrix(rowTransformed);

  // 对转置后的每一行（即原矩阵的列）做一维逆DST
  final List<List<double>> colTransformed = [];
  for (int j = 0; j < cols; j++) {
  colTransformed.add(inverseTransform1D(transposed[j], type: type));
  }

  // 再次转置回原始方向
  return _transposeMatrix(colTransformed);
  }

  // ====================
  // 快速DST实现（基于FFT）
  // ====================

  /// 快速一维DST-II变换（使用FFT加速）
  static List<double> fastTransform1D(List<double> input, {DSTType type = DSTType.DST_II}) {
  final int N = input.length;

  switch (type) {
  case DSTType.DST_II:
  return _fastDST2(input);
  case DSTType.DST_I:
  case DSTType.DST_III:
  case DSTType.DST_IV:
  // 对于其他类型，暂时使用直接计算
  // 可以后续扩展快速算法
  return transform1D(input, type: type);
  }
  }

  /// 快速DST-II实现
  static List<double> _fastDST2(List<double> input) {
  final int N = input.length;
  final int M = 2 * N + 2; // 扩展序列长度

  // 创建扩展序列：x'[n] = [0, x[0], x[1], ..., x[N-1], 0, -x[N-1], ..., -x[0]]
  final List<double> extended = List<double>.filled(M, 0.0);

  // 前半部分
  extended[0] = 0;
  for (int i = 0; i < N; i++) {
  extended[i + 1] = input[i];
  }
  extended[N + 1] = 0;

  // 后半部分（奇对称扩展）
  for (int i = 0; i < N; i++) {
  extended[M - 1 - i] = -input[N - 1 - i];
  }

  // 应用FFT
  final List<Complex> fftResult = _fft(extended.map((e) => Complex(e, 0)).toList());

  // 提取DST结果
  final List<double> output = List<double>.filled(N, 0.0);
  final double scale = math.sqrt(2.0 / N);

  for (int k = 0; k < N; k++) {
  // DST-II系数对应于虚部的特定部分
  // X[k] = -imag(FFT[k+1]) / 2
  output[k] = -fftResult[k + 1].imaginary * scale;
  }

  return output;
  }

  // ====================
  // DST与DCT的转换关系
  // ====================

  /// 通过DCT计算DST（利用转换关系）
  static List<double> dstViaDCT(List<double> input, {DSTType type = DSTType.DST_II}) {
  final int N = input.length;
  final List<double> modifiedInput = List<double>.filled(N, 0.0);

  // 对输入序列进行预处理
  for (int n = 0; n < N; n++) {
  modifiedInput[n] = input[n] * math.sin(math.pi * (n + 0.5) / (2 * N));
  }

  // 计算DCT（这里需要您之前实现的DCT类）
  // 注意：这里假设有DCT类的实现
  // final dctResult = DCT.transform1D(modifiedInput);

  // 由于DCT类未在此提供，这里返回直接DST计算结果作为fallback
  return transform1D(input, type: type);
  }

  // ====================
  // 内部辅助函数
  // ====================

  /// 矩阵转置
  static List<List<double>> _transposeMatrix(List<List<double>> matrix) {
  final int rows = matrix.length;
  final int cols = matrix[0].length;

  final List<List<double>> result = [];
  for (int j = 0; j < cols; j++) {
  final List<double> newRow = [];
  for (int i = 0; i < rows; i++) {
  newRow.add(matrix[i][j]);
  }
  result.add(newRow);
  }
  return result;
  }

  /// 快速傅里叶变换（复用DCT中的实现）
  static List<Complex> _fft(List<Complex> x) {
  final int N = x.length;

  if (N <= 1) return x;

  // 分离偶数和奇数索引
  final List<Complex> even = [];
  final List<Complex> odd = [];
  for (int i = 0; i < N; i++) {
  if (i % 2 == 0) {
  even.add(x[i]);
  } else {
  odd.add(x[i]);
  }
  }

  // 递归计算
  final List<Complex> evenTransformed = _fft(even);
  final List<Complex> oddTransformed = _fft(odd);

  // 合并结果
  final List<Complex> result = List<Complex>.filled(N, Complex(0, 0));
  for (int k = 0; k < N ~/ 2; k++) {
  final double angle = -2 * math.pi * k / N;
  final Complex twiddle = Complex(math.cos(angle), math.sin(angle));

  final Complex t = twiddle * oddTransformed[k];
  result[k] = evenTransformed[k] + t;
  result[k + N ~/ 2] = evenTransformed[k] - t;
  }

  return result;
  }

  // ====================
  // 实用工具函数
  // ====================

  /// 计算变换的能量压缩效率（衡量变换性能）
  static double energyCompressionEfficiency(List<double> input, List<double> transformed,
  {int keepCoefficients = 0}) {
  if (keepCoefficients == 0) {
  keepCoefficients = (transformed.length * 0.1).round(); // 保留10%系数
  }

  // 复制变换系数并排序（按绝对值）
  final sortedCoefficients = List<double>.from(transformed)
  ..sort((a, b) => b.abs().compareTo(a.abs()));

  // 保留前keepCoefficients个系数，其余置零
  final compressed = List<double>.from(transformed);
  for (int i = keepCoefficients; i < compressed.length; i++) {
  compressed[i] = 0.0;
  }

  // 计算原始能量和压缩后能量
  final originalEnergy = input.map((x) => x * x).reduce((a, b) => a + b);
  final compressedEnergy = compressed.map((x) => x * x).reduce((a, b) => a + b);

  return compressedEnergy / originalEnergy;
  }

  /// 打印变换系数统计信息
  static void printTransformStats(List<double> input, List<double> transformed,
  {String label = "DST"}) {
  final inputEnergy = input.map((x) => x * x).reduce((a, b) => a + b);
  final outputEnergy = transformed.map((x) => x * x).reduce((a, b) => a + b);

  print('$label 统计信息:');
  print('  输入能量: ${inputEnergy.toStringAsFixed(6)}');
  print('  输出能量: ${outputEnergy.toStringAsFixed(6)}');
  print('  能量保持: ${(outputEnergy/inputEnergy*100).toStringAsFixed(2)}%');

  // 计算系数分布
  final sorted = List<double>.from(transformed)..sort((a, b) => b.abs().compareTo(a.abs()));
  final top10Energy = sorted.sublist(0, (sorted.length * 0.1).round())
      .map((x) => x * x).reduce((a, b) => a + b);

  print('  前10%系数能量占比: ${(top10Energy/outputEnergy*100).toStringAsFixed(2)}%');
  }
}