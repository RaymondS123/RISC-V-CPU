// ============================================================
//  ALU testbench
//  Run with:  iverilog -o alu_tb alu_tb.v alu.v && vvp alu_tb
// ============================================================

`timescale 1ns/1ps

module alu_tb;

    reg  [31:0] a, b;
    reg  [ 3:0] alu_ctrl;
    wire [31:0] result;
    wire        zero, negative, overflow;

    integer pass = 0;
    integer fail = 0;

    // instantiate DUT
    alu dut (
        .a        (a),
        .b        (b),
        .alu_ctrl (alu_ctrl),
        .result   (result),
        .zero     (zero),
        .negative (negative),
        .overflow (overflow)
    );

    // ---- task: check one result --------------------------------
    task check;
        input [31:0] expected;
        input [63:0] label;   // 8-char ASCII tag
        begin
            #1;
            if (result === expected) begin
                $display("PASS  %-8s  a=%08h b=%08h ctrl=%b => %08h",
                         label, a, b, alu_ctrl, result);
                pass = pass + 1;
            end else begin
                $display("FAIL  %-8s  a=%08h b=%08h ctrl=%b => got %08h expected %08h",
                         label, a, b, alu_ctrl, result, expected);
                fail = fail + 1;
            end
        end
    endtask

    initial begin


        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        // ---- ADD -----------------------------------------------
        alu_ctrl = 4'b0000;
        a = 32'd10;   b = 32'd20;   check(32'd30,           "ADD     ");
        a = 32'hFFFFFFFF; b = 32'd1; check(32'd0,           "ADD_WRAP");

        // ---- SUB -----------------------------------------------
        alu_ctrl = 4'b0001;
        a = 32'd30;   b = 32'd10;   check(32'd20,           "SUB     ");
        a = 32'd0;    b = 32'd1;    check(32'hFFFFFFFF,     "SUB_WRAP");

        // ---- AND -----------------------------------------------
        alu_ctrl = 4'b0010;
        a = 32'hFF00FF00; b = 32'h0F0F0F0F; check(32'h0F000F00, "AND     ");

        // ---- OR ------------------------------------------------
        alu_ctrl = 4'b0011;
        a = 32'hF0F0F0F0; b = 32'h0F0F0F0F; check(32'hFFFFFFFF, "OR      ");

        // ---- XOR -----------------------------------------------
        alu_ctrl = 4'b0100;
        a = 32'hAAAAAAAA; b = 32'h55555555; check(32'hFFFFFFFF, "XOR     ");
        a = 32'hDEADBEEF; b = 32'hDEADBEEF; check(32'h00000000, "XOR_SAME");

        // ---- SLL -----------------------------------------------
        alu_ctrl = 4'b0101;
        a = 32'h00000001; b = 32'd4;  check(32'h00000010,   "SLL     ");
        a = 32'h00000001; b = 32'd31; check(32'h80000000,   "SLL_31  ");

        // ---- SRL -----------------------------------------------
        alu_ctrl = 4'b0110;
        a = 32'h80000000; b = 32'd1;  check(32'h40000000,   "SRL     ");
        a = 32'hFFFFFFFF; b = 32'd4;  check(32'h0FFFFFFF,   "SRL_4   ");

        // ---- SRA -----------------------------------------------
        alu_ctrl = 4'b0111;
        a = 32'h80000000; b = 32'd1;  check(32'hC0000000,   "SRA     ");
        a = 32'hFFFFFFFF; b = 32'd4;  check(32'hFFFFFFFF,   "SRA_NEG ");

        // ---- SLT (signed) --------------------------------------
        alu_ctrl = 4'b1000;
        a = 32'hFFFFFFFF; b = 32'd1;  check(32'd1,          "SLT_NEG ");  // -1 < 1
        a = 32'd1;        b = 32'd1;  check(32'd0,          "SLT_EQ  ");
        a = 32'd2;        b = 32'd1;  check(32'd0,          "SLT_GT  ");

        // ---- SLTU (unsigned) -----------------------------------
        alu_ctrl = 4'b1001;
        a = 32'hFFFFFFFF; b = 32'd1;  check(32'd0,          "SLTU_BIG");  // big > 1
        a = 32'd0;        b = 32'd1;  check(32'd1,          "SLTU_LT ");

        // ---- LUI pass-through ----------------------------------
        alu_ctrl = 4'b1010;
        a = 32'hDEADBEEF; b = 32'h12345000; check(32'h12345000, "LUI     ");

        // ---- zero flag -----------------------------------------
        alu_ctrl = 4'b0001;
        a = 32'd42; b = 32'd42;
        #1;
        if (zero !== 1'b1) begin
            $display("FAIL  ZERO_FLG expected zero=1 got zero=%b", zero);
            fail = fail + 1;
        end else begin
            $display("PASS  ZERO_FLG");
            pass = pass + 1;
        end

        // ---- negative flag -------------------------------------
        alu_ctrl = 4'b0000;
        a = 32'h80000000; b = 32'd0;
        #1;
        if (negative !== 1'b1) begin
            $display("FAIL  NEG_FLG  expected negative=1 got negative=%b", negative);
            fail = fail + 1;
        end else begin
            $display("PASS  NEG_FLG");
            pass = pass + 1;
        end

        // ---- overflow flag -------------------------------------
        alu_ctrl = 4'b0000;   // ADD: max_positive + 1 => overflow
        a = 32'h7FFFFFFF; b = 32'd1;
        #1;
        if (overflow !== 1'b1) begin
            $display("FAIL  OVF_FLG  expected overflow=1 got overflow=%b", overflow);
            fail = fail + 1;
        end else begin
            $display("PASS  OVF_FLG");
            pass = pass + 1;
        end

        // ---- summary -------------------------------------------
        $display("\n========================================");
        $display("  %0d passed   %0d failed", pass, fail);
        $display("========================================");
        $finish;
    end

endmodule