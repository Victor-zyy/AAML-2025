`include "systolic_array.v"
module TPU(
    clk,
    rst_n,

    in_valid,
    K,
    M,
    N,
    busy,

    A_wr_en,
    A_index,
    A_data_in,
    A_data_out,

    B_wr_en,
    B_index,
    B_data_in,
    B_data_out,

    C_wr_en,
    C_index,
    C_data_in,
    C_data_out
);


input clk;
input rst_n;
input            in_valid;
input [7:0]      K;
input [7:0]      M;
input [7:0]      N;
output  reg      busy;

output reg           A_wr_en;
output reg [15:0]    A_index;
output reg [31:0]    A_data_in;
input  [31:0]    A_data_out;

output reg           B_wr_en;
output reg [15:0]    B_index;
output reg [31:0]    B_data_in;
input  [31:0]    B_data_out;

output reg           C_wr_en;
output reg [15:0]    C_index;
output reg [127:0]   C_data_in;
input  [127:0]   C_data_out;



//* Implement your design here
// ---------------------------------------------------------
// 内部寄存器声明 
// ---------------------------------------------------------
reg [7:0] M_r, K_r, N_r;

// 计算 M 和 N 需要分多少个 4x4 的块 -- Tiling celling calculation
wire [7:0] cnt_M = (M_r + 8'd3) >> 2;
wire [7:0] cnt_N = (N_r + 8'd3) >> 2;

// 循环变量：m(行块), n(列块), k(K维度计数)
reg [7:0] m, n, k; 

// 状态机与缓存
reg [9:0] state;
reg pe_rst;

reg [31:0] AA [0:3];
reg [31:0] BB [0:3];

reg [7:0] a [0:3];
reg [7:0] b [0:3];

wire [127:0] CC [0:3]; 

systolic_array u_array (
    .clk(clk), .rst_n(rst_n), .clear(pe_rst),
    .a_in_0(a[0]), .a_in_1(a[1]), .a_in_2(a[2]), .a_in_3(a[3]),
    .b_in_0(b[0]), .b_in_1(b[1]), .b_in_2(b[2]), .b_in_3(b[3]),
    .c_row_0(CC[0]), .c_row_1(CC[1]), .c_row_2(CC[2]), .c_row_3(CC[3])
);

// ---------------------------------------------------------
// 主控制逻辑
// ---------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        busy <= 0;
        pe_rst <= 0;
        A_wr_en <= 0; B_wr_en <= 0; C_wr_en <= 0;
        A_index <= 0; B_index <= 0; C_index <= 0;
        A_data_in <= 0; B_data_in <= 0; C_data_in <= 0;
        
        M_r <= 0; K_r <= 0; N_r <= 0;
        m <= 0; k <= 0; n <= 0;
        
        AA[0] <= 0; AA[1] <= 0; AA[2] <= 0; AA[3] <= 0;
        BB[0] <= 0; BB[1] <= 0; BB[2] <= 0; BB[3] <= 0;
        a[0] <= 0; a[1] <= 0; a[2] <= 0; a[3] <= 0;
        b[0] <= 0; b[1] <= 0; b[2] <= 0; b[3] <= 0;
        
        state <= 10'b11_00_01_10_11; 
    end else if (in_valid) begin
        busy <= 1;
        pe_rst <= 1;
        
        M_r <= M; 
        K_r <= K; 
        N_r <= N;

        AA[0] <= 0; AA[1] <= 0; AA[2] <= 0; AA[3] <= 0;
        BB[0] <= 0; BB[1] <= 0; BB[2] <= 0; BB[3] <= 0;

        A_index <= 0; B_index <= 0;
        m <= 0; k <= 0; n <= 0;

        state <= {2'b00, 8'b00_01_10_11}; 
    end else if (busy) begin
        case(state[9:8])
            2'b00: begin // === CALC ===
                pe_rst <= 0;
                C_wr_en <= 0;

                AA[state[7:6]] <= k < K_r ? A_data_out : 0;
                BB[state[7:6]] <= k < K_r ? B_data_out : 0;

                a[0] <= k < K_r ? A_data_out[31:24] : 0;
                a[1] <= AA[state[1:0]][23:16];
                a[2] <= AA[state[3:2]][15:8];
                a[3] <= AA[state[5:4]][7:0];

                b[0] <= k < K_r ? B_data_out[31:24] : 0;
                b[1] <= BB[state[1:0]][23:16];
                b[2] <= BB[state[3:2]][15:8];
                b[3] <= BB[state[5:4]][7:0];

                A_index <= m * K_r + k + 1;
                B_index <= n * K_r + k + 1;
                k <= k + 1;

                if (k + 1 < K_r + 8'd4) begin
                    state <= {2'b00, state[5:0], state[7:6]};
                end else begin
                    state <= {2'b01, 8'b00_01_10_11};
                end
            end
            
            2'b01: begin // === WRITE ===
                C_wr_en <= 1;
                
                C_index <= n * M_r + m * 4 + state[7:6];
                C_data_in <= CC[state[7:6]];

                if (m * 4 + state[5:4] >= M_r || state[7:6] == 2'b11) begin
                    pe_rst <= 1;

                    A_index <= n + 1 < cnt_N ? m * K_r : (m + 1) * K_r;
                    B_index <= n + 1 < cnt_N ? (n + 1) * K_r : 0;
                    
                    k <= 0;
                    n <= n + 1 < cnt_N ? n + 1 : 0;
                    m <= n + 1 < cnt_N ? m : m + 1;

                    if (n + 1 == cnt_N && m + 1 == cnt_M) begin
                        state <= {2'b11, 8'd0}; 
                    end else begin
                        state <= {2'b00, 8'b00_01_10_11}; 
                    end
                end else begin
                    state <= {2'b01, state[5:0], state[7:6]};
                end
            end
            
            2'b11: begin // === DONE ===
                C_wr_en <= 0;
                C_index <= 0;
                busy <= 0;
            end
        endcase
    end
end

endmodule