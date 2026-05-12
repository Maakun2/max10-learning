# FPGA学習ログ：always文と並列動作の理解

## 今日の目的

Verilog HDL の `always` 文を、

- 「ソフトウェアのループ」

ではなく、

- 「実際に存在する回路」

として理解することを目的に学習した。

---

# 1. CPUとFPGAの根本的な違い

## CPU

CPUでは処理は基本的に逐次実行される。

```c
while(1){
    A();
    B();
    C();
}
```

これは、

```text
A → B → C
```

の順番で実行される。

---

## FPGA

FPGAでは、

```verilog
always @(posedge clk)
begin
    A <= ...;
end

always @(posedge clk)
begin
    B <= ...;
end
```

のように記述すると、

```text
A回路
B回路
```

が物理的に同時に存在する。

つまり、

```text
always文 = 新しい回路を作る
```

という考え方になる。

---

# 2. always @(posedge clk) の意味

```verilog
always @(posedge clk)
```

は、

```text
クロック立ち上がり時に動作する同期回路
```

を意味する。

これはソフトウェアのループではなく、

```text
クロックに同期して動作するフリップフロップ回路
```

を生成している。

---

# 3. 2つの周期カウンタを作成

今回は、

- 1秒周期
- 0.5秒周期

の2種類のカウンタを作成した。

```verilog
`define CYCLE_SEC1 48000000
`define CYCLE_SEC2 24000000
```

48MHzクロックを利用し、

```text
48000000クロック = 約1秒
24000000クロック = 約0.5秒
```

となることを学んだ。

---

# 4. begin/end の重要性

Verilogでは、

```verilog
if (条件)
    文1;
    文2;
```

と書くと、

```verilog
if (条件)
    文1;

文2;
```

として解釈される。

つまり、

```text
if文の対象は最初の1文だけ
```

である。

複数文をまとめるには、

```verilog
begin
    ...
end
```

が必要。

---

# 5. 同じ出力に複数assignできない

最初は、

```verilog
assign led = ~counter_led1;
assign led = ~counter_led2;
```

としていた。

しかしこれは、

```text
同じ配線を複数回路が同時に駆動する
```

状態になりエラーとなる。

そのため、

```verilog
assign led[0] = ...
assign led[1] = ...
```

のように別々に指定する必要があることを学んだ。

---

# 6. アクティブLowの理解

MAX10-FB基板のLEDは、

```text
Low(0)で点灯
High(1)で消灯
```

する。

そのため、

```verilog
assign led = ~counter_led;
```

のように反転して使用した。

これは、

| counter_led | LED出力 | LED状態 |
|---|---|---|
| 0 | 1 | 消灯 |
| 1 | 0 | 点灯 |

となるため。

---

# 7. 未接続出力の挙動

`led[2]` を指定しなかった場合、

```text
出力値が不定
```

となり、結果としてLEDが点灯し続けた。

そのため、

```verilog
assign led[2] = 1'b1;
```

のように、

```text
使わない出力も明示的に指定する
```

ことが重要だと学んだ。

---

# 8. alwaysを1つにまとめても並列動作する

最初は、

```verilog
always ...
always ...
```

で分離していた。

その後、

```verilog
always ...
begin
    ...
    ...
end
```

のように1つにまとめた。

しかし、

```text
同じalways内でも各レジスタは独立した回路として動作する
```

ことを学んだ。

つまり本質は、

```text
alwaysの数
```

ではなく、

```text
レジスタと配線構造
```

で回路が決まる。

---

# 9. 今日の最重要理解

FPGAは、

```text
「プログラムを書く」
```

のではなく、

```text
「電子回路を構築する」
```

ものである。

CPUは、

```text
時間を分けて処理
```

する。

FPGAは、

```text
空間上に回路を配置して同時動作
```

する。

この違いが最も重要である。
