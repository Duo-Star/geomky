import 'dart:math' as math;
import '../../Trunk/Complex.dart';

/// 傅里叶变换工具类
class FourierTransform {
  // ====================
  // 离散傅里叶变换 (DFT)
  // ====================

  /// 一维DFT变换
  static List<Complex> dft(List<Complex> input) {
    final int N = input.length;
    final List<Complex> output = List<Complex>.filled(N, Complex(0, 0));

    for (int k = 0; k < N; k++) {
      Complex sum = Complex(0, 0);
      for (int n = 0; n < N; n++) {
        // 计算旋转因子：e^(-j*2π*k*n/N)
        final double angle = -2 * math.pi * k * n / N;
        final Complex twiddle = Complex(math.cos(angle), math.sin(angle));
        sum += input[n] * twiddle;
      }
      output[k] = sum;
    }
    return output;
  }

  /// 一维逆DFT变换
  static List<Complex> idft(List<Complex> input) {
    final int N = input.length;
    final List<Complex> output = List<Complex>.filled(N, Complex(0, 0));

    for (int n = 0; n < N; n++) {
      Complex sum = Complex(0, 0);
      for (int k = 0; k < N; k++) {
        // 计算旋转因子：e^(j*2π*k*n/N)
        final double angle = 2 * math.pi * k * n / N;
        final Complex twiddle = Complex(math.cos(angle), math.sin(angle));
        sum += input[k] * twiddle;
      }
      // 逆变换需要除以N
      output[n] = sum / N.toDouble();
    }
    return output;
  }

  // ====================
  // 快速傅里叶变换 (FFT)
  // ====================

