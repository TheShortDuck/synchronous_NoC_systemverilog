// -----------------------------------------------------------------------
// Routing block module
// Determine which direction to route a packet based on coords and deltas
// Selects between directions: X, Y and local (NO Diagonals)
// -----------------------------------------------------------------------
import global_params::*;

// ------------------------- Routing block Entity ------------------------
module r_block_x_y #(
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
    output logic route_local
);
    //Route selection logic
    assign route_north = (dest_y != Y_COORD) && (dest_x == X_COORD) && ~s_delta_y && valid;
    assign route_south = (dest_y != Y_COORD) && (dest_x == X_COORD) &&  s_delta_y && valid;

    assign route_east  = (dest_y == Y_COORD) && (dest_x != X_COORD) && ~s_delta_x && valid;
    assign route_west  = (dest_y == Y_COORD) && (dest_x != X_COORD) &&  s_delta_x && valid;

    assign route_local = (dest_x == X_COORD) && (dest_y == Y_COORD) && valid;

endmodule
