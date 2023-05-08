// -----------------------------------------------------------------------
// Routing block testbench
// This testbench is for the NoC WITH diagonals
// -----------------------------------------------------------------------
import global_params::*;

// --------------------------- Testbench Entity ---------------------------
module r_block_tb;
    // Coordinates of the block
    localparam integer X_COORD = 1;
    localparam integer Y_COORD = 1;

    // Inputs
    logic [$clog2(MESH_SIDE)-1:0] dx,dy;
    logic sdx, sdy;
    logic valid;
    // Outputs
    logic [8:0] out;

// --------------------------- Module Instance ---------------------------
    r_block #(
        .X_COORD(X_COORD),
        .Y_COORD(Y_COORD)
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
        .route_local(out[4]),
        .route_ne(out[5]),
        .route_nw(out[6]),
        .route_se(out[7]),
        .route_sw(out[8])
    );

// ------------------------------ Testbench ------------------------------
    initial begin
        $display("########## Starting test ##########");
        $display("Routing from (1,1) - on a 3x3 grid");

        for(int k = 1; k>=0; k--) begin
            valid = k;

            if (!k) $display("\nDisabling valid");

            for(int i = 0; i<3;i++) begin
                for(int j = 0; j<3; j++) begin
                    dx = 2'(i);
                    dy = 2'(j);
                    sdx = (i < X_COORD) ? 1 : 0;
                    sdy = (j < Y_COORD) ? 1 : 0;
                    $monitor("dx:%b dy:%b sdx:%b sdy:%b    N:%b  E:%b  S:%b  W:%b  L:%b  NE:%b  NW:%b  SE:%b  SW:%b",
                        dx,dy,sdx,sdy,out[0],out[1],out[2],out[3],out[4],out[5],out[6],out[7],out[8]);
                    #10;
                end
            end
        end

        #10
        $display("########## Test complete ##########");
        $finish;

    end

endmodule
