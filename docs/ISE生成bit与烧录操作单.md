# 明天 ISE 生成 `.bit` 与烧录操作单

工程名称：`finger_piano`  
工程位置：`C:\Xilinx\finger_piano\finger_piano.xise`

本操作单只用于：打开已经建立的工程，检查 `.v` 与 `.ucf`，生成 `.bit`，然后下载到 FPGA。

---

## 一、先准备硬件

在打开 iMPACT 前，必须同时具备：

```text
FPGA目标板已上电
下载器/JTAG下载线已连接：电脑USB端 ↔ FPGA板JTAG下载口
```

面包板的模拟±5 V电源与下载器不是一回事。FPGA板没有上电或下载器没有插入电脑时，iMPACT会提示：

```text
Cable autodetection failed
Can not find cable
```

这时不要继续烧录，先检查目标板电源和下载线。

---

## 二、打开已有 ISE 工程

1. 打开 **Xilinx ISE Project Navigator**。
2. 点击：

```text
File → Open Project
```

3. 选择：

```text
C:\Xilinx\finger_piano\finger_piano.xise
```

4. 不要直接双击单独的 `.v` 或 `.ucf` 文件；应从 `.xise` 工程文件打开。

---

## 三、检查源码和引脚文件

左侧 `Hierarchy` 中应有顶层模块：

```text
finger_piano (finger_piano.v)
```

### 1. 检查 Verilog 源码

打开 `finger_piano.v`，第一行模块定义应为：

```verilog
module finger_piano (
```

文件中只能有一个 `module finger_piano (`，末尾只能有一个 `endmodule`。

### 2. 检查 UCF 引脚约束

打开 `finger_piano.ucf`，确认实际接线对应如下：

```ucf
NET "clk_2m"    LOC = "P124" | IOSTANDARD = LVCMOS33;

NET "A"         LOC = "P76"  | IOSTANDARD = LVCMOS33;
NET "B"         LOC = "P77"  | IOSTANDARD = LVCMOS33;
NET "C"         LOC = "P78"  | IOSTANDARD = LVCMOS33;

NET "audio_out" LOC = "P90"  | IOSTANDARD = LVCMOS33 | DRIVE = 8 | SLEW = SLOW;
```

对应关系：

```text
2 MHz晶振 → P124
传感器1（A）→ P76
传感器2（B）→ P77
传感器3（C）→ P78
音频输出 → P90 → 100 nF → LM386功放
```

检查完按 `Ctrl + S` 保存。

---

## 四、生成 `.bit` 文件

1. ISE 左上方工作模式选择：

```text
Implementation
```

不是 `Simulation`。

2. 在 `Hierarchy` 中单击顶层 `finger_piano`。
3. 在左下方 `Processes` 按顺序双击：

```text
Synthesize - XST
Implement Design
Generate Programming File
```

4. 必须等前一步完成后再进行下一步。黄色警告可以先查看，但没有红色错误、步骤出现绿色对勾时才算成功。
5. `Generate Programming File` 出现绿色对勾后，右击该项，选择：

```text
Open Containing Folder
```

6. 文件夹中找到：

```text
finger_piano.bit
```

这就是待下载到 FPGA 的文件。

---

## 五、将下载器连接给虚拟机

1. FPGA板和下载器都已接好、电源已打开后，在 VMware 菜单选择：

```text
虚拟机 → 可移动设备
```

2. 找到下载器名称，可能显示为：

```text
Xilinx USB Cable
FTDI
USB Serial Converter
USB Download Cable
```

3. 选择：

```text
连接（断开与主机的连接）
```

若此菜单只有CD/DVD、网络适配器、声卡，没有上述USB设备，表示下载器还没有插入电脑、未被系统识别，或没有接到FPGA板。此时 iMPACT 无法下载。

---

## 六、iMPACT 下载程序

1. 在 ISE 菜单选择：

```text
Configure Target Device → iMPACT
```

2. 在 iMPACT 左侧选择：

```text
Boundary Scan
```

3. 点击或右击空白处选择：

```text
Initialize Chain
```

4. 成功时中间会出现识别到的 FPGA 芯片图标。
5. 出现选择配置文件窗口时，选择第四部分生成的：

```text
finger_piano.bit
```

6. 若弹出选择 PROM 文件窗口，点击：

```text
Cancel
```

本次直接下载到 FPGA，不烧外部 PROM。

7. 右击 FPGA 芯片图标，选择：

```text
Program
```

8. 等待控制台出现：

```text
Programmed successfully
```

即表示烧录完成。

---

## 七、烧录后立即验证

1. 等待约1秒，程序的内部上电自动复位已经结束。
2. 示波器探头尖端接 **P90**，地夹接 FPGA GND。
3. 三路传感器都不按：输入为 `111`，P90低电平、扬声器静音。
4. 三路传感器都按下：输入为 `000`，P90约493.83 Hz方波；从最小音量开始缓慢调大100 kΩ电位器，应听到B4音。

直接下载到FPGA的程序会在板子断电后丢失。验收期间不掉电即可；若老师没有要求掉电保存，不需要操作PROM。

