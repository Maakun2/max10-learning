# FPGA LED点滅（Lチカ）学習メモ

## 学習内容
本日は，MAX10 FPGA上で動作するVerilog HDLのLED点滅回路（Lチカ）を題材に，FPGA設計の基本概念を学習した．

---

# 1. FPGAはクロックで動作する

今回使用したクロック：

```verilog
input wire clk // 48MHz Clock
```

48MHzとは：

```text
48MHz = 48,000,000Hz
```

つまり：

```text
1秒間に4800万回動作する
```

という意味。

---

# 2. FPGAにおける時間の考え方

FPGAは「1秒」という概念を持たない。

代わりに：

```text
クロックを何回数えたか
```

で時間を表現する。

今回：

```verilog
`define CYCLE_1SEC 48000000
```

とすることで，

```text
48000000回クロックが来たら1秒
```

として扱っている。

---

# 3. カウンタによる分周

## 1秒生成回路

```verilog
reg [31:0] counter_1sec;
```

クロックごとに：

```verilog
counter_1sec <= counter_1sec + 1;
```

を行い，

```verilog
assign period_1sec =
    (counter_1sec == (`CYCLE_1SEC - 1));
```

で1秒経過を判定している。

---

# 4. `CYCLE_1SEC` を変更した結果

## 元の設定

```verilog
`define CYCLE_1SEC 48000000
```

結果：

```text
約1秒ごとにLED変化
```

---

## 24000000 に変更

```verilog
`define CYCLE_1SEC 24000000
```

結果：

```text
約0.5秒ごとにLED変化
```

理由：

```text
24000000 / 48000000 = 0.5秒
```

となるため。

---

## 480000 に変更

```verilog
`define CYCLE_1SEC 480000
```

結果：

```text
非常に高速に点滅
```

理由：

```text
480000 / 48000000 = 0.01秒
```

つまり：

```text
0.01秒ごとにLED状態が切り替わる
```

ため。

---

# 5. wireとregの違い

## wire

```verilog
wire period_1sec;
```

wireは：

```text
配線
```

を意味する。

状態を保持せず，
「今この瞬間の値」を表す。

---

## reg

```verilog
reg [31:0] counter_1sec;
```

regは：

```text
値を記憶する
```

ために使用する。

カウンタは前回値を保持する必要があるためregになる。

---

# 6. always文の意味

```verilog
always @(posedge clk, negedge res_n)
```

は：

```text
clk立ち上がり
または
res_n立ち下がり
```

で実行される。

「かつ」ではなく「または」。

---

# 7. 非同期リセット

```verilog
if (~res_n)
```

はリセット信号。

```text
res_n = 0
```

でリセットが有効になる。

これは：

```text
Low Active
```

と呼ばれる。

---

# 8. LED制御

## LED用カウンタ

```verilog
reg [2:0] counter_led;
```

3bitなので：

```text
2^3 = 8
```

8通りの状態を持つ。

```text
000
001
010
011
100
101
110
111
```

を順番に繰り返す。

---

# 9. Low Active LED

```verilog
assign led = ~counter_led;
```

今回の基板のLEDは：

| 信号 | LED |
|---|---|
| 0 | 点灯 |
| 1 | 消灯 |

となっている。

そのため反転して出力している。

---

# 10. RGB LEDのbit対応

実機確認より：

```text
001 → 赤点灯
```

だったため，

```text
led[0] が赤
```

に対応していると推測できる。

---

# 11. bit幅の考え方

今回：

```verilog
reg [31:0] counter_1sec;
```

となっていた。

実際に必要なのは：

```text
48000000まで数えるbit数
```

であり，

```text
2^26 = 67,108,864
```

なので26bitあれば足りる。

32bitは余裕を持たせた設計。

---

# 12. FPGAにおける「時間」の本質

FPGAの時間は：

```text
クロック振動の回数
```

である。

さらに，
そのクロック自体も完全な理想時間ではなく，

- 温度
- 水晶精度
- 電圧変動

などでわずかにズレる。

つまり：

```text
コンピュータの時間 = 物理振動を数えたもの
```

であることを理解した。

---

# 本日の理解キーワード

- FPGA
- Verilog HDL
- wire
- reg
- always
- posedge
- nonblocking assignment (`<=`)
- counter
- clock
- reset
- Low Active
- RGB LED
- bit幅
- 分周
- クロック周期
- FPGA時間概念