  /// 一维FFT变换 (Cooley-Tukey算法)
  static List<Complex> fft(List<Complex> input) {
    final int N = input.length;

    // 基本情况：长度为1的FFT就是自身
    if (N <= 1) return input;

    // 检查输入长度是否为2的幂
    if (!_isPowerOfTwo(N)) {
      // 如果不是2的幂，使用DFT作为fallback
      return dft(input);
    }

    // 分离偶数和奇数索引
    final List<Complex> even = [];
    final List<Complex> odd = [];
    for (int i = 0; i < N; i++) {
      if (i % 2 == 0) {
        even.add(input[i]);
      } else {
        odd.add(input[i]);
      }
    }

    // 递归计算偶数和奇数部分
    final List<Complex> evenTransformed = fft(even);
    final List<Complex> oddTransformed = fft(odd);

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

  /// 一维逆FFT变换
  static List<Complex> ifft(List<Complex> input) {
    // 对输入取共轭
    final conjugated = input.map((c) => c.conjugate()).toList();

    // 应用FFT
    final fftResult = fft(conjugated);

    // 再次取共轭并除以N
    return fftResult.map((c) => c.conjugate() / input.length.toDouble()).toList();
  }

  // ====================
  // 实数输入优化版本
  // ====================

  /// 实数输入FFT (返回复数结果)
  static List<Complex> rfft(List<double> input) {
    // 将实数输入转换为复数
    final complexInput = input.map((x) => Complex(x, 0)).toList();
    return fft(complexInput);
  }

  /// 实数输入FFT (返回幅度谱)
  static List<double> rfftMagnitude(List<double> input) {
    List<Complex> complexResult = rfft(input);
    return complexResult.map((c) => c.magnitude.toDouble()).toList();
  }

  /// 实数输入FFT (返回相位谱)
  static List<double> rfftPhase(List<double> input) {
    final complexResult = rfft(input);
    return complexResult.map((c) => c.argument.toDouble()).toList();
  }

  // ====================
  // 二维变换
  // ====================

  /// 二维FFT变换
  static List<List<Complex>> fft2D(List<List<Complex>> input) {
    final int rows = input.length;
    final int cols = input[0].length;

    // 先对每一行做一维FFT
    final List<List<Complex>> rowTransformed = [];
    for (int i = 0; i < rows; i++) {
      rowTransformed.add(fft(input[i]));
    }

    // 转置矩阵
    final List<List<Complex>> transposed = _transposeMatrix(rowTransformed);

    // 对转置后的每一行（即原矩阵的列）做一维FFT
    final List<List<Complex>> colTransformed = [];
    for (int j = 0; j < cols; j++) {
      colTransformed.add(fft(transposed[j]));
    }

    // 再次转置回原始方向
    return _transposeMatrix(colTransformed);
  }

  /// 二维逆FFT变换
  static List<List<Complex>> ifft2D(List<List<Complex>> input) {
    final int rows = input.length;
    final int cols = input[0].length;

    // 先对每一行做一维逆FFT
    final List<List<Complex>> rowTransformed = [];
    for (int i = 0; i < rows; i++) {
      rowTransformed.add(ifft(input[i]));
    }

    // 转置矩阵
    final List<List<Complex>> transposed = _transposeMatrix(rowTransformed);

    // 对转置后的每一行（即原矩阵的列）做一维逆FFT
    final List<List<Complex>> colTransformed = [];
    for (int j = 0; j < cols; j++) {
      colTransformed.add(ifft(transposed[j]));
    }

    // 再次转置回原始方向
    return _transposeMatrix(colTransformed);
  }

  // ====================
  // 实用工具函数
  // ====================

  /// 检查是否为2的幂
  static bool _isPowerOfTwo(int n) {
    return (n & (n - 1)) == 0 && n != 0;
  }

  /// 矩阵转置
  static List<List<Complex>> _transposeMatrix(List<List<Complex>> matrix) {
    final int rows = matrix.length;
    final int cols = matrix[0].length;

    final List<List<Complex>> result = [];
    for (int j = 0; j < cols; j++) {
      final List<Complex> newRow = [];
      for (int i = 0; i < rows; i++) {
        newRow.add(matrix[i][j]);
      }
      result.add(newRow);
    }
    return result;
  }

  /// 零填充到2的幂
  static List<Complex> padToPowerOfTwo(List<Complex> input) {
    int n = input.length;
    if (_isPowerOfTwo(n)) return input;

    // 计算下一个2的幂
    int nextPower = 1;
    while (nextPower < n) {
      nextPower <<= 1;
    }

    // 创建新列表并填充零
    return List<Complex>.from(input)..addAll(List<Complex>.filled(nextPower - n, Complex(0, 0)));
  }

  /// 计算频率轴
  static List<double> frequencyAxis(int N, double samplingRate) {
    final List<double> freqs = List<double>.filled(N, 0.0);
    final double deltaF = samplingRate / N;

    for (int i = 0; i < N; i++) {
      if (i <= N ~/ 2) {
        freqs[i] = i * deltaF;
      } else {
        freqs[i] = (i - N) * deltaF; // 负频率部分
      }
    }
    return freqs;
  }

  /// 计算功率谱密度
  static List<double> powerSpectralDensity(List<Complex> fftResult) {
    final int N = fftResult.length;
    return List<double>.generate(N, (i) {
      final mag = fftResult[i].magnitude;
      return mag * mag / N;
    });
  }

  /// 计算相位谱
  static List<double> phaseSpectrum(List<Complex> fftResult) {
    return fftResult.map((c) => c.argument.toDouble()).toList();
  }

  /// 计算幅度谱
  static List<double> magnitudeSpectrum(List<Complex> fftResult) {
    return fftResult.map((c) => c.magnitude.toDouble()).toList();
  }

  /// 频域滤波（低通）
  static List<Complex> lowPassFilter(List<Complex> fftResult, double cutoffFreq, double samplingRate) {
    final int N = fftResult.length;
    final double deltaF = samplingRate / N;
    final int cutoffIndex = (cutoffFreq / deltaF).round();

    return List<Complex>.generate(N, (i) {
      if (i <= cutoffIndex || i >= N - cutoffIndex) {
        return fftResult[i];
      } else {
        return Complex(0, 0);
      }
    });
  }

  /// 频域滤波（高通）
  static List<Complex> highPassFilter(List<Complex> fftResult, double cutoffFreq, double samplingRate) {
    final int N = fftResult.length;
    final double deltaF = samplingRate / N;
    final int cutoffIndex = (cutoffFreq / deltaF).round();

    return List<Complex>.generate(N, (i) {
      if (i > cutoffIndex && i < N - cutoffIndex) {
        return fftResult[i];
      } else {
        return Complex(0, 0);
      }
    });
  }
}