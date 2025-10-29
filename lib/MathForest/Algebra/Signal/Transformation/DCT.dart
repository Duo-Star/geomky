import 'dart:math' as math;
import '../../Trunk/Complex.dart';

/// 离散余弦变换工具类
class DCT {
  // ====================
  // 基础DCT实现（直接计算）
  // ====================

  /// 一维DCT变换 (DCT-II)
  static List<double> transform1D(List<double> input) {
    final int N = input.length;
    final List<double> output = List<double>.filled(N, 0.0);
    final double c0 = math.sqrt(1.0 / N);
    final double ck = math.sqrt(2.0 / N);

    for (int k = 0; k < N; k++) {
      double sum = 0.0;
      for (int n = 0; n < N; n++) {
        // 计算DCT核心公式: cos(π*k*(2n+1)/(2N))
        final angle = (math.pi * k * (2 * n + 1)) / (2 * N);
        sum += input[n] * math.cos(angle);
      }
      // 应用归一化系数
      output[k] = (k == 0) ? c0 * sum : ck * sum;
    }
    return output;
  }

  /// 一维逆DCT变换 (IDCT)
  static List<double> inverseTransform1D(List<double> input) {
    final int N = input.length;
    final List<double> output = List<double>.filled(N, 0.0);
    final double c0 = math.sqrt(1.0 / N);
    final double ck = math.sqrt(2.0 / N);

    for (int n = 0; n < N; n++) {
      double sum = c0 * input[0]; // DC分量单独处理
      for (int k = 1; k < N; k++) {
        // 计算IDCT核心公式: cos(π*k*(2n+1)/(2N))
        final angle = (math.pi * k * (2 * n + 1)) / (2 * N);
        sum += ck * input[k] * math.cos(angle);
      }
      output[n] = sum;
    }
    return output;
  }

  /// 二维DCT变换
  static List<List<double>> transform2D(List<List<double>> input) {
    final int rows = input.length;
    final int cols = input[0].length;

    // 先对每一行做一维DCT
    final List<List<double>> rowTransformed = [];
    for (int i = 0; i < rows; i++) {
      rowTransformed.add(transform1D(input[i]));
    }

    // 转置矩阵（行列转换）
    final List<List<double>> transposed = _transposeMatrix(rowTransformed);

    // 对转置后的每一行（即原矩阵的列）做一维DCT
    final List<List<double>> colTransformed = [];
    for (int j = 0; j < cols; j++) {
      colTransformed.add(transform1D(transposed[j]));
    }

    // 再次转置回原始方向
    return _transposeMatrix(colTransformed);
  }

  /// 二维逆DCT变换
  static List<List<double>> inverseTransform2D(List<List<double>> input) {
    final int rows = input.length;
    final int cols = input[0].length;

    // 先对每一行做一维IDCT
    final List<List<double>> rowTransformed = [];
    for (int i = 0; i < rows; i++) {
      rowTransformed.add(inverseTransform1D(input[i]));
    }

    // 转置矩阵
    final List<List<double>> transposed = _transposeMatrix(rowTransformed);

    // 对转置后的每一行（即原矩阵的列）做一维IDCT
    final List<List<double>> colTransformed = [];
    for (int j = 0; j < cols; j++) {
      colTransformed.add(inverseTransform1D(transposed[j]));
    }

    // 再次转置回原始方向
    return _transposeMatrix(colTransformed);
  }

  // ====================
  // 快速DCT实现（FFT加速）
  // ====================

  /// 快速一维DCT变换（使用FFT加速）
  static List<double> fastTransform1D(List<double> input) {
    final int N = input.length;
    final int M = N * 2; // 扩展序列长度

    // 创建对称扩展序列：y[n] = x[n], y[2N-1-n] = x[n]
    final List<double> extended = List<double>.filled(M, 0.0);
    for (int i = 0; i < N; i++) {
      extended[i] = input[i];
      extended[M - 1 - i] = input[i];
    }

    // 应用FFT
    final List<Complex> fftResult = _fft(extended.map((e) => Complex(e, 0)).toList());

    // 提取DCT结果
    final List<double> output = List<double>.filled(N, 0.0);
    final double scale = math.sqrt(2.0 / N);

    for (int k = 0; k < N; k++) {
      // 相位旋转因子：e^(-j*π*k/(2N))
      final phase = -math.pi * k / (2 * N);
      final rotation = Complex(math.cos(phase), math.sin(phase));

      // 应用旋转并取实部
      final Complex rotated = fftResult[k] * rotation;
      output[k] = rotated.real * scale;
    }

    // 调整DC分量（k=0）
    output[0] /= math.sqrt(2);

    return output;
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

  /// 快速傅里叶变换（FFT）
  static List<Complex> _fft(List<Complex> x) {
    final int N = x.length;

    // 基本情况：长度为1的FFT就是自身
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

    // 递归计算偶数和奇数部分
    final List<Complex> evenTransformed = _fft(even);
    final List<Complex> oddTransformed = _fft(odd);

    // 合并结果
    final List<Complex> result = List<Complex>.filled(N, Complex(0, 0));
    for (int k = 0; k < N ~/ 2; k++) {
      // 计算旋转因子：e^(-j*2π*k/N)
      final double angle = -2 * math.pi * k / N;
      final Complex twiddle = Complex(math.cos(angle), math.sin(angle));

      // 蝶形运算
      final Complex t = twiddle * oddTransformed[k];
      result[k] = evenTransformed[k] + t;
      result[k + N ~/ 2] = evenTransformed[k] - t;
    }

    return result;
  }

  // ====================
  // 性能优化函数
  // ====================

  /// 预计算余弦表（提高大尺寸DCT性能）
  static List<List<double>> precomputeCosineTable(int N) {
    final table = List<List<double>>.generate(N, (k) {
      return List<double>.generate(N, (n) {
        return math.cos(math.pi * k * (2 * n + 1) / (2 * N));
      });
    });
    return table;
  }

  /// 使用预计算表的优化DCT
  static List<double> optimizedTransform1D(List<double> input, List<List<double>> cosineTable) {
    final int N = input.length;
    final List<double> output = List<double>.filled(N, 0.0);
    final double c0 = math.sqrt(1.0 / N);
    final double ck = math.sqrt(2.0 / N);

    for (int k = 0; k < N; k++) {
      double sum = 0.0;
      for (int n = 0; n < N; n++) {
        // 使用预计算的余弦值
        sum += input[n] * cosineTable[k][n];
      }
      output[k] = (k == 0) ? c0 * sum : ck * sum;
    }
    return output;
  }
}

/*
void main() {
  // 一维DCT示例
  final input1D = [1.0, 2.0, 3.0, 4.0];
  print('原始数据: $input1D');

  // 标准DCT
  final dct1D = DCT.transform1D(input1D);
  print('标准DCT: $dct1D');

  // 快速DCT
  final fastDct1D = DCT.fastTransform1D(input1D);
  print('快速DCT: $fastDct1D');

  // 二维DCT示例
  final input2D = [
    [1.0, 2.0],
    [3.0, 4.0],
  ];
  print('\n原始二维数据:');
  input2D.forEach(print);

  final dct2D = DCT.transform2D(input2D);
  print('\n二维DCT结果:');
  dct2D.forEach(print);

  // 使用预计算表优化
  final cosineTable = DCT._precomputeCosineTable(8);
  final largeInput = List<double>.generate(8, (i) => i.toDouble());
  final optimizedDct = DCT.optimizedTransform1D(largeInput, cosineTable);
  print('\n优化DCT结果: $optimizedDct');
}
 */