import global_params::*;

// verilog_lint: waive module-filename
module router_x_y #( // Router for 2d mesh (x and y)
    parameter integer X_COORD = 0,
    parameter integer Y_COORD = 0
)(
    input clk,
    input rst,

    router_if.in_p intf_in[NORTH:LOCAL],
    router_if.out_p intf_out[NORTH:LOCAL]
);
// -------------------------------- SIGNALS -------------------------------
    // Registers for input interfaces
    logic [DATA_WIDTH-1:0] data_reg [NORTH:LOCAL];
    logic sdx_reg [NORTH:LOCAL];
    logic sdy_reg [NORTH:LOCAL];
    logic [$clog2(MESH_SIDE) - 1:0] dest_x_reg [NORTH:LOCAL];
    logic [$clog2(MESH_SIDE) - 1:0] dest_y_reg [NORTH:LOCAL];
    logic valid_reg [NORTH:LOCAL];

    // R_block and Arbiter signals
    logic route_intent [NORTH:LOCAL][LOCAL:NORTH]; // Index - 1: origin, 2: destination
    logic route_grant [NORTH:LOCAL][LOCAL:NORTH];

    // Other signals/variables
    genvar i, j; // Generation variable

// ------------------------------------------------------------------------

// --------------------------- HANDLE REGISTERS ---------------------------
    generate
        for(i=0;i<=4;i++)begin: gen_handle_reg
            always_ff @(posedge clk or posedge rst) begin
                if(rst) begin
                    data_reg[i]    <= 0;
                    sdx_reg[i]     <= 0;
                    sdy_reg[i]     <= 0;
                    dest_x_reg[i]  <= 0;
                    dest_y_reg[i]  <= 0;
                    valid_reg[i]   <= 0;

                end else begin
                    valid_reg[i]  <= intf_in[i].valid; // Update valid either way

                    if (intf_in[i].valid) begin
                        data_reg[i]   <= intf_in[i].data;
                        sdx_reg[i]    <= intf_in[i].s_delta_x;
                        sdy_reg[i]    <= intf_in[i].s_delta_y;
                        dest_x_reg[i] <= intf_in[i].dest_x;
                        dest_y_reg[i] <= intf_in[i].dest_y;
                    end
                end
            end
        end
    endgenerate
// ------------------------------------------------------------------------

// ----------------------------- Handle Ready ----------------------------- (Seems to work?)
    generate
        for(i=0;i<=4;i++)begin: gen_handle_rdy
            always_ff @(posedge clk or posedge rst) begin
                if(rst)begin
                    intf_in[i].ready <= 1;
                end else begin
                    if(valid_reg[i] && (route_intent[i] != route_grant[i]))   intf_in[i].ready <= 0;
                    else intf_in[i].ready <= 1; // NOT WORKING, FIX!
                end
            end
        end
    endgenerate
// ------------------------------------------------------------------------

// -------------------------- R_BLOCKS & ARBITER --------------------------
    generate
        for(i=0;i<=4;i++)begin: gen_r_block
            r_block #(
                .X_COORD(X_COORD),
                .Y_COORD(Y_COORD)
            ) r_block_inst (
                .dest_x(dest_x_reg[i]),
                .dest_y(dest_y_reg[i]),
                .s_delta_x(sdx_reg[i]),
                .s_delta_y(sdy_reg[i]),
                .valid(valid_reg[i]),
                .route_north(route_intent[i][NORTH]),
                .route_east(route_intent[i][EAST]),
                .route_south(route_intent[i][SOUTH]),
                .route_west(route_intent[i][WEST]),
                .route_local(route_intent[i][LOCAL])
            );

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
// ------------------------------------------------------------------------

// ----------------------------- Output ports -----------------------------
    generate
        for(i=0;i<=4;i++) begin: g_output_ports
            //if (i != j) begin: g_n_avoid // This avoids assigning input port to same output
            always_ff @(posedge clk or posedge rst) begin
                if (rst) begin
                    intf_out[i].data      <= 0;
                    intf_out[i].dest_x    <= 0;
                    intf_out[i].dest_y    <= 0;
                    intf_out[i].s_delta_x <= 0;
                    intf_out[i].s_delta_y <= 0;
                    intf_out[i].valid     <= 0;
                end else begin
                    if (intf_out[i].ready && route_grant[NORTH][i]) begin
                        intf_out[i].data      <= data_reg[NORTH];
                        intf_out[i].dest_x    <= dest_x_reg[NORTH];
                        intf_out[i].dest_y    <= dest_y_reg[NORTH];
                        intf_out[i].s_delta_x <= sdx_reg[NORTH];
                        intf_out[i].s_delta_y <= sdy_reg[NORTH];
                        intf_out[i].valid     <= route_grant[NORTH][i];
                    end
                    else if (intf_out[i].ready && route_grant[EAST][i]) begin
                        intf_out[i].data      <= data_reg[EAST];
                        intf_out[i].dest_x    <= dest_x_reg[EAST];
                        intf_out[i].dest_y    <= dest_y_reg[EAST];
                        intf_out[i].s_delta_x <= sdx_reg[EAST];
                        intf_out[i].s_delta_y <= sdy_reg[EAST];
                        intf_out[i].valid     <= route_grant[EAST][i];
                    end
                    else if (intf_out[i].ready && route_grant[SOUTH][i]) begin
                        intf_out[i].data      <= data_reg[SOUTH];
                        intf_out[i].dest_x    <= dest_x_reg[SOUTH];
                        intf_out[i].dest_y    <= dest_y_reg[SOUTH];
                        intf_out[i].s_delta_x <= sdx_reg[SOUTH];
                        intf_out[i].s_delta_y <= sdy_reg[SOUTH];
                        intf_out[i].valid     <= route_grant[SOUTH][i];
                    end
                    else if (intf_out[i].ready && route_grant[WEST][i]) begin
                        intf_out[i].data      <= data_reg[WEST];
                        intf_out[i].dest_x    <= dest_x_reg[WEST];
                        intf_out[i].dest_y    <= dest_y_reg[WEST];
                        intf_out[i].s_delta_x <= sdx_reg[WEST];
                        intf_out[i].s_delta_y <= sdy_reg[WEST];
                        intf_out[i].valid     <= route_grant[WEST][i];
                    end
                    else if (intf_out[i].ready && route_grant[LOCAL][i]) begin
                        intf_out[i].data      <= data_reg[LOCAL];
                        intf_out[i].dest_x    <= dest_x_reg[LOCAL];
                        intf_out[i].dest_y    <= dest_y_reg[LOCAL];
                        intf_out[i].s_delta_x <= sdx_reg[LOCAL];
                        intf_out[i].s_delta_y <= sdy_reg[LOCAL];
                        intf_out[i].valid     <= route_grant[LOCAL][i];
                    end else begin
                        intf_out[i].valid     <= 0;
                    end
                end
            end
        end
    endgenerate


endmodule

// NOTES AND LEGACY
/*
when send data, valid is sen along with data, packet is thrown into register
The header of the packet is evaluated in the r_blocks, and these are connected to arbiters for determine output
(arbiters should be fair, not prioritize LSB as now)

When done, the logic could maybe be reduced with generate statements
*/
    /* Implement this as a module (referring to the r_block, that exists now)
        The R block takes each input port and determines output port
        Then the arbiters takes each "selection" from the R blocks and determines priority for given output port
    always_comb begin
        north_eqx = north_dest_x_reg != X_COORD; // Equality check coords,
        north_eqy = north_dest_y_reg != Y_COORD; // don't know if ineqaulity or eq is best yet

        //north_r_west = ; // Decide if want to make route block as module (mby reuse route_logic.sv)

    end
    */

// OLD REGISTER HANDLING
    /*always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            data_reg    <= '{default:0};
            sdx_reg     <= '{default:0};
            sdy_reg     <= '{default:0};
            dest_x_reg  <= '{default:0};
            dest_y_reg  <= '{default:0};
            valid_reg   <= '{default:0};
        end else if (valid) begin // only feed register when valid!
            data_reg[NORTH]   <= north_in.data;
            data_reg[EAST]    <= east_in.data;
            data_reg[SOUTH]   <= south_in.data;
            data_reg[WEST]    <= west_in.data;
            data_reg[LOCAL]   <= local_in.data;

            sdx_reg[NORTH]    <= north_in.s_delta_x;
            sdx_reg[EAST]     <= east_in.s_delta_x;
            sdx_reg[SOUTH]    <= south_in.s_delta_x;
            sdx_reg[WEST]     <= west_in.s_delta_x;
            sdx_reg[LOCAL]    <= local_in.s_delta_x;

            sdy_reg[NORTH]    <= north_in.s_delta_y;
            sdy_reg[EAST]     <= east_in.s_delta_y;
            sdy_reg[SOUTH]    <= south_in.s_delta_y;
            sdy_reg[WEST]     <= west_in.s_delta_y;
            sdy_reg[LOCAL]    <= local_in.s_delta_y;

            dest_x_reg[NORTH] <= north_in.dest_x;
            dest_x_reg[EAST]  <= east_in.dest_x;
            dest_x_reg[SOUTH] <= south_in.dest_x;
            dest_x_reg[WEST]  <= west_in.dest_x;
            dest_x_reg[LOCAL] <= local_in.dest_x;

            dest_y_reg[NORTH] <= north_in.dest_y;
            dest_y_reg[EAST]  <= east_in.dest_y;
            dest_y_reg[SOUTH] <= south_in.dest_y;
            dest_y_reg[WEST]  <= west_in.dest_y;
            dest_y_reg[LOCAL] <= local_in.dest_y;

            valid_reg[NORTH]  <= north_in.valid;
            valid_reg[EAST]   <= east_in.valid;
            valid_reg[SOUTH]  <= south_in.valid;
            valid_reg[WEST]   <= west_in.valid;
            valid_reg[LOCAL]  <= local_in.valid;
        end
    end*/

// BROKEN MULTIPLE DRIVERS
/*
// ----------------------------- Output ports -----------------------------
    generate
        for(i=0;i<=4;i++) begin: g_oo
            for(j=0;j<=4;j++) begin: g_oi
                if (i != j) begin: g_n_avoid // This avoids assigning input port to same output
                    always_ff @(posedge clk or posedge rst) begin
                        if(!intf_out[i].ready) begin
                            intf_out[i].data      <=intf_out[i].data;
                            intf_out[i].dest_x    <=intf_out[i].dest_x;
                            intf_out[i].dest_y    <=intf_out[i].dest_y;
                            intf_out[i].s_delta_x <=intf_out[i].s_delta_x;
                            intf_out[i].s_delta_y <=intf_out[i].s_delta_y;
                            intf_out[i].valid     <=intf_out[i].valid;
                        end else if (intf_out[i].ready && route_grant[j][i]) begin
                            intf_out[i].data      <= data_reg[j];
                            intf_out[i].dest_x    <= dest_x_reg[j];
                            intf_out[i].dest_y    <= dest_y_reg[j];
                            intf_out[i].s_delta_x <= sdx_reg[j];
                            intf_out[i].s_delta_y <= sdy_reg[j];
                            intf_out[i].valid     <= route_grant[j][i];
                        end
                    end
                end
            end
        end
    endgenerate
*/
