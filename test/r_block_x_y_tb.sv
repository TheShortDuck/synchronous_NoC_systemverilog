// -----------------------------------------------------------------------
// Routing block X Y testbench
// This testbench is for the NoC WITHOUT diagonals
// -----------------------------------------------------------------------
import global_params::*;

// --------------------------- Testbench Entity ---------------------------
module r_block_x_y_tb;
    // Coordinates of the block
    localparam integer X_COORD = 1;
    localparam integer Y_COORD = 1;

    // Inputs
    logic [$clog2(MESH_SIDE)-1:0] dx,dy;
    logic sdx, sdy;
    logic valid;
    // Outputs
    logic [4:0] out;

// --------------------------- Module Instance ---------------------------
    r_block #(
        .X_COORD(X_COORD),
        .Y_COORD(Y_COORD),
        .MESH_SIDE(MESH_SIDE)
    ) r_block_inst (
        .dest_x(dx),
        .dest_y(dy),
        .s_delta_x(sdx),
        .s_delta_y(sdy),
        .valid(valid),
        .route_north(out[0]),
        .route_east(out[1]),
        .route_south(out[2]),
        .route_west(out[3]),
        .route_local(out[4])
    );

// ------------------------------ Testbench ------------------------------
    initial begin
        $display("########## Starting test ##########");
        $display("Routing from (1,1) - on a 3x3 grid");
        $display("Demonstrating x first");
        valid = 1;
        for(int i = 0; i<3;i++) begin
            dx = 2'(i);
            dy = 2'(i);
            sdx = (i < X_COORD) ? 1 : 0;
            sdy = (i < Y_COORD) ? 1 : 0;
            $monitor("dx: %b\tdy: %b\tsdx: %b\tsdy: %b\tN: %b\tE: %b\tS: %b\tW: %b\tLocal: %b",
                dx,dy,sdx,sdy,out[0],out[1],out[2],out[3],out[4]);
            #10;
        end

        $display("\nRouting along y");
        for(int i = 0; i<3;i++) begin
            dx = 2'd1;
            dy = 2'(i);
            sdx = 0;
            sdy = (i < Y_COORD) ? 1 : 0;
            $monitor("dx: %b\tdy: %b\tsdx: %b\tsdy: %b\tN: %b\tE: %b\tS: %b\tW: %b\tLocal: %b",
                dx,dy,sdx,sdy,out[0],out[1],out[2],out[3],out[4]);
            #10;
        end

        $display("\nDisabling valid");
        valid = 0;
        for(int i = 0; i<3;i++) begin
            dx = 2'(i);
            dy = 2'(i);
            sdx = (i < X_COORD) ? 1 : 0;
            sdy = (i < Y_COORD) ? 1 : 0;
            $monitor("dx: %b\tdy: %b\tsdx: %b\tsdy: %b\tN: %b\tE: %b\tS: %b\tW: %b\tLocal: %b",
                dx,dy,sdx,sdy,out[0],out[1],out[2],out[3],out[4]);
            #10;
        end

    end

endmodule

