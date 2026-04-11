// RTL/PE.v
module PE (
    input  wire               clk,
    input  wire               rst_n,
    input  wire               clear,   // clear the accumulator and right/down registers 
    input  wire [7:0]  left,    
    input  wire [7:0]  top,     
    output reg  [7:0]  right,
    output reg  [7:0]  down,
    output reg  [31:0] acc
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || clear) begin
            right <= 8'd0;
            down  <= 8'd0;
            acc   <= 32'd0;
        end else begin
            // Data flow: from left to right, from top to down
            right <= left;
            down  <= top;
            // unsigned multiplication and accumulation
            acc <= $signed(acc) + $signed(left)*$signed(top);
        end
    end
endmodule