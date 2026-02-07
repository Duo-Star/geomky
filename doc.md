## 欢迎来到神圣几何的世界
巴拉巴拉


- 你好GMK
```
// 这是示例程序
@A is P of 1 1
@l is L of <A> <2 2>

```



## 全局主题

沉浸式体验几何之美

| 日间       |      | 夜间            |        |
|----------| ---- | ------------- | ------ |
| `banana` | `香蕉` | `volcano`     | `火山`   |
| `forest` | `森林` | `deep-ocean`  | `深海`   |
| `sky`    | `天空` | `universe`    | `宇宙`   |
| `autumn` | `秋日` | `observatory` | `观象台`  |
| `polar`  | `极地` | `pakoo-night` | `果谷之夜` |
| `moon`   | `月球` | `ruins`       | `遗迹`   |

设置全局主题

```
>style moon
```

## 指令API文档

### 数字

| 指令名     | 参数类型      | 解释   | 返回值类型 |
| ------- | --------- | ---- | ----- |
| `N`     | `num`     | 创建数字 | `num` |
| `N^add` | `num num` | 相加   | `num` |
| `N^sub` | `num num` | 相减   | `num` |
| `N^ops` | `num`     | 取反   | `num` |
| `N^mul` | `num num` | 相乘   | `num` |
| `N^div` | `num num` | 相除   | `num` |
| `N^sin` | `num`     | 正弦   | `num` |
| `N^cos` | `num`     | 余弦   | `num` |
| `N^tan` | `num`     | 正切   | `num` |
| `N^abs` | `num`     | 绝对值  | `num` |
| `N^sgn` | `num`     | 符号归一 | `num` |

### 共生数字

| 指令名  | 参数类型              | 解释   | 返回值类型  |
| ---- | ----------------- | ---- | ------ |
| `DN` | `num num`         | 创建駢数 | `DNum` |
| `TN` | `num num num`     | 创建汆数 | `TNum` |
| `QN` | `num num num num` | 创建合数 | `QNum` |

### 点

| 指令名     | 参数类型            | 解释         | 返回值类型    |
| ------- | --------------- | ---------- | -------- |
| `P`     | `num num`       | 点（x y坐标创建） | `Vector` |
| `P:v`   | `Vector`        | 从向量创建点     | `Vector` |
| `P^mid` | `Vector Vector` | 中点         | `Vector` |

### 共生点

| 指令名          | 参数类型                          | 解释        | 返回值类型    |
| ------------ | ----------------------------- | --------- | -------- |
| `DP`         | `Vector Vector`               | 创建骈点      | `DPoint` |
| `TP`         | `Vector Vector Vector`        | 创建汆点      | `TPoint` |
| `QP:4p`      | `Vector Vector Vector Vector` | 创建合点      | `QPoint` |
| `QP`         | `DPoint DPoint`               | 从共轭骈点创建合点 | `QPoint` |
| `DP^l`       | `DPoint`                      | 连接骈点      | `Line`   |
| `DP^mid`     | `DPoint`                      | 骈点中点      | `Vector` |
| `DP^index`   | `DPoint num`                  | 駢点的索引     | `Vector` |
| `QP^deriveL` | `QPoint`                      | 计算合点的衍线   | `Line`   |
| `QP^heart`   | `QPoint`                      | 计算合点的心点   | `Vector` |
| `QP^xl1`     | `QPoint`                      | 合点连接-1    | `XLine`  |
| `QP^xl2`     | `QPoint`                      | 合点连接-2    | `XLine`  |


### 调和性

| 指令名          | 参数类型                          | 解释        | 返回值类型    |
| ------------ | ----------------------------- | --------- | -------- |
| `Harm:dpt`   | `DPoint num`                  | 计算调和点     | `DPoint` |


### 线性

| 指令名    | 参数类型            | 解释       | 返回值类型     |
| ------ | --------------- | -------- | --------- |
| `L:pv` | `Vector Vector` | 直线（点向创建） | `Line`    |
| `L`    | `Vector Vector` | 直线（两点创建） | `Line`    |
| `Poly` | `Vector...`     | 多边形      | `Polygon` |


### 交点计算

| 指令名            | 参数类型                | 解释            | 返回值类型    |
| -------------- | ------------------- | ------------- | -------- |
| `Ins^ll`       | `Line Line`         | 直线和直线交点       | `Vector` |
| `Ins^lc`       | `Line Circle`       | 直线和圆的交点       | `DPoint` |
| `Ins^cl`       | `Circle Line`       | 圆和直线的交点       | `DPoint` |
| `Ins^cc`       | `Circle Circle`     | 两个圆的交点        | `DPoint` |
| `Ins^cl_index` | `Circle Line num`   | 圆和直线的交点（索引消骈） | `Vector` |
| `Ins^c0l`      | `Conic0 Line`       | 椭圆和直线的交点      | `DPoint` |
| `Ins^lc0`      | `Line Conic0`       | 直线和椭圆的交点      | `DPoint` |
| `Ins^lc2`      | `Line Conic2`       | 直线和双曲线的交点     | `DPoint` |
| `Ins^c2l`      | `Conic2 Line`       | 直线和双曲线的交点     | `DPoint` |
| `Ins^lxl`      | `Line XLine`        | 直线和交叉直线的交点    | `DPoint` |
| `Ins^xll`      | `XLine Line`        | 直线和交叉直线的交点    | `DPoint` |
| `Ins^cc_index` | `Circle Circle num` | 两个圆的交点（索引消骈）  | `Vector` |

### 切线计算

|指令名|参数类型|解释|返回值类型|
|---|---|---|---|
|`Tan^dp`|`dynamic DPoint`|椭圆上骈点的切线（得到交叉直线）|`XLine`|
|`Tan`|`dynamic Vector`|切线|`Line`|

### 圆类型

|指令名|参数类型|解释|返回值类型|
|---|---|---|---|
|`C`|`Vector num`|圆（圆心和半径）|`Circle`|
|`C:op`|`Vector Vector`|圆（圆心和圆上一点）|`Circle`|
|`C:diameter`|`DPoint`|圆（直径创建）|`Circle`|

### 索引

| 指令名          | 参数类型             | 解释                  | 返回值类型    |
| ------------ | ---------------- | ------------------- | -------- |
| `IndexP`     | `dynamic num`    | 对象上取点（直线，二次对象，共生对象） | `Vector` |
| `IndexDP`    | `dynamic DNum`   | 由駢数索引到骈点            | `DPoint` |
| `IndexQP`    | `dynamic QNum`   | 由合数索引到合点            | `QPoint` |
| `Index^getN` | `dynamic Vector` | 获取索引数值              | `num`    |

### 二次曲线的创建

| 指令名  | 参数类型                   | 解释           | 返回值类型    |
| ---- | ---------------------- | ------------ | -------- |
| `C0` | `Vector Vector Vector` | 椭圆（中心和共轭直径）  | `Conic0` |
| `C1` | `Vector Vector Vector` | 抛物线          | `Conic1` |
| `C2` | `Vector Vector Vector` | 双曲线（中心和渐进方向） | `Conic2` |

### 二次曲线的性质


| 指令名          | 参数类型                          | 解释        | 返回值类型    |
| ------------ | ----------------------------- | --------- | -------- |
| `Asym`       | `dynamic`                     | 二次曲线的渐近线  | `XLine`  |
| `F`          | `dynamic`                     | 二次曲线的焦点   | `DPoint` |
| `XL^p`       | `XLine`                       | 叉线中心      | `Vector` |

