// -----------------------------------------------------------------------
// Mesh Top module
// This is the top level module for the NoC.
// -----------------------------------------------------------------------
import global_params::*;

// --------------------------- Mesh Top Entity ---------------------------
module mesh_top (
    router_if.in_p local_in[MESH_SIDE][MESH_SIDE], // Input IF
    router_if.out_p local_out[MESH_SIDE][MESH_SIDE], // Output IF
    input logic clk,
    input logic rst
);

    router_if r_in[MESH_SIDE][MESH_SIDE][NORTH:SW](); // Input IF
    router_if r_out[MESH_SIDE][MESH_SIDE][NORTH:SW](); // Output IF

    generate
        for (genvar i = 0; i < MESH_SIDE; i++) begin
            for (genvar j = 0; j < MESH_SIDE; j++) begin
                assign r_in[i][j][LOCAL].s_delta_x = local_in[i][j].s_delta_x;
                assign r_in[i][j][LOCAL].s_delta_y = local_in[i][j].s_delta_y;
                assign r_in[i][j][LOCAL].dest_x    = local_in[i][j].dest_x;
                assign r_in[i][j][LOCAL].dest_y    = local_in[i][j].dest_y;
                assign r_in[i][j][LOCAL].data      = local_in[i][j].data;
                assign r_in[i][j][LOCAL].valid     = local_in[i][j].valid;
                assign local_in[i][j].ready = r_in[i][j][LOCAL].ready;

                assign local_out[i][j].s_delta_x = r_out[i][j][LOCAL].s_delta_x;
                assign local_out[i][j].s_delta_y = r_out[i][j][LOCAL].s_delta_y;
                assign local_out[i][j].dest_x    = r_out[i][j][LOCAL].dest_x;
                assign local_out[i][j].dest_y    = r_out[i][j][LOCAL].dest_y;
                assign local_out[i][j].data      = r_out[i][j][LOCAL].data;
                assign local_out[i][j].valid     = r_out[i][j][LOCAL].valid;
                assign r_out[i][j][LOCAL].ready = local_out[i][j].ready;
            end
        end
    endgenerate

// --------------------------- Module Instances --------------------------
    // Generate routers scaling with MESH_SIDE for X and Y
    // Bottom left corner: (0,0) Top right: (MESH_SIDE-1, MESH_SIDE-1)
    generate
        for (genvar i = 0; i < MESH_SIDE; i++) begin: g_rx
            for (genvar j = 0; j < MESH_SIDE; j++) begin: g_ry
                router #(
                    .X_COORD(i),
                    .Y_COORD(j)
                ) router_inst (
                    .clk(clk),
                    .rst(rst),
                    .intf_in(r_in[i][j]),
                    .intf_out(r_out[i][j])
                );
            end
        end
    endgenerate

