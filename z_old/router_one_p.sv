import global_params::*;

module router_one_p #( // Router for 2d mesh (x and y)
    parameter integer X_COORD = 0,
    parameter integer Y_COORD = 0
)(
    input clk,
    input rst,
    input valid,
    // N
    router_if.in_p  north_in[NORTH:LOCAL],
    router_if.out_p  intf_out[NORTH:LOCAL],
    /*router_if.out_p  east_out,
    router_if.out_p  south_out,
    router_if.out_p  west_out,
    router_if.out_p  local_out,*/
    output logic route_out_N,
    output logic route_out_E,
    output logic route_out_S,
    output logic route_out_W,
    output logic route_out_L
);
    typedef enum {NORTH, EAST, SOUTH, WEST, LOCAL} port_t;
    // SIGNALS
    // Registers for input interfaces
    logic [DATA_WIDTH-1:0] data_reg [NORTH:LOCAL];
    logic sdx_reg [NORTH:LOCAL];
    logic sdy_reg [NORTH:LOCAL];
    logic [$clog2(MESH_SIDE) - 1:0] dest_x_reg [NORTH:LOCAL];
    logic [$clog2(MESH_SIDE) - 1:0] dest_y_reg [NORTH:LOCAL];
    logic valid_reg [NORTH:LOCAL];
    // R block signals
    //logic [LOCAL:NORTH] route_intent_north; // Intents north as output, index determines input
    //logic [LOCAL:NORTH] route_intent_east;
    //logic [LOCAL:NORTH] route_intent_south;
    //logic [LOCAL:NORTH] route_intent_west;
    //logic [LOCAL:NORTH] route_intent_local;
    logic route_intent [NORTH:LOCAL][LOCAL:NORTH]; // index 1: inp, 2: out
    logic route_grant [NORTH:LOCAL][LOCAL:NORTH]; // 1: origin, 2: destination
    genvar i;

    // HANDLE REGISTERS
    /*always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            data_reg    <= '{default:0};
            sdx_reg     <= '{default:0};
            sdy_reg     <= '{default:0};
            dest_x_reg  <= '{default:0};
            dest_y_reg  <= '{default:0};
        end else begin // Remember only do this when valid signal!
            valid_reg[NORTH]  <= north_in.valid;
            if (north_in.valid) begin
                data_reg[NORTH]   <= north_in.data;
                sdx_reg[NORTH]    <= north_in.s_delta_x;
                sdy_reg[NORTH]    <= north_in.s_delta_y;
                dest_x_reg[NORTH] <= north_in.dest_x;
                dest_y_reg[NORTH] <= north_in.dest_y;
            end
        end
    end
    */
    generate
        for(i=NORTH;i<=LOCAL;i++)begin: gen_handle_reg
            always_ff @(posedge clk or posedge rst) begin
                if(rst) begin
                    data_reg[i]    <= '0;
                    sdx_reg[i]     <= '0;
                    sdy_reg[i]     <= 0;
                    dest_x_reg[i]  <= 0;
                    dest_y_reg[i]  <= 0;
                    route_intent <= '{default:0};
                end else begin // Remember only do this when valid signal!
                    valid_reg[i]  <= north_in[i].valid;

                    if (north_in[i].valid) begin
                        data_reg[i]   <= north_in[i].data;
                        sdx_reg[i]    <= north_in[i].s_delta_x;
                        sdy_reg[i]    <= north_in[i].s_delta_y;
                        dest_x_reg[i] <= north_in[i].dest_x;
                        dest_y_reg[i] <= north_in[i].dest_y;
                    end
                end
            end
        end
    endgenerate

    // -------------- Handle Ready -------------- (Seems to work?)
    always_ff @(posedge clk or posedge rst) begin
        if(rst)begin
            north_in[NORTH].ready <= 1;
        end else begin
            if (route_grant[NORTH].or()) north_in[NORTH].ready <= 1;
            else if (valid_reg[NORTH])   north_in[NORTH].ready <= 0;
        end
    end

    /* Implement this as a module
        The R block takes each input port and determines output port
        Then the arbiters takes each "selection" from the R blocks and determines priority for given output port
    always_comb begin
        north_eqx = north_dest_x_reg != X_COORD; // Equality check coords,
        north_eqy = north_dest_y_reg != Y_COORD; // don't know if ineqaulity or eq is best yet

        //north_r_west = ; // Decide if want to make route block as module (mby reuse route_logic.sv)

    end
    */
    //------- ROUTER BLOCKS -------
    r_block #(
        .X_COORD(X_COORD),
        .Y_COORD(Y_COORD)
    ) r_block_inst (
        .dest_x(dest_x_reg[NORTH]),
        .dest_y(dest_y_reg[NORTH]),
        .s_delta_x(sdx_reg[NORTH]),
        .s_delta_y(sdy_reg[NORTH]),
        .valid(valid_reg[NORTH]),
        .route_north(route_intent[NORTH][NORTH]),
        .route_east(route_intent[NORTH][EAST]),
        .route_south(route_intent[NORTH][SOUTH]),
        .route_west(route_intent[NORTH][WEST]),
        .route_local(route_intent[NORTH][LOCAL])
    );

    generate
        for(i=NORTH;i<=LOCAL;i++)begin: gen_r_block

            arbiter arbiter_inst (
                .req0(route_intent[NORTH][i]),
                .req1(route_intent[EAST][i]),
                .req2(route_intent[SOUTH][i]),
                .req3(route_intent[WEST][i]),
                .req4(route_intent[LOCAL][i]),
                .gnt0(route_grant[NORTH][i]),
                .gnt1(route_grant[EAST][i]),
                .gnt2(route_grant[SOUTH][i]),
                .gnt3(route_grant[WEST][i]),
                .gnt4(route_grant[LOCAL][i]),
                .clk(clk),
                .rst(rst)
            );
        end
    endgenerate
    //-----------------------------
    //----------------------------- Output ports -----------------------------

    generate
        for(i=NORTH;i<=LOCAL;i++) begin: g_outputs
            if (i != NORTH) begin: g_nest1 // This avoids assigning input port to same output
                always_ff @(posedge clk or posedge rst) begin
                    if(!intf_out[i].ready) begin
                        intf_out[i].data      <=0;
                        intf_out[i].dest_x    <=0;
                        intf_out[i].dest_y    <=0;
                        intf_out[i].s_delta_x <=0;
                        intf_out[i].s_delta_y <=0;
                        intf_out[i].valid     <=0;
                    end else if (route_grant[NORTH][i]) begin
                        intf_out[i].data      <= data_reg[NORTH];
                        intf_out[i].dest_x    <= dest_x_reg[NORTH];
                        intf_out[i].dest_y    <= dest_y_reg[NORTH];
                        intf_out[i].s_delta_x <= sdx_reg[NORTH];
                        intf_out[i].s_delta_y <= sdy_reg[NORTH];
                        intf_out[i].valid     <= route_grant[NORTH][i];
                    end
                end
            end
        end
    endgenerate

