library;
import "dart:math" as math;
/*

 */

//
acos(x) => math.acos(x);
asin(x) => math.asin(x);
atan(x) => math.atan(x);
atan2(x,y) => math.atan2(x,y);

//
sin(x) => math.sin(x);
cos(x) => math.cos(x);
tan(x) => math.tan(x);

sgn(x){ //
  if(x>0){ return 1;
  }else if( x==0 ){ return 0;
  }else if( x<0 ){ return -1;
  }
}

abs(x){
  if (x<0){
    return -x;
  }
  return x;
}

sinh( x) { // 双曲正弦函数
  return (math.exp(x) - math.exp(-x)) / 2;
}

cosh( x) { // 双曲余弦函数
  return (math.exp(x) + math.exp(-x)) / 2;
}

tanh( x) { // 双曲正切函数
  return sinh(x) / cosh(x);
}

coth( x) { // 双曲余切函数
  return cosh(x) / sinh(x);
}

sech( x) { // 双曲正割函数
  return 1 / cosh(x);
}

csch( x) { // 双曲余割函数
  return 1 / sinh(x);
}

asinh( x) { // 反双曲正弦函数
  return math.log(x + math.sqrt(x * x + 1));
}

acosh( x) { // 反双曲余弦函数
  if (x < 1) { throw ArgumentError('acosh is only defined for x >= 1'); }
  return math.log(x + math.sqrt(x * x - 1));
}

atanh( x) { // 反双曲正切函数
  if (x <= -1 || x >= 1) { throw ArgumentError('atanh is only defined for -1 < x < 1'); }
  return 0.5 * math.log((1 + x) / (1 - x));
}

//
num floor(num x) => x.floor();

//
num ceil(num x) => x.ceil();

//
num mod(num x, num y) => x- floor(x/y)*y;

//
num pow(num x, num y) => math.pow(x, y);

// 开放正数
num openPNum(num x) => (x>0) ? x : 0;

// 开放负数
num openNNum(num x) => (x<0) ? x : 0;


// 计算阶乘
int factorial(int n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}

// 计算斐波那契数列的第 n 项
int fibonacci(int n) {
  if (n <= 2) return 1;
  return fibonacci(n - 1) + fibonacci(n - 2);
}


// 定积分
/*
自适应辛普森积分法
自动调整步长，在函数变化剧烈处使用更小的步长，精度高，计算量小
 */
num integralRange(Function f, num from, num to, {double eps = 1e-8}) {
  num a = from;
  num b = to;
  num simpson(num a, num b) {
    num c = (a + b) / 2;
    return (f(a) + 4 * f(c) + f(b)) * (b - a) / 6;
  }
  num adaptiveSimpson(num a, num b, num eps, num whole) {
    num c = (a + b) / 2;
    num left = simpson(a, c);
    num right = simpson(c, b);
    num sum = left + right;
    if ((sum - whole).abs() <= 15 * eps || b - a < 1e-10) {
      return sum + (sum - whole) / 15;
    }
    return adaptiveSimpson(a, c, eps/2, left) + adaptiveSimpson(c, b, eps/2, right);
  }
  return adaptiveSimpson(a, b, eps, simpson(a, b));
}


// 计算导数
num derivativeAt(Function f, num x) {
  const num h = 1e-5;
  return (f(x + h) - f(x - h)) / (2 * h);
}