// ----------------------------- Connections -----------------------------
    // Connect output of a router to the input of adjacent router. (opposite edge/corner)
    // Signals connnected individually because of the way interfaces are described by the SV standard.
    generate
        for (genvar i = 0; i < MESH_SIDE; i++) begin: g_rconx
            for (genvar j = 0; j < MESH_SIDE; j++) begin: g_rcony
                // Assign North in to South out (if not on top edge)
                if(j != MESH_SIDE-1) begin: g_north
                    assign r_in[i][j][NORTH].s_delta_x = r_out[i][j+1][SOUTH].s_delta_x;
                    assign r_in[i][j][NORTH].s_delta_y = r_out[i][j+1][SOUTH].s_delta_y;
                    assign r_in[i][j][NORTH].dest_x    = r_out[i][j+1][SOUTH].dest_x;
                    assign r_in[i][j][NORTH].dest_y    = r_out[i][j+1][SOUTH].dest_y;
                    assign r_in[i][j][NORTH].data      = r_out[i][j+1][SOUTH].data;
                    assign r_in[i][j][NORTH].valid     = r_out[i][j+1][SOUTH].valid;
                    assign r_in[i][j][NORTH].ready     = r_out[i][j+1][SOUTH].ready;
                end

                // Assign South in to North out (if not on bottom edge)
                if(j != 0) begin: g_south
                    assign r_in[i][j][SOUTH].s_delta_x = r_out[i][j-1][NORTH].s_delta_x;
                    assign r_in[i][j][SOUTH].s_delta_y = r_out[i][j-1][NORTH].s_delta_y;
                    assign r_in[i][j][SOUTH].dest_x    = r_out[i][j-1][NORTH].dest_x;
                    assign r_in[i][j][SOUTH].dest_y    = r_out[i][j-1][NORTH].dest_y;
                    assign r_in[i][j][SOUTH].data      = r_out[i][j-1][NORTH].data;
                    assign r_in[i][j][SOUTH].valid     = r_out[i][j-1][NORTH].valid;
                    assign r_in[i][j][SOUTH].ready     = r_out[i][j-1][NORTH].ready;
                end

                // Assign East in to West out (if not on right edge)
                if(i != MESH_SIDE-1) begin: g_east
                    assign r_in[i][j][EAST].s_delta_x = r_out[i+1][j][WEST].s_delta_x;
                    assign r_in[i][j][EAST].s_delta_y = r_out[i+1][j][WEST].s_delta_y;
                    assign r_in[i][j][EAST].dest_x    = r_out[i+1][j][WEST].dest_x;
                    assign r_in[i][j][EAST].dest_y    = r_out[i+1][j][WEST].dest_y;
                    assign r_in[i][j][EAST].data      = r_out[i+1][j][WEST].data;
                    assign r_in[i][j][EAST].valid     = r_out[i+1][j][WEST].valid;
                    assign r_in[i][j][EAST].ready     = r_out[i+1][j][WEST].ready;
                end

                // Assign West in to East out (if not on left edge)
                if(i != 0) begin: g_west
                    assign r_in[i][j][WEST].s_delta_x = r_out[i-1][j][EAST].s_delta_x;
                    assign r_in[i][j][WEST].s_delta_y = r_out[i-1][j][EAST].s_delta_y;
                    assign r_in[i][j][WEST].dest_x    = r_out[i-1][j][EAST].dest_x;
                    assign r_in[i][j][WEST].dest_y    = r_out[i-1][j][EAST].dest_y;
                    assign r_in[i][j][WEST].data      = r_out[i-1][j][EAST].data;
                    assign r_in[i][j][WEST].valid     = r_out[i-1][j][EAST].valid;
                    assign r_in[i][j][WEST].ready     = r_out[i-1][j][EAST].ready;
                end

                // Assign NE in to SW out (if not on top or right edge)
                if(i != MESH_SIDE-1 && j != MESH_SIDE-1) begin: g_ne
                    assign r_in[i][j][NE].s_delta_x = r_out[i+1][j+1][SW].s_delta_x;
                    assign r_in[i][j][NE].s_delta_y = r_out[i+1][j+1][SW].s_delta_y;
                    assign r_in[i][j][NE].dest_x    = r_out[i+1][j+1][SW].dest_x;
                    assign r_in[i][j][NE].dest_y    = r_out[i+1][j+1][SW].dest_y;
                    assign r_in[i][j][NE].data      = r_out[i+1][j+1][SW].data;
                    assign r_in[i][j][NE].valid     = r_out[i+1][j+1][SW].valid;
                    assign r_in[i][j][NE].ready     = r_out[i+1][j+1][SW].ready;
                end

                // Assign SW in to NE out (if not on bottom or left edge)
                if(i != 0 && j != 0) begin: g_sw
                    assign r_in[i][j][SW].s_delta_x = r_out[i-1][j-1][NE].s_delta_x;
                    assign r_in[i][j][SW].s_delta_y = r_out[i-1][j-1][NE].s_delta_y;
                    assign r_in[i][j][SW].dest_x    = r_out[i-1][j-1][NE].dest_x;
                    assign r_in[i][j][SW].dest_y    = r_out[i-1][j-1][NE].dest_y;
                    assign r_in[i][j][SW].data      = r_out[i-1][j-1][NE].data;
                    assign r_in[i][j][SW].valid     = r_out[i-1][j-1][NE].valid;
                    assign r_in[i][j][SW].ready     = r_out[i-1][j-1][NE].ready;
                end

                // Assign NW in to SE out (if not on top or left edge)
                if(i != 0 && j != MESH_SIDE-1) begin: g_nw
                    assign r_in[i][j][NW].s_delta_x = r_out[i-1][j+1][SE].s_delta_x;
                    assign r_in[i][j][NW].s_delta_y = r_out[i-1][j+1][SE].s_delta_y;
                    assign r_in[i][j][NW].dest_x    = r_out[i-1][j+1][SE].dest_x;
                    assign r_in[i][j][NW].dest_y    = r_out[i-1][j+1][SE].dest_y;
                    assign r_in[i][j][NW].data      = r_out[i-1][j+1][SE].data;
                    assign r_in[i][j][NW].valid     = r_out[i-1][j+1][SE].valid;
                    assign r_in[i][j][NW].ready     = r_out[i-1][j+1][SE].ready;
                end

                // Assign SE in to NW out (if not on bottom or right edge)
                if(i != MESH_SIDE-1 && j != 0) begin: g_se
                    assign r_in[i][j][SE].s_delta_x = r_out[i+1][j-1][NW].s_delta_x;
                    assign r_in[i][j][SE].s_delta_y = r_out[i+1][j-1][NW].s_delta_y;
                    assign r_in[i][j][SE].dest_x    = r_out[i+1][j-1][NW].dest_x;
                    assign r_in[i][j][SE].dest_y    = r_out[i+1][j-1][NW].dest_y;
                    assign r_in[i][j][SE].data      = r_out[i+1][j-1][NW].data;
                    assign r_in[i][j][SE].valid     = r_out[i+1][j-1][NW].valid;
                    assign r_in[i][j][SE].ready     = r_out[i+1][j-1][NW].ready;
                end

            end
        end
    endgenerate

    endmodule
