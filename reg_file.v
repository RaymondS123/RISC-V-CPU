module reg_file(
    input wire clk,

    //read port 1
    input wire [4:0] rs1,
    output wire [31:0] rd1,

    //read port 2
    input wire [4:0] rs2,
    output wire [31:0] rd2,

    //write port
    input wire [4:0] rd,
    output wire [31:0] rd,
    input wire we //write enable
);

//32 registers each 32 bit wide
reg [31:0] regs [31:0];

integer i;
always @(*) begin
    for(i = 0; i < 32; i = i + 1) begin
        regs[i] = 32'b0;
    end
end