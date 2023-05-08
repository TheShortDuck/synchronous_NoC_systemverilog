// -----------------------------------------------------------------------
// Mesh Top X Y module
// This is the top level module for the NoC without diagonals.
// -----------------------------------------------------------------------
import global_params::*;

// --------------------------- Mesh Top Entity ---------------------------
module mesh_top_x_y (
    router_if.in_p r_in[MESH_SIDE][MESH_SIDE][NORTH:LOCAL], // Input IF
    router_if.out_p r_out[MESH_SIDE][MESH_SIDE][NORTH:LOCAL], // Output IF
    input logic clk,
    input logic rst
);

    // --------------------------- Module Instances --------------------------
    // Generate routers scaling with MESH_SIDE for X and Y
    // Bottom left corner: (0,0) Top right: (MESH_SIDE-1, MESH_SIDE-1)
    generate
        for (genvar i = 0; i < MESH_SIDE; i++) begin: g_rx
            for (genvar j = 0; j < MESH_SIDE; j++) begin: g_ry
                router_x_y #(
                    .X_COORD(i),
                    .Y_COORD(j)
                ) router_x_y_inst (
                    .clk(clk),
                    .rst(rst),
                    .intf_in(r_in[i][j]),
                    .intf_out(r_out[i][j])
                );
            end
        end
    endgenerate

    // ----------------------------- Connections -----------------------------
    // Connect output of a router to the input of adjacent router. (opposite side)
    // Signals connnected individually because of the way interfaces are described by the SV standard.
    generate
        for (genvar i = 0; i < MESH_SIDE; i++) begin: g_rconx
            for (genvar j = 0; j < MESH_SIDE; j++) begin: g_rcony
                // Assign North in to South out (if not on top edge)
                if(j != MESH_SIDE-1) begin: g_north
                    assign r_in[i][j][NORTH].s_delta_x = r_out[i][j+1][SOUTH].s_delta_x;
                    assign r_in[i][j][NORTH].s_delta_y = r_out[i][j+1][SOUTH].s_delta_y;
                    assign r_in[i][j][NORTH].dest_x = r_out[i][j+1][SOUTH].dest_x;
                    assign r_in[i][j][NORTH].dest_y = r_out[i][j+1][SOUTH].dest_y;
                    assign r_in[i][j][NORTH].data = r_out[i][j+1][SOUTH].data;
                    assign r_in[i][j][NORTH].valid = r_out[i][j+1][SOUTH].valid;
                    assign r_in[i][j][NORTH].ready = r_out[i][j+1][SOUTH].ready;
                end

                // Assign South in to North out (if not on bottom edge)
                if(j != 0) begin: g_south
                    assign r_in[i][j][SOUTH].s_delta_x = r_out[i][j-1][NORTH].s_delta_x;
                    assign r_in[i][j][SOUTH].s_delta_y = r_out[i][j-1][NORTH].s_delta_y;
                    assign r_in[i][j][SOUTH].dest_x = r_out[i][j-1][NORTH].dest_x;
                    assign r_in[i][j][SOUTH].dest_y = r_out[i][j-1][NORTH].dest_y;
                    assign r_in[i][j][SOUTH].data = r_out[i][j-1][NORTH].data;
                    assign r_in[i][j][SOUTH].valid = r_out[i][j-1][NORTH].valid;
                    assign r_in[i][j][SOUTH].ready = r_out[i][j-1][NORTH].ready;
                end

                // Assign East in to West out (if not on right edge)
                if(i != MESH_SIDE-1) begin: g_east
                    assign r_in[i][j][EAST].s_delta_x = r_out[i+1][j][WEST].s_delta_x;
                    assign r_in[i][j][EAST].s_delta_y = r_out[i+1][j][WEST].s_delta_y;
                    assign r_in[i][j][EAST].dest_x = r_out[i+1][j][WEST].dest_x;
                    assign r_in[i][j][EAST].dest_y = r_out[i+1][j][WEST].dest_y;
                    assign r_in[i][j][EAST].data = r_out[i+1][j][WEST].data;
                    assign r_in[i][j][EAST].valid = r_out[i+1][j][WEST].valid;
                    assign r_in[i][j][EAST].ready = r_out[i+1][j][WEST].ready;
                end

                // Assign West in to East out (if not on left edge)
                if(i != 0) begin: g_west
                    assign r_in[i][j][WEST].s_delta_x = r_out[i-1][j][EAST].s_delta_x;
                    assign r_in[i][j][WEST].s_delta_y = r_out[i-1][j][EAST].s_delta_y;
                    assign r_in[i][j][WEST].dest_x = r_out[i-1][j][EAST].dest_x;
                    assign r_in[i][j][WEST].dest_y = r_out[i-1][j][EAST].dest_y;
                    assign r_in[i][j][WEST].data = r_out[i-1][j][EAST].data;
                    assign r_in[i][j][WEST].valid = r_out[i-1][j][EAST].valid;
                    assign r_in[i][j][WEST].ready = r_out[i-1][j][EAST].ready;
                end

            end
        end
    endgenerate

endmodule
