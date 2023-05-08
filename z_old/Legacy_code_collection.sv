// Inserting ccode from file into listing in latex
/*
% Insert listing global_params.sv directly from the file with the lstinputlisting command
% LISTING: global_params.sv
\lstinputlisting[language=Verilog, caption={The \textit{global\_params.sv} file}, label={lst:global_params}]{../if/global_params.sv}
*/


// ------------------------------------------------------------
// FROM mesh_top
// ------------------------------------------------------------
// LEGACY CODE (copilot ignore rest of file)
/*
generate THIS WILL NOT WORK BECAUSE OF THE WAY SYSTEMVERILOG DEFINES INTERFACES
    for (genvar i = 0; i < MESH_SIDE; i++) begin: g_rconx
        for (genvar j = 0; j < MESH_SIDE; j++) begin: g_rcony
            // Assign North in to South out (if not on top edge)
            if (i != MESH_SIDE - 1) assign r_in[i][j][NORTH] = r_out[i + 1][j][SOUTH];
            // Assign South in to North out (if not on bottom edge)
            if (i != 0) assign r_in[i][j][SOUTH] = r_out[i - 1][j][NORTH];
            // Assign East in to West out (if not on right edge)
            if (j != MESH_SIDE - 1) assign r_in[i][j][EAST] = r_out[i][j + 1][WEST];
            // Assign West in to East out (if not on left edge)
            if (j != 0) assign r_in[i][j][WEST] = r_out[i][j - 1][EAST];
        end
    end
endgenerate*/

// FROM mesh_top_x_y
// LEGACY CODE (copilot ignore rest of file)
/*
generate THIS WILL NOT WORK BECAUSE OF THE WAY SYSTEMVERILOG DEFINES INTERFACES
    for (genvar i = 0; i < MESH_SIDE; i++) begin: g_rconx
        for (genvar j = 0; j < MESH_SIDE; j++) begin: g_rcony
            // Assign North in to South out (if not on top edge)
            if (i != MESH_SIDE - 1) assign r_in[i][j][NORTH] = r_out[i + 1][j][SOUTH];
            // Assign South in to North out (if not on bottom edge)
            if (i != 0) assign r_in[i][j][SOUTH] = r_out[i - 1][j][NORTH];
            // Assign East in to West out (if not on right edge)
            if (j != MESH_SIDE - 1) assign r_in[i][j][EAST] = r_out[i][j + 1][WEST];
            // Assign West in to East out (if not on left edge)
            if (j != 0) assign r_in[i][j][WEST] = r_out[i][j - 1][EAST];
        end
    end
endgenerate*/



