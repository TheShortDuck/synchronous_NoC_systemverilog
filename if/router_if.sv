import global_params::*;

interface router_if;
    logic s_delta_x; // Signed delta x and y
    logic s_delta_y;
    logic [$clog2(MESH_SIDE) - 1:0] dest_x; // Coordinates for destination
    logic [$clog2(MESH_SIDE) - 1:0] dest_y; // (Scale with MESH_SIDE)
    logic [DATA_WIDTH-1:0] data; // Data of the Packet
    logic valid; // Handskake signals
    logic ready;

    modport in_p ( // Tie router interface as input port
        input s_delta_x,
        input s_delta_y,
        input dest_x,
        input dest_y,
        input data,
        input valid,
        output ready
    );

    modport out_p ( // Tie router interface as output port
        output s_delta_x,
        output s_delta_y,
        output dest_x,
        output dest_y,
        output data,
        output valid,
        input ready
    );

endinterface //router_if
