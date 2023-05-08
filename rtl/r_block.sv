// -----------------------------------------------------------------------
// Routing block module
// Determine which direction to route a packet based on coords and deltas
// Selects between directions: X, Y, diagonals, and local
// -----------------------------------------------------------------------
import global_params::*;

// ------------------------- Routing block Entity ------------------------
module r_block #(
    parameter integer X_COORD = 0,
    parameter integer Y_COORD = 0
) (
    input logic [$clog2(MESH_SIDE) - 1:0] dest_x,
    input logic [$clog2(MESH_SIDE) - 1:0] dest_y,
    input logic s_delta_x,
    input logic s_delta_y,
    input logic valid,
    output logic route_north,
    output logic route_east,
    output logic route_south,
    output logic route_west,
    output logic route_local,
    output logic route_ne,
    output logic route_nw,
    output logic route_se,
    output logic route_sw
);
    // Route selection logic
    assign route_north = (dest_y != Y_COORD) && (dest_x == X_COORD) && ~s_delta_y && valid;
    assign route_south = (dest_y != Y_COORD) && (dest_x == X_COORD) &&  s_delta_y && valid;

    assign route_east  = (dest_y == Y_COORD) && (dest_x != X_COORD) && ~s_delta_x && valid;
    assign route_west  = (dest_y == Y_COORD) && (dest_x != X_COORD) &&  s_delta_x && valid;

    assign route_local = (dest_x == X_COORD) && (dest_y == Y_COORD) && valid;

    assign route_ne = (dest_y != Y_COORD) && (dest_x != X_COORD) && ~s_delta_y && ~s_delta_x && valid;
    assign route_nw = (dest_y != Y_COORD) && (dest_x != X_COORD) && ~s_delta_y &&  s_delta_x && valid;

    assign route_se = (dest_y != Y_COORD) && (dest_x != X_COORD) &&  s_delta_y && ~s_delta_x && valid;
    assign route_sw = (dest_y != Y_COORD) && (dest_x != X_COORD) &&  s_delta_y &&  s_delta_x && valid;

endmodule
