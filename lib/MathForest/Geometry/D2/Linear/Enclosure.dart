/*
+++++可视化编程哈哈哈+++++

     !------------p2
     !  Enclosure  !
     !     Box     !
     p1------------!

注意！自觉，我不会为你的错误擦屁股！
意思是：我移除了abs
 */

//import '../../../Algebra/Functions/Main.dart' as funcs;
import 'Vector.dart';



class Enclosure {
  Vector p1;
  Vector p2;

  Enclosure([Vector? p1, Vector? p2]): p1 = p1 ?? Vector(), p2 = p2 ?? Vector(1,1);

  num get area => a*b;

  num get cir => 2*(a+b);

  num get a => (p2.x-p1.x);

  num get b => (p2.y-p1.y);


  (num,num,num,num) get resolve {
    return (p1.x, p1.y, p2.x, p2.y);
  }


}