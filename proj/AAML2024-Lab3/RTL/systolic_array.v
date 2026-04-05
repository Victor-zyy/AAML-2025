`include "PE.v"
// RTL/systolic_array.v
module systolic_array (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         clear,
    // 从 TPU 传入的已对齐的 4 个输入
    input  wire [7:0]   a_in_0, a_in_1, a_in_2, a_in_3,
    input  wire [7:0]   b_in_0, b_in_1, b_in_2, b_in_3,
    // 按行输出，方便 TPU 写入 128-bit 的 SRAM C
    output wire [127:0] c_row_0,
    output wire [127:0] c_row_1,
    output wire [127:0] c_row_2,
    output wire [127:0] c_row_3
);

    wire signed [7:0] wire_h [0:3][0:4];  // 4x5 
    wire signed [7:0] wire_v [0:4][0:3];  // 5x4
    wire signed [31:0] pe_acc [0:3][0:3]; // 4x4 PE 的累加器输出

    // 边界输入绑定
    assign wire_h[0][0] = a_in_0; assign wire_v[0][0] = b_in_0;
    assign wire_h[1][0] = a_in_1; assign wire_v[0][1] = b_in_1;
    assign wire_h[2][0] = a_in_2; assign wire_v[0][2] = b_in_2;
    assign wire_h[3][0] = a_in_3; assign wire_v[0][3] = b_in_3;

    // 输出打包 (大端/小端对齐，注意与测试平台的预期一致)
    // 对应 Testbench 的期望格式，pe_acc[0][0] 放在最高位段
    assign c_row_0 = {pe_acc[0][0], pe_acc[0][1], pe_acc[0][2], pe_acc[0][3]};
    assign c_row_1 = {pe_acc[1][0], pe_acc[1][1], pe_acc[1][2], pe_acc[1][3]};
    assign c_row_2 = {pe_acc[2][0], pe_acc[2][1], pe_acc[2][2], pe_acc[2][3]};
    assign c_row_3 = {pe_acc[3][0], pe_acc[3][1], pe_acc[3][2], pe_acc[3][3]};

    genvar i, j;
    generate
        for (i = 0; i < 4; i = i + 1) begin : row
            for (j = 0; j < 4; j = j + 1) begin : col
                PE pe_inst (
                    .clk(clk), .rst_n(rst_n), .clear(clear),
                    .left(wire_h[i][j]),  .top(wire_v[i][j]),
                    .right(wire_h[i][j+1]), .down(wire_v[i+1][j]),
                    .acc(pe_acc[i][j])
                );
            end
        end
    endgenerate
endmodule
