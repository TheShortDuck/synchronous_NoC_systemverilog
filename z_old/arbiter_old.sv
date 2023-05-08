// Arbiter switching priority (slow because clock)
module arbiter ( // verilog_lint: waive module-filename
    input logic clk,
    input logic rst,
    input logic req0,
    input logic req1,
    input logic req2,
    input logic req3,
    input logic req4,
    output logic gnt0,
    output logic gnt1,
    output logic gnt2,
    output logic gnt3,
    output logic gnt4
);
    //State names
    typedef enum {S_idle, S_0, S_1, S_2, S_3, S_4} state_coding_t;
    //State reg
    logic [2:0] state, state_next;

    logic [4:0] arb_in, arb_out;

    assign arb_in = {req4,req3,req2,req1,req0};
    assign gnt0 = arb_out[0];
    assign gnt1 = arb_out[1];
    assign gnt2 = arb_out[2];
    assign gnt3 = arb_out[3];
    assign gnt4 = arb_out[4];

    // State
    always_comb begin
        case (state)
            S_idle : begin
                if(arb_in[0]) state_next = S_0;
                else if(arb_in[1]) state_next = S_1;
                else if(arb_in[2]) state_next = S_2;
                else if(arb_in[3]) state_next = S_3;
                else if(arb_in[4]) state_next = S_4;
                else state_next = S_idle;
            end

            S_0 : begin
                if(arb_in[1]) state_next = S_1;
                else if(arb_in[2]) state_next = S_2;
                else if(arb_in[3]) state_next = S_3;
                else if(arb_in[4]) state_next = S_4;
                else if(arb_in[0]) state_next = S_0; // 0 low priority
                else state_next = S_idle;
            end

            S_1 : begin
                if(arb_in[2]) state_next = S_2;
                else if(arb_in[3]) state_next = S_3;
                else if(arb_in[4]) state_next = S_4;
                else if(arb_in[0]) state_next = S_0;
                else if(arb_in[1]) state_next = S_1; // 1 low priority
                else state_next = S_idle;
            end

            S_2 : begin
                if(arb_in[3]) state_next = S_3;
                else if(arb_in[4]) state_next = S_4;
                else if(arb_in[0]) state_next = S_0;
                else if(arb_in[1]) state_next = S_1;
                else if(arb_in[2]) state_next = S_2; // 2 low priority
                else state_next = S_idle;
            end

            S_3 : begin
                if(arb_in[4]) state_next = S_4;
                else if(arb_in[0]) state_next = S_0;
                else if(arb_in[1]) state_next = S_1;
                else if(arb_in[2]) state_next = S_2;
                else if(arb_in[3]) state_next = S_3; // 3 low priority
                else state_next = S_idle;
            end

            S_4 : begin
                if(arb_in[0]) state_next = S_0;
                else if(arb_in[1]) state_next = S_1;
                else if(arb_in[2]) state_next = S_2;
                else if(arb_in[3]) state_next = S_3;
                else if(arb_in[4]) state_next = S_4; // 4 low priority
                else state_next = S_idle;
            end

            default: begin
                if(arb_in[0]) state_next = S_0;
                else if(arb_in[1]) state_next = S_1;
                else if(arb_in[2]) state_next = S_2;
                else if(arb_in[3]) state_next = S_3;
                else if(arb_in[4]) state_next = S_4;
                else state_next = S_idle;
            end
        endcase
    end

    // Output
    always_comb begin
        case (state)
            S_0 : arb_out = 5'b00001;
            S_1 : arb_out = 5'b00010;
            S_2 : arb_out = 5'b00100;
            S_3 : arb_out = 5'b01000;
            S_4 : arb_out = 5'b10000;
            default: arb_out = '0;
        endcase
    end

    // Seq
    always_ff @(posedge clk or posedge rst) begin
        if(rst) state <= S_idle;
        else state <= state_next;
    end


endmodule


// Arbiter (Parameterized width) LSB priority
/*
module arbiter #(
    parameter integer WIDTH = 4
) (
    input logic [WIDTH - 1:0] in,
    output logic [WIDTH - 1:0] out
);
    logic [WIDTH - 1:0] check;

    always_comb begin
        check = {~ in[WIDTH - 2:0] & check[WIDTH - 2:0], 1'b1};
        out = in & check;
    end
endmodule
*/



/*
// Arbiter (Parameterized width) (should be fair when done)
// chapter 18, interconnection book
module arbiter (
    input logic req0,
    input logic req1,
    input logic req2,
    input logic req3,
    input logic req4,
    output logic gnt0,
    output logic gnt1,
    output logic gnt2,
    output logic gnt3,
    output logic gnt4,
    input logic clk,
    input logic rst
);
    localparam integer WIDTH = 5;
    logic [WIDTH - 1:0] req, gnt;
    logic [WIDTH - 1:0] last, prio;
    logic [WIDTH - 1:0] carry;
    wire [WIDTH - 1:0] tmp_gnt, hold;
    wire [WIDTH - 1:0] next_prio;
    wire any_hold;

    assign req = {req4,req3,req2,req1,req0};
    assign gnt0 = gnt[0];
    assign gnt1 = gnt[1];
    assign gnt2 = gnt[2];
    assign gnt3 = gnt[3];
    assign gnt4 = gnt[4];

    // Logic for simple iterative variable priority arbiter

    always_comb begin // This should work, (but still carry feed back to carry) mby still prob
        for(int i = 0; i<WIDTH; i++) begin
            carry[i+1] = (~req[i] & (carry[i] | prio[i]));
        end
        carry[0] = carry[WIDTH-1];
    end
    assign tmp_gnt = req & (carry | prio);

    // Do as footnote 2
    /*always_comb begin // This should work, (but still carry feed back to carry) mby still prob
        for(int i = 0; i<WIDTH; i++) begin
            carry[i+1] = (~req[i] & (carry[i] | prio[i]));
        end
        carry[0] = 0;
        for(int i = 0; i<WIDTH; i++) begin
            carry[i+WIDTH] = (~req[i] & (carry[i+WIDTH-1] | prio[i]));
        end
    end
    assign tmp_gnt = (req & (carry[WIDTH*2-1:WIDTH] | prio)) | (req & (carry[WIDTH-1:0] | prio));
*//*
    // Hold logic
    assign hold = req & last;
    assign any_hold = |hold;
    assign gnt = any_hold ? hold : tmp_gnt;

    // Round-Robin Next priority
    assign next_prio = |gnt ? {gnt[WIDTH-2:0], gnt[WIDTH-1]} : prio;

    // Sequential
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            last <= 0;
            prio <= 1; // Reset priority to ..01
        end else begin
            last <= gnt; // Register for last
            prio <= next_prio; // Register for priority
        end
    end

endmodule

*/
