// Simple testbench for the arbiter
module arbiter_tb; // verilog_lint: waive module-filename
    localparam integer WIDTH = 5;
    logic clk, rst;
    logic [WIDTH-1:0] in;
    logic [WIDTH-1:0] out;

    arbiter arb_inst (
    .clk(clk),
    .rst(rst),
    .req0(in[0]),
    .req1(in[1]),
    .req2(in[2]),
    .req3(in[3]),
    .req4(in[4]),
    .gnt0(out[0]), // Maybe this is fine (indicates origin of route)
    .gnt1(out[1]),
    .gnt2(out[2]),
    .gnt3(out[3]),
    .gnt4(out[4])
    );

    always #5 clk = ~clk;

    initial $monitor("in: %b\tout: %b\t",in,out);

    initial begin
        clk = 0;
        rst = 1;
        in = '0;
        #5 rst = 0;
        $display("NEXT BATCH");
        @(negedge clk) in = 'b11111;
        @(negedge clk) in = 'b11111;
        @(negedge clk) in = 'b11111;
        @(negedge clk) in = 'b11111;
        @(negedge clk) in = 'b11111;
        $display("NEXT BATCH");
        @(negedge clk) in = 'b11110;
        @(negedge clk) in = 'b11110;
        @(negedge clk) in = 'b11110;
        @(negedge clk) in = 'b11110;
        @(negedge clk) in = 'b11110;
        $display("NEXT BATCH");
        @(negedge clk) in = 'b11101;
        @(negedge clk) in = 'b11101;
        @(negedge clk) in = 'b11101;
        @(negedge clk) in = 'b11101;
        @(negedge clk) in = 'b11101;
        $display("NEXT BATCH");
        @(negedge clk) in = 'b11011;
        @(negedge clk) in = 'b11011;
        @(negedge clk) in = 'b11011;
        @(negedge clk) in = 'b11011;
        @(negedge clk) in = 'b11011;
        $display("NEXT BATCH");
        @(negedge clk) in = 'b10111;
        @(negedge clk) in = 'b10111;
        @(negedge clk) in = 'b10111;
        @(negedge clk) in = 'b10111;
        @(negedge clk) in = 'b10111;
        $display("NEXT BATCH");
        @(negedge clk) in = 'b01111;
        @(negedge clk) in = 'b01111;
        @(negedge clk) in = 'b01111;
        @(negedge clk) in = 'b01111;
        @(negedge clk) in = 'b01111;

        #100 $finish;

    end



endmodule



/*
// Simple testbench for the LSB priority arbiter
module arbiter_tb;
    localparam integer WIDTH = 4;
    logic [WIDTH-1:0] in;
    logic [WIDTH-1:0] out;

    arbiter #(
        .WIDTH(WIDTH)
    ) arb_inst (
        .in(in),
        .out(out)
    );

    initial begin
        $display("########## Starting test ##########");
        in = 4'd0;
        $monitor("in: %b\tout: %b",in,out);
        #10
        in = 4'd1;
        $monitor("in: %b\tout: %b",in,out);
        #10
        in = 4'd2;
        $monitor("in: %b\tout: %b",in,out);
        #10
        in = 4'd3;
        $monitor("in: %b\tout: %b",in,out);
        #10
        in = 4'd4;
        $monitor("in: %b\tout: %b",in,out);
        #10
        in = 4'd5;
        $monitor("in: %b\tout: %b",in,out);
    end

endmodule
*/
