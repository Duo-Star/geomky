library;

List<num> decimalToFraction(
  num x, [
  int maxDenominator = 500000,
  double tolerance = 0,
]) {
  // 处理符号并取绝对值
  final sign = x < 0 ? -1 : 1;
  final xAbs = x.abs();

  // 分离整数和小数部分
  final integerPartAbs = xAbs.floor();
  final fractionalAbs = xAbs - integerPartAbs;

  // 连分数算法初始化
  num remainder = fractionalAbs;
  int hPrev2 = 1, hPrev1 = 0;
  int kPrev2 = 0, kPrev1 = 1;
  int bestH = 0, bestK = 1; // 默认分数部分为0/1

  const epsilon = 1e-12;
  bool converged = false;

  // 连分数展开主循环
  while (remainder > epsilon) {
    final reciprocal = 1 / remainder;
    final a = reciprocal.floor();
    remainder = reciprocal - a;

    final currentH = a * hPrev1 + hPrev2;
    final currentK = a * kPrev1 + kPrev2;

    if (currentK > maxDenominator) break;

    hPrev2 = hPrev1;
    hPrev1 = currentH;
    kPrev2 = kPrev1;
    kPrev1 = currentK;
    bestH = currentH;
    bestK = currentK;
    converged = true;
  }

  // 约简分数
  int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  final common = gcd(bestH, bestK);
  bestH ~/= common;
  bestK ~/= common;

  // 计算总分子
  final totalNumerator = sign * (integerPartAbs * bestK + bestH);

  // 检查误差
  final fractionValue = totalNumerator / bestK;
  final error = (fractionValue - x).abs();

  // 返回分数或原始值
  return (tolerance > 0 && error > tolerance)
      ? [x, 1]
      : [totalNumerator, bestK];
}
