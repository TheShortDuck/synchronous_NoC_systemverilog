import global_params::*;

// Simple testbench for the arbiter
module router_one_p_tb;
    localparam integer WIDTH = 4;
    logic clk, rst, valid;
    router_if intf_in[NORTH:LOCAL]();
    router_if intf_out[NORTH:LOCAL]();
    /*router_if north_out();
    router_if east_out();
    router_if south_out();
    router_if west_out();
    router_if local_out();*/
    logic route_out_N;
    logic route_out_E;
    logic route_out_S;
    logic route_out_W;
    logic route_out_L;

    logic [DATA_WIDTH-1:0] north_data, east_data, south_data, west_data, local_data;
    logic [$clog2(MESH_SIDE)-1:0] north_dest_x, east_dest_x, south_dest_x, west_dest_x, local_dest_x; // verilog_lint: w
    logic [$clog2(MESH_SIDE)-1:0] north_dest_y, east_dest_y, south_dest_y, west_dest_y, local_dest_y; // verilog_lint: w
    logic north_sdx, east_sdx, south_sdx, west_sdx, local_sdx;
    logic north_sdy, east_sdy, south_sdy, west_sdy, local_sdy;
    logic north_valid, east_valid, south_valid, west_valid, local_valid;

    logic start_ns_prio;

    router_one_p #( // Router for 2d mesh (x and y)
        .X_COORD(1),
        .Y_COORD(1)
    ) router_inst (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .north_in(intf_in),
        .intf_out(intf_out),
        /*.north_out(north_out),
        .east_out(east_out),
        .south_out(south_out),
        .west_out(west_out),
        .local_out(local_out),*/
        .route_out_N(route_out_N),
        .route_out_E(route_out_E),
        .route_out_S(route_out_S),
        .route_out_W(route_out_W),
        .route_out_L(route_out_L)
    );
    assign north_data = intf_out[0].data;
    assign east_data =  intf_out[1].data;
    assign south_data = intf_out[2].data;
    assign west_data =  intf_out[3].data;
    assign local_data = intf_out[4].data;

    assign north_dest_x = intf_out[0].dest_x;
    assign east_dest_x =  intf_out[1].dest_x;
    assign south_dest_x = intf_out[2].dest_x;
    assign west_dest_x =  intf_out[3].dest_x;
    assign local_dest_x = intf_out[4].dest_x;

    assign north_dest_y = intf_out[0].dest_y;
    assign east_dest_y =  intf_out[1].dest_y;
    assign south_dest_y = intf_out[2].dest_y;
    assign west_dest_y =  intf_out[3].dest_y;
    assign local_dest_y = intf_out[4].dest_y;

    assign north_sdx = intf_out[0].s_delta_x;
    assign east_sdx =  intf_out[1].s_delta_x;
    assign south_sdx = intf_out[2].s_delta_x;
    assign west_sdx =  intf_out[3].s_delta_x;
    assign local_sdx = intf_out[4].s_delta_x;

    assign north_sdy = intf_out[0].s_delta_y;
    assign east_sdy =  intf_out[1].s_delta_y;
    assign south_sdy = intf_out[2].s_delta_y;
    assign west_sdy =  intf_out[3].s_delta_y;
    assign local_sdy = intf_out[4].s_delta_y;

    assign north_valid = intf_out[0].valid;
    assign east_valid =  intf_out[1].valid;
    assign south_valid = intf_out[2].valid;
    assign west_valid =  intf_out[3].valid;
    assign local_valid = intf_out[4].valid;