/*
    generate
        for(i=NORTH;i<=LOCAL;i++) begin: g_outputs
            assign intf_out[i].data      = data_reg[NORTH] & {512{route_grant[NORTH][i]}};
            assign intf_out[i].dest_x    = dest_x_reg[NORTH] & {$clog2(north_in.MESH_SIDE){route_grant[NORTH][i]}};
            assign intf_out[i].dest_y    = dest_y_reg[NORTH] & {$clog2(north_in.MESH_SIDE){route_grant[NORTH][i]}};
            assign intf_out[i].s_delta_x = sdx_reg[NORTH] & route_grant[NORTH][i];
            assign intf_out[i].s_delta_y = sdy_reg[NORTH] & route_grant[NORTH][i];
            assign intf_out[i].valid     = route_grant[NORTH][i];
        end
    endgenerate
*/
/*
    assign north_out.data      = data_reg[NORTH] & {512{route_grant[NORTH][NORTH]}};
    assign north_out.dest_x    = dest_x_reg[NORTH] & {$clog2(north_in.MESH_SIDE){route_grant[NORTH][NORTH]}};
    assign north_out.dest_y    = dest_y_reg[NORTH] & {$clog2(north_in.MESH_SIDE){route_grant[NORTH][NORTH]}};
    assign north_out.s_delta_x = sdx_reg[NORTH] & route_grant[NORTH][NORTH];
    assign north_out.s_delta_y = sdy_reg[NORTH] & route_grant[NORTH][NORTH];
    assign north_out.valid     = route_grant[NORTH][NORTH];

    assign east_out.data      = data_reg[NORTH] & {512{route_grant[NORTH][EAST]}};
    assign east_out.dest_x    = dest_x_reg[NORTH] & {$clog2(north_in.MESH_SIDE){route_grant[NORTH][EAST]}};
    assign east_out.dest_y    = dest_y_reg[NORTH] & {$clog2(north_in.MESH_SIDE){route_grant[NORTH][EAST]}};
    assign east_out.s_delta_x = sdx_reg[NORTH] & route_grant[NORTH][EAST];
    assign east_out.s_delta_y = sdy_reg[NORTH] & route_grant[NORTH][EAST];
    assign east_out.valid     = route_grant[NORTH][EAST];

    assign south_out.data      = data_reg[NORTH] & {512{route_grant[NORTH][SOUTH]}};
    assign south_out.dest_x    = dest_x_reg[NORTH] & {$clog2(north_in.MESH_SIDE){route_grant[NORTH][SOUTH]}};
    assign south_out.dest_y    = dest_y_reg[NORTH] & {$clog2(north_in.MESH_SIDE){route_grant[NORTH][SOUTH]}};
    assign south_out.s_delta_x = sdx_reg[NORTH] & route_grant[NORTH][SOUTH];
    assign south_out.s_delta_y = sdy_reg[NORTH] & route_grant[NORTH][SOUTH];
    assign south_out.valid     = route_grant[NORTH][SOUTH];

    assign west_out.data      = data_reg[NORTH] & {512{route_grant[NORTH][WEST]}};
    assign west_out.dest_x    = dest_x_reg[NORTH] & {$clog2(north_in.MESH_SIDE){route_grant[NORTH][WEST]}};
    assign west_out.dest_y    = dest_y_reg[NORTH] & {$clog2(north_in.MESH_SIDE){route_grant[NORTH][WEST]}};
    assign west_out.s_delta_x = sdx_reg[NORTH] & route_grant[NORTH][WEST];
    assign west_out.s_delta_y = sdy_reg[NORTH] & route_grant[NORTH][WEST];
    assign west_out.valid     = route_grant[NORTH][WEST];

    assign local_out.data      = data_reg[NORTH] & {512{route_grant[NORTH][LOCAL]}};
    assign local_out.dest_x    = dest_x_reg[NORTH] & {$clog2(north_in.MESH_SIDE){route_grant[NORTH][LOCAL]}};
    assign local_out.dest_y    = dest_y_reg[NORTH] & {$clog2(north_in.MESH_SIDE){route_grant[NORTH][LOCAL]}};
    assign local_out.s_delta_x = sdx_reg[NORTH] & route_grant[NORTH][LOCAL];
    assign local_out.s_delta_y = sdy_reg[NORTH] & route_grant[NORTH][LOCAL];
    assign local_out.valid     = route_grant[NORTH][LOCAL];
*/
    //----------------------------- Output ports -----------------------------

    assign route_out_N = route_grant[NORTH][NORTH];
    assign route_out_E = route_grant[NORTH][EAST];
    assign route_out_S = route_grant[NORTH][SOUTH];
    assign route_out_W = route_grant[NORTH][WEST];
    assign route_out_L = route_grant[NORTH][LOCAL];

