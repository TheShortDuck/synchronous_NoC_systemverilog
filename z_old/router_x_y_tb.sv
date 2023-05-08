import global_params::*;

module router_x_y_tb;
    localparam integer WIDTH = 4;
    logic clk, rst;
    router_if intf_in[NORTH:LOCAL]();
    router_if intf_out[NORTH:LOCAL]();

    logic [DATA_WIDTH-1:0] north_data, east_data, south_data, west_data, local_data;
    logic [$clog2(MESH_SIDE)-1:0] north_dest_x, east_dest_x, south_dest_x, west_dest_x, local_dest_x;
    logic [$clog2(MESH_SIDE)-1:0] north_dest_y, east_dest_y, south_dest_y, west_dest_y, local_dest_y;
    logic north_sdx, east_sdx, south_sdx, west_sdx, local_sdx;
    logic north_sdy, east_sdy, south_sdy, west_sdy, local_sdy;
    logic north_valid, east_valid, south_valid, west_valid, local_valid;
    logic [4:0] ready_sigs;
    logic [NORTH:LOCAL] last;

    logic start_ns_prio;

    router_x_y #( // Router for 2d mesh (x and y)
        .X_COORD(1),
        .Y_COORD(1)
    ) router_inst (
        .clk(clk),
        .rst(rst),
        .intf_in(intf_in),
        .intf_out(intf_out)
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

    assign ready_sigs = {
        intf_in[0].ready,
        intf_in[1].ready,
        intf_in[2].ready,
        intf_in[3].ready,
        intf_in[4].ready
    };

    always #5 clk = ~clk;

    //initial $monitor("out N: %b\tout E: %b\tout S: %b\tout W: %b\tout L: %b\t",route_out_N,route_out_E,route_out_S,route_out_W,route_out_L);

    initial begin
        #1;
        clk = 0;
        rst=1;
        intf_in[NORTH].s_delta_x = 0;
        intf_in[NORTH].s_delta_y = 0;
        intf_in[NORTH].dest_x = 0;
        intf_in[NORTH].dest_y = 0;
        intf_in[NORTH].data = 0;

        intf_in[EAST].s_delta_x = 0;
        intf_in[EAST].s_delta_y = 0;
        intf_in[EAST].dest_x = 1;
        intf_in[EAST].dest_y = 0;
        intf_in[EAST].data = 0;

        intf_in[SOUTH].s_delta_x = 0;
        intf_in[SOUTH].s_delta_y = 0;
        intf_in[SOUTH].dest_x = 0;
        intf_in[SOUTH].dest_y = 1;
        intf_in[SOUTH].data = 0;

        intf_in[WEST].s_delta_x = 0;
        intf_in[WEST].s_delta_y = 0;
        intf_in[WEST].dest_x = 1;
        intf_in[WEST].dest_y = 1;
        intf_in[WEST].data = 0;

        intf_in[LOCAL].s_delta_x = 0;
        intf_in[LOCAL].s_delta_y = 0;
        intf_in[LOCAL].dest_x = 2;
        intf_in[LOCAL].dest_y = 1;
        intf_in[LOCAL].data = 0;

        intf_out[NORTH].ready = 0;
        intf_out[EAST].ready  = 0; // EAST
        intf_out[SOUTH].ready = 0;
        intf_out[WEST].ready  = 0; // WEST
        intf_out[LOCAL].ready = 0;

        intf_in[NORTH].valid = 0;
        intf_in[EAST].valid = 0;
        intf_in[SOUTH].valid = 0;
        intf_in[WEST].valid = 0;
        intf_in[LOCAL].valid = 0;

        start_ns_prio = 0;
        #30 rst = 0;

        intf_out[NORTH].ready = 1;
        intf_out[EAST].ready  = 1; // EAST
        intf_out[SOUTH].ready = 1;
        intf_out[WEST].ready  = 1; // WEST
        intf_out[LOCAL].ready = 1;

        intf_in[NORTH].valid = 0;
        intf_in[EAST].valid = 0;
        intf_in[SOUTH].valid = 0;
        intf_in[WEST].valid = 0;
        intf_in[LOCAL].valid = 0;


        #300 start_ns_prio = 1;
    end

    always @(posedge clk) begin
        if(intf_in[NORTH].ready && !last[NORTH]) begin
            intf_in[NORTH].valid = 1;
            intf_in[NORTH].data = {128{4'h1}};
            intf_in[NORTH].dest_x = $urandom_range(2);
            intf_in[NORTH].dest_y = $urandom_range(1);
            intf_in[NORTH].s_delta_x = intf_in[NORTH].dest_x < 1 ? 1 : 0;
            intf_in[NORTH].s_delta_y = intf_in[NORTH].dest_y < 1 ? 1 : 0;
            last[NORTH] = 1;
        end else begin
            intf_in[NORTH].valid = 0;
            last[NORTH] = 0;
        end
        if(intf_in[EAST].ready && !last[EAST]) begin
            intf_in[EAST].valid = 1;
            intf_in[EAST].data = {128{4'h2}};
            intf_in[EAST].dest_x = $urandom_range(1);
            intf_in[EAST].dest_y = $urandom_range(2);
            intf_in[EAST].s_delta_x = intf_in[EAST].dest_x < 1 ? 1 : 0;
            intf_in[EAST].s_delta_y = intf_in[EAST].dest_y < 1 ? 1 : 0;
            last[EAST] = 1;
        end else begin
            intf_in[EAST].valid = 0;
            last[EAST] = 0;
        end
        if(intf_in[SOUTH].ready && !last[SOUTH])  begin
            intf_in[SOUTH].valid = 1;
            intf_in[SOUTH].data = {128{4'h3}};
            intf_in[SOUTH].dest_x = $urandom_range(2);
            intf_in[SOUTH].dest_y = $urandom_range(2,1);
            intf_in[SOUTH].s_delta_x = intf_in[SOUTH].dest_x < 1 ? 1 : 0;
            intf_in[SOUTH].s_delta_y = intf_in[SOUTH].dest_y < 1 ? 1 : 0;
            last[SOUTH] = 1;
        end else begin
            intf_in[SOUTH].valid = 0;
            last[SOUTH] = 0;
        end
        if(intf_in[WEST].ready && !last[WEST]) begin
            intf_in[WEST].valid = 1;
            intf_in[WEST].data = {128{4'h4}};
            intf_in[WEST].dest_x = $urandom_range(2,1);
            intf_in[WEST].dest_y = $urandom_range(2);
            intf_in[WEST].s_delta_x = intf_in[3].dest_x < 1 ? 1 : 0;
            intf_in[WEST].s_delta_y = intf_in[3].dest_y < 1 ? 1 : 0;
            last[WEST] = 1;
        end else begin
            intf_in[WEST].valid = 0;
            last[WEST] = 0;
        end
        if(intf_in[LOCAL].ready && !last[LOCAL]) begin
            intf_in[LOCAL].valid = 1;
            intf_in[LOCAL].data = {128{4'h5}};
            intf_in[LOCAL].dest_x = $urandom_range(1)*2;
            intf_in[LOCAL].dest_y = $urandom_range(1)*2;
            intf_in[LOCAL].s_delta_x = intf_in[LOCAL].dest_x < 1 ? 1 : 0;
            intf_in[LOCAL].s_delta_y = intf_in[LOCAL].dest_y < 1 ? 1 : 0;
            last[LOCAL] = 1;
        end else begin
            intf_in[LOCAL].valid = 0;
            last[LOCAL] = 0;
        end
    end

    initial #1000 $finish;

endmodule
