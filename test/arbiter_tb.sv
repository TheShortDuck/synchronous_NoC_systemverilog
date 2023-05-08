// -----------------------------------------------------------------------
// Testbench for the arbiter
// -----------------------------------------------------------------------

module arbiter_tb;
    localparam integer WIDTH = 5;
    logic [WIDTH-1:0] in;
    logic [WIDTH-1:0] out;
    logic clk, rst;

// -------------------------- Arbiter instance ---------------------------
    arbiter arb_inst (
        .req0(in[0]),
        .req1(in[1]),
        .req2(in[2]),
        .req3(in[3]),
        .req4(in[4]),
        .gnt0(out[0]),
        .gnt1(out[1]),
        .gnt2(out[2]),
        .gnt3(out[3]),
        .gnt4(out[4]),
        .clk(clk),
        .rst(rst)
    );

    // Clock generator
    always #5 clk = ~clk;

    // Monitor requests and grants
    initial $monitor("Time:%0d  \tin: %b\tout: %b\t",$time,in,out);

    // Test sequence
    initial begin
        clk = 0;
        rst = 1;
        in = '0;
        #20 rst = 0;
        $display("######## Test started ########");
        $display("Inputs on rising edge of clock");
        @(posedge clk) in = 'b11111;

        @(posedge clk) in = 'b11110;
        @(posedge clk) in = 'b11111;

        @(posedge clk) in = 'b11101;

        @(posedge clk) in = 'b11011;

        @(posedge clk) in = 'b10111;

        @(posedge clk) in = 'b01111;

        @(posedge clk) in = 0;
        $display("Set to 0, and input at various times");

        #1 in = 'b11110;
        #1 in = 'b01110;
        #1 in = 'b01011;
        #1 in = 'b01011;
        #1 in = 'b01001;
        #4 in = 'b01100;
        #2 in = 'b01001;
        #100
        $display("######## Test complete ########");
        $finish;

    end

endmodule