endmodule
/*
when send data, valid is sen along with data, packet is thrown into register
The header of the packet is evaluated in the r_blocks, and these are connected to arbiters for determine output
(arbiters should be fair, not prioritize LSB as now)

When done, the logic could maybe be reduced with generate statements
*/


/*
    generate
        for(i=NORTH;i<=LOCAL;i++) begin: g_outputs
            if (i != NORTH) begin: g_nest1 // This avoids assigning input port to same output
                always_ff @(posedge clk or posedge rst) begin
                    if (route_grant[NORTH][i]) begin
                        intf_out[i].data      <= data_reg[NORTH];
                        intf_out[i].dest_x    <= dest_x_reg[NORTH];
                        intf_out[i].dest_y    <= dest_y_reg[NORTH];
                        intf_out[i].s_delta_x <= sdx_reg[NORTH];
                        intf_out[i].s_delta_y <= sdy_reg[NORTH];
                        intf_out[i].valid     <= route_grant[NORTH][i];
                    end else if(!intf_out[i].ready) begin
                        intf_out[i].data      <=intf_out[i].data;
                        intf_out[i].dest_x    <=intf_out[i].dest_x;
                        intf_out[i].dest_y    <=intf_out[i].dest_y;
                        intf_out[i].s_delta_x <=intf_out[i].s_delta_x;
                        intf_out[i].s_delta_y <=intf_out[i].s_delta_y;
                        intf_out[i].valid     <=intf_out[i].valid;
                    end else begin
                        intf_out[i].data      <= 0;
                        intf_out[i].dest_x    <= 0;
                        intf_out[i].dest_y    <= 0;
                        intf_out[i].s_delta_x <= 0;
                        intf_out[i].s_delta_y <= 0;
                        intf_out[i].valid     <= 0;
                    end
                end
            end
        end
    endgenerate
*/
