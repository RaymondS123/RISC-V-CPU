//ALU encoding
//4'b0000 ADD
//4'b0001 SUB
//4'b0010 AND
//4'b0011 OR
//4'b0100 XOR
//4;b0101 SLL
//4'b0110 SRL
//4'b0111 SRA
//4'b1000 SLT
//4'b1001 SLTU
//4'b1010 LUI

module alu (
    input [31:0] a;
    input [31:0] b;
    input [3:0] alu_ctrl;
    output reg [31:0] result;
    output wire zero;
    output wire negative;
    output wire overflow;
);

//shift amount
wire [4:0] shift_bit = b[4:0];

//combinational logic
always @(*) begin
    case(alu_ctrl)
        4'b0000: result = a + b;
        4'b0001: result = a - b;
        4'b0010: result = a & b;
        4'b0011: result = a | b;
        4'b0100: result = a ^ b;
        4'b0101: result = a << shift_bit;
        4'b0110: result = a >> shift_bit;
        4'b0111: result = $signed(a) >> shift_bit;
        4'b1000: result = {31'b0, ($signed(a) < $signed(b))};
        4'b1001: result = {31'b0, (a < b)};
        4'b1010: result = b;
        default: result = 32'b0;
end

//status flags
assign zero = (result == 32'b0);
assign negative = result[31];

wire add_overflow = (alu_ctrl == 4'b0000) && ((a[31] & b[31] & ~result[31]) | (~a[31] & ~b[31] & result[31]));
wire sub_overflow = (alu_ctrl == 4'b0001) && ((~a[31] & b[31] & result[31]) | (a[31] & ~b[31] & ~result[31]));

assign overflow = add_overflow | sub_overflow;

endmodule


