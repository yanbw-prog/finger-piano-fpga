`timescale 1ns / 1ps

// 验收三实际烧录顶层。
// A、B、C分别接P76、P77、P78；audio_out接P90。
// 不占用外部rst_n管脚，配置完成后自动复位约10 ms。
module finger_piano (
    input  wire clk_2m,
    input  wire A,
    input  wire B,
    input  wire C,
    output reg  audio_out
);

    reg [11:0] count;
    reg [11:0] div_num;
    reg [15:0] por_count;
    reg        rst_n;

    initial begin
        count     = 12'd0;
        div_num   = 12'd0;
        audio_out = 1'b0;
        por_count = 16'd0;
        rst_n     = 1'b0;
    end

    // FPGA配置后自动保持复位10 ms：2 MHz × 10 ms＝20 000。
    always @(posedge clk_2m) begin
        if (!rst_n) begin
            if (por_count == 16'd19999) begin
                rst_n <= 1'b1;
            end else begin
                por_count <= por_count + 1'b1;
            end
        end
    end

    // A、B、C为低电平有效：三路都不按时为111，静音。
    always @(*) begin
        case ({A, B, C})
            3'b111: div_num = 12'd0;    // 静音
            3'b110: div_num = 12'd3822; // C4，261.62 Hz
            3'b101: div_num = 12'd3405; // D4，293.67 Hz
            3'b100: div_num = 12'd3034; // E4，329.63 Hz
            3'b011: div_num = 12'd2863; // F4，349.23 Hz
            3'b010: div_num = 12'd2551; // G4，391.99 Hz
            3'b001: div_num = 12'd2273; // A4，440.00 Hz
            3'b000: div_num = 12'd2025; // B4，493.88 Hz
            default: div_num = 12'd0;
        endcase
    end

    // 2 MHz时钟分频，得到音频方波。
    always @(posedge clk_2m) begin
        if (!rst_n) begin
            count     <= 12'd0;
            audio_out <= 1'b0;
        end else if (div_num == 12'd0) begin
            count     <= 12'd0;
            audio_out <= 1'b0;
        end else if (count >= div_num - 1'b1) begin
            count     <= 12'd0;
            audio_out <= ~audio_out;
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule

