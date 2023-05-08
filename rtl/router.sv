// -----------------------------------------------------------------------
// Router module
// This module has 9 ports, X, Y, diagnonal and a local port
// -----------------------------------------------------------------------
import global_params::*;

// ---------------------------- Router Entity ----------------------------
module router #(
    parameter integer X_COORD = 0,
    parameter integer Y_COORD = 0
)(
    input clk,
    input rst,

    router_if.in_p intf_in[NORTH:SW],
    router_if.out_p intf_out[NORTH:SW]
);
// ------------------------------- Signals -------------------------------
    // Registers for input interfaces
    logic [DATA_WIDTH-1:0] data_reg [NORTH:SW];
    logic sdx_reg [NORTH:SW];
    logic sdy_reg [NORTH:SW];
    logic [$clog2(MESH_SIDE) - 1:0] dest_x_reg [NORTH:SW];
    logic [$clog2(MESH_SIDE) - 1:0] dest_y_reg [NORTH:SW];
    logic valid_reg [NORTH:SW];

    // R_block and Arbiter signals
    logic route_intent [NORTH:SW][SW:NORTH]; // Idx - 1: Origin, 2: Dest
    logic route_grant [NORTH:SW][SW:NORTH];

    // Other signals/variables
    genvar i, j; // Generation variables

// --------------------------- Handle Registers --------------------------
    generate
        for(i=NORTH;i<=SW;i++)begin: gen_handle_reg // Loop over all ports
            always_ff @(posedge clk or posedge rst) begin
                if(rst) begin
                    data_reg[i]    <= 0;
                    sdx_reg[i]     <= 0;
                    sdy_reg[i]     <= 0;
                    dest_x_reg[i]  <= 0;
                    dest_y_reg[i]  <= 0;
                    valid_reg[i]   <= 0;

                end else begin
                    if (intf_in[i].valid) begin
                        data_reg[i]   <= intf_in[i].data;
                        sdx_reg[i]    <= intf_in[i].s_delta_x;
                        sdy_reg[i]    <= intf_in[i].s_delta_y;
                        dest_x_reg[i] <= intf_in[i].dest_x;
                        dest_y_reg[i] <= intf_in[i].dest_y;
                        valid_reg[i]  <= 1; // Set valid in on register
                    end else if (intf_in[i].ready) begin
                        valid_reg[i] <= 0; // Set valid low again on ready
                    end

                end
            end
        end
    endgenerate

// ----------------------------- Handle Ready ----------------------------
    generate
        for(i=NORTH;i<=SW;i++)begin: gen_handle_rdy
            assign intf_in[i].ready = (
                (valid_reg[i] || intf_in[i].valid) ? (
                (route_intent[i] == route_grant[i]) ? 1 : 0) : 1);
        end
    endgenerate

// -------------------------- R_blocks & Arbiter -------------------------
    generate
        for(i=NORTH;i<=SW;i++)begin: gen_r_block
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
                .route_local(route_intent[i][LOCAL]),
                .route_ne(route_intent[i][NE]),
                .route_nw(route_intent[i][NW]),
                .route_se(route_intent[i][SE]),
                .route_sw(route_intent[i][SW])
            );

            arbiter arbiter_inst (
                .req0(route_intent[NORTH][i]),
                .req1(route_intent[EAST][i]),
                .req2(route_intent[SOUTH][i]),
                .req3(route_intent[WEST][i]),
                .req4(route_intent[LOCAL][i]),
                .req5(route_intent[NE][i]),
                .req6(route_intent[NW][i]),
                .req7(route_intent[SE][i]),
                .req8(route_intent[SW][i]),
                .gnt0(route_grant[NORTH][i]),
                .gnt1(route_grant[EAST][i]),
                .gnt2(route_grant[SOUTH][i]),
                .gnt3(route_grant[WEST][i]),
                .gnt4(route_grant[LOCAL][i]),
                .gnt5(route_grant[NE][i]),
                .gnt6(route_grant[NW][i]),
                .gnt7(route_grant[SE][i]),
                .gnt8(route_grant[SW][i]),
                .clk(clk),
                .rst(rst)
            );

        end
    endgenerate

// ----------------------------- Output ports -----------------------------
    generate
        for(i=NORTH;i<=SW;i++) begin: g_comb_out
            assign intf_out[i].data = intf_out[i].ready ? (
                {DATA_WIDTH{route_grant[NORTH][i]}}     & data_reg[NORTH]
                | {DATA_WIDTH{route_grant[EAST][i]}}    & data_reg[EAST]
                | {DATA_WIDTH{route_grant[SOUTH][i]}}   & data_reg[SOUTH]
                | {DATA_WIDTH{route_grant[WEST][i]}}    & data_reg[WEST]
                | {DATA_WIDTH{route_grant[LOCAL][i]}}   & data_reg[LOCAL]
                | {DATA_WIDTH{route_grant[NE][i]}}      & data_reg[NE]
                | {DATA_WIDTH{route_grant[NW][i]}}      & data_reg[NW]
                | {DATA_WIDTH{route_grant[SE][i]}}      & data_reg[SE]
                | {DATA_WIDTH{route_grant[SW][i]}}      & data_reg[SW]) : 0;
                // Currently lowest amount of LUTs

            assign intf_out[i].dest_x = ~intf_out[i].ready ? 0 :
                route_grant[NORTH][i]   ? dest_x_reg[NORTH] :
                route_grant[EAST][i]    ? dest_x_reg[EAST] :
                route_grant[SOUTH][i]   ? dest_x_reg[SOUTH] :
                route_grant[WEST][i]    ? dest_x_reg[WEST] :
                route_grant[LOCAL][i]   ? dest_x_reg[LOCAL] :
                route_grant[NE][i]      ? dest_x_reg[NE] :
                route_grant[NW][i]      ? dest_x_reg[NW] :
                route_grant[SE][i]      ? dest_x_reg[SE] :
                route_grant[SW][i]      ? dest_x_reg[SW] : 0;

            assign intf_out[i].dest_y = ~intf_out[i].ready ? 0 :
                route_grant[NORTH][i]   ? dest_y_reg[NORTH] :
                route_grant[EAST][i]    ? dest_y_reg[EAST] :
                route_grant[SOUTH][i]   ? dest_y_reg[SOUTH] :
                route_grant[WEST][i]    ? dest_y_reg[WEST] :
                route_grant[LOCAL][i]   ? dest_y_reg[LOCAL] :
                route_grant[NE][i]      ? dest_y_reg[NE] :
                route_grant[NW][i]      ? dest_y_reg[NW] :
                route_grant[SE][i]      ? dest_y_reg[SE] :
                route_grant[SW][i]      ? dest_y_reg[SW] : 0;

            assign intf_out[i].s_delta_x = ~intf_out[i].ready ? 0 :
                route_grant[NORTH][i]   ? sdx_reg[NORTH] :
                route_grant[EAST][i]    ? sdx_reg[EAST] :
                route_grant[SOUTH][i]   ? sdx_reg[SOUTH] :
                route_grant[WEST][i]    ? sdx_reg[WEST] :
                route_grant[LOCAL][i]   ? sdx_reg[LOCAL] :
                route_grant[NE][i]      ? sdx_reg[NE] :
                route_grant[NW][i]      ? sdx_reg[NW] :
                route_grant[SE][i]      ? sdx_reg[SE] :
                route_grant[SW][i]      ? sdx_reg[SW] : 0;

            assign intf_out[i].s_delta_y = ~intf_out[i].ready ? 0 :
                route_grant[NORTH][i]   ? sdy_reg[NORTH] :
                route_grant[EAST][i]    ? sdy_reg[EAST] :
                route_grant[SOUTH][i]   ? sdy_reg[SOUTH] :
                route_grant[WEST][i]    ? sdy_reg[WEST] :
                route_grant[LOCAL][i]   ? sdy_reg[LOCAL] :
                route_grant[NE][i]      ? sdy_reg[NE] :
                route_grant[NW][i]      ? sdy_reg[NW] :
                route_grant[SE][i]      ? sdy_reg[SE] :
                route_grant[SW][i]      ? sdy_reg[SW] : 0;

            assign intf_out[i].valid = ~intf_out[i].ready ? 0 :
                route_grant[NORTH][i] ? 1 :
                route_grant[EAST][i] ? 1 :
                route_grant[SOUTH][i] ? 1 :
                route_grant[WEST][i] ? 1 :
                route_grant[LOCAL][i] ? 1 :
                route_grant[NE][i] ? 1 :
                route_grant[NW][i] ? 1 :
                route_grant[SE][i] ? 1 :
                route_grant[SW][i] ? 1 : 0;

        end
    endgenerate

endmodule
