library;

String myFirstTry ="""
@A is P of 1 1
@x is N of .E
@B is P of <x> .PI
@C is P:v of <2 2>
@D is P^mid of <C> <A>
@n1 is N^mul of <time> .E
@qn1 is QN of 1 2 <n1> <time>
@c1 is C of <1 1> 1
@qp1 is IndexQP of <c1> <qn1>
@p1 is QP^heart of <qp1>
@l1 is QP^deriveL of <qp1>
""";

String tryDeriveLofCir = """
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
@准线 is L of <p5> <p6>
@p is IndexP of <c1> 1.2
""";

String styleTest ="""
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

[lua].|*
this is a lua script
c2 = gmk.getVar('c2')
c2.setColor(0xffffff00)
*|
""";


String regularPentagonal = """
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

 @p14 is C^index
""";



String tanLTest = """
-@p1 is P of 2 1
-@p2 is P of 1 0
-@p3 is P of 0 1
@c2_1 is C0 of <p1> <p2> <p3>
-@l1 is L of <p1> <p2>
-@l2 is L of <p1> <p3>
@dp1 is F of <c2_1>
#dp1 fertileWaveLink
@n1 is N^sin of <time>
@n2 is N^mul of <n1> 5
@p4 is IndexP of <c2_1> <n2>
@l3 is Tan of <c2_1> <p4>
""";


String temple ="""
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
""";



String c1L1C3InsL = """
@c is C of .O 1
#c red
@p is IndexP of <c> 1.5
@p1 is IndexP of <c> 3.8
@p2 is IndexP of <c> 4.2
@p3 is IndexP of <c> 5.2
@pa is P^mid of <p> <p1>
@pb is P^mid of <p> <p2>
@pc is P^mid of <p> <p3>
@c1 is C:op of <pa> <p>
@c2 is C:op of <pb> <p>
@c3 is C:op of <pc> <p>
@px1 is Ins^cc_index of <c1> <c2> 2
@px2 is Ins^cc_index of <c1> <c3> 2
@px3 is Ins^cc_index of <c2> <c3> 2
#px1 forest 2
#px2 forest 2
#px3 forest 2
@l is L of <px1> <px2>
#l amber

""";

String harmonicTest ="""
@slider is L of <0 0> <1 0>
@thumb is IndexP of <slider> 0
@t is Index^getN of <slider> <thumb>
@A is P of 1 1
@B is P of 2 2
@dp1 is DP of <A> <B>
-@l is L of <A> <B>
@dp2 is Harm:dpt of <dp1> <t>
#dp2 red
@c1 is C:diameter of <dp1>
@c2 is C:diameter of <dp2>
#c1 purple
#c2 red
""";





