/*
    assign north_data = north_out.data;
    assign east_data = east_out.data;
    assign south_data = south_out.data;
    assign west_data = west_out.data;
    assign local_data = local_out.data;

    assign north_dest_x = north_out.dest_x;
    assign east_dest_x = east_out.dest_x;
    assign south_dest_x = south_out.dest_x;
    assign west_dest_x = west_out.dest_x;
    assign local_dest_x = local_out.dest_x;

    assign north_dest_y = north_out.dest_y;
    assign east_dest_y = east_out.dest_y;
    assign south_dest_y = south_out.dest_y;
    assign west_dest_y = west_out.dest_y;
    assign local_dest_y = local_out.dest_y;

    assign north_sdx = north_out.s_delta_x;
    assign east_sdx = east_out.s_delta_x;
    assign south_sdx = south_out.s_delta_x;
    assign west_sdx = west_out.s_delta_x;
    assign local_sdx = local_out.s_delta_x;

    assign north_sdy = north_out.s_delta_y;
    assign east_sdy = east_out.s_delta_y;
    assign south_sdy = south_out.s_delta_y;
    assign west_sdy = west_out.s_delta_y;
    assign local_sdy = local_out.s_delta_y;
*/
    always #5 clk = ~clk;

    initial $monitor("in: %b\tout N: %b\tout E: %b\tout S: %b\tout W: %b\tout L: %b\t",
        valid,
        route_out_N,
        route_out_E,
        route_out_S,
        route_out_W,
        route_out_L
    );

    initial begin
        clk = 0;
        rst=1;
        intf_in[NORTH].s_delta_x = 0;
        intf_in[NORTH].s_delta_y = 0;
        intf_in[NORTH].dest_x = 0;
        intf_in[NORTH].dest_y = 0;
        intf_in[NORTH].data = 0;
        intf_out[0].ready = 1;
        intf_out[1].ready = 1; // EAST
        intf_out[2].ready = 1;
        intf_out[3].ready = 1; // WEST
        intf_out[4].ready = 1;
        start_ns_prio = 0;
        #10 rst = 0;
        intf_in[NORTH].valid = 1;
        #300 start_ns_prio = 1;
    end
    always @(posedge clk) begin
        if(intf_in[NORTH].ready) begin
            intf_in[NORTH].valid = 1;
            intf_in[NORTH].data = intf_in[NORTH].data + 'ha;
            // verilog_lint: waive-start line-length
            intf_in[NORTH].dest_x = start_ns_prio ? 1 : intf_in[NORTH].dest_x == 2 ? 0 : intf_in[NORTH].dest_x+1;// intf_in[NORTH].dest_x+1;
            intf_in[NORTH].dest_y = intf_in[NORTH].dest_y == 2 ? 0 : intf_in[NORTH].dest_y+1;// intf_in[NORTH].dest_y+1;
            intf_in[NORTH].s_delta_x = intf_in[NORTH].dest_x < 1 ? 1 : 0; // intf_in[NORTH].s_delta_x+1;
            intf_in[NORTH].s_delta_y = intf_in[NORTH].dest_y < 1 ? 1 : 0;// intf_in[NORTH].s_delta_y+1;
            // verilog_lint: waive-stop line-length
        end else begin
            intf_in[NORTH].valid = 0;
        end
    end

    initial #1000 $finish;

/*
    initial begin
        clk = 0;
        rst = 1;
        intf_in.s_delta_x = 1;
        intf_in.s_delta_y = 1;
        intf_in.dest_x = '0;
        intf_in.dest_y = '0;
        intf_in.data = '1;
        intf_in.valid = 0;
        intf_out[1].ready = 0; // EAST
        intf_out[3].ready = 1; // WEST
        #5 rst = 0;
        $display("Starting");
        @(posedge clk) intf_in.valid = 1;
        @(posedge clk) begin
            intf_in.valid = 0;
            intf_in.s_delta_x = 0;
            intf_in.s_delta_y = 0;
            intf_in.dest_x = 2'b10;
            intf_in.dest_y = 2'b10;
            intf_in.data = 'habcdef;
        end
        @(posedge clk) intf_in.valid = 1;
        @(posedge clk) intf_in.valid = 0;
        #100 $finish;

    end
*/


endmodule
