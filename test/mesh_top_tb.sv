// -----------------------------------------------------------------------
// Testbench for mesh_top module
// The version of the NoC WITH diagonals
// -----------------------------------------------------------------------

`timescale 1ns/1ps
import global_params::*;

// --------------------------- Testbench Entity ---------------------------
module mesh_top_tb;
    // INPUTS
    logic clk;
    logic rst;
    // Ports
    logic in_sdx [MESH_SIDE][MESH_SIDE][NORTH:SW];
    logic in_sdy [MESH_SIDE][MESH_SIDE][NORTH:SW];
    logic [$clog2(MESH_SIDE)-1:0] in_dx [MESH_SIDE][MESH_SIDE][NORTH:SW];
    logic [$clog2(MESH_SIDE)-1:0] in_dy [MESH_SIDE][MESH_SIDE][NORTH:SW];
    logic [DATA_WIDTH-1:0] in_data [MESH_SIDE][MESH_SIDE][NORTH:SW];
    logic in_valid [MESH_SIDE][MESH_SIDE][NORTH:SW];
    logic in_ready [MESH_SIDE][MESH_SIDE][NORTH:SW];

    // OUTPUTS
    // Ports
    logic out_sdx [MESH_SIDE][MESH_SIDE][NORTH:SW];
    logic out_sdy [MESH_SIDE][MESH_SIDE][NORTH:SW];
    logic [$clog2(MESH_SIDE)-1:0] out_dx [MESH_SIDE][MESH_SIDE][NORTH:SW];
    logic [$clog2(MESH_SIDE)-1:0] out_dy [MESH_SIDE][MESH_SIDE][NORTH:SW];
    logic [DATA_WIDTH-1:0] out_data [MESH_SIDE][MESH_SIDE][NORTH:SW];
    logic out_valid [MESH_SIDE][MESH_SIDE][NORTH:SW];
    logic out_ready [MESH_SIDE][MESH_SIDE][NORTH:SW];

    // INTERFACES
    router_if intf_in[MESH_SIDE][MESH_SIDE][NORTH:SW](); // Input interface for each router
    router_if intf_out[MESH_SIDE][MESH_SIDE][NORTH:SW](); // Output interface for each router

    // OTHER VARIABLES
    int file;
    string str;
    // Time stamp data
    logic [3:0] tmpdat_i, tmpdat_j;

// --------------------------- Module Instance ---------------------------
    mesh_top mesh_top_inst (
        .r_in(intf_in),
        .r_out(intf_out),
        .clk(clk),
        .rst(rst)
    );
// ----------------------------- Connections -----------------------------
    // Ports to router interfaces (array of interfaces canont be used in initial -> for loop)
    generate
        for(genvar i = 0; i<MESH_SIDE;i++) begin: g_lconx
            for( genvar j = 0; j < MESH_SIDE; j++) begin: g_lcony
                for(genvar k = NORTH; k<= SW; k++) begin: g_port
                    assign intf_in[i][j][k].s_delta_x = in_sdx[i][j][k];
                    assign intf_in[i][j][k].s_delta_y = in_sdy[i][j][k];
                    assign intf_in[i][j][k].dest_x    = in_dx[i][j][k];
                    assign intf_in[i][j][k].dest_y    = in_dy[i][j][k];
                    assign intf_in[i][j][k].data      = in_data[i][j][k];
                    assign intf_in[i][j][k].valid     = in_valid[i][j][k];
                    assign in_ready[i][j][k]          = intf_in[i][j][k].ready; // Note direction

                    assign out_sdx[i][j][k]        = intf_out[i][j][k].s_delta_x;
                    assign out_sdy[i][j][k]        = intf_out[i][j][k].s_delta_y;
                    assign out_dx[i][j][k]         = intf_out[i][j][k].dest_x;
                    assign out_dy[i][j][k]         = intf_out[i][j][k].dest_y;
                    assign out_data[i][j][k]       = intf_out[i][j][k].data;
                    assign out_valid[i][j][k]      = intf_out[i][j][k].valid;
                    assign intf_out[i][j][k].ready = out_ready[i][j][k]; // Note direction
                end
            end
        end
    endgenerate

// ------------------------------ Testbench ------------------------------
    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Open file for writing (full path needed for Vivado)
        file = $fopen("/home/andreas/Bachelor/low_latency_NoC/ascii_files/mesh_top_tb.txt", "w+");
        $fwrite(file, "Testbench for mesh_top module\n");

        // Reset and set all inputs to initial values
        clk = 0;
        rst = 1;
        // Loop through all router and set all inputs to 0
        for(int i = 0; i < MESH_SIDE; i++) begin // Loop routers (x)
            for(int j = 0; j < MESH_SIDE; j++) begin // (y)
                for(int k=NORTH;k<=SW; k++)begin // Loop ports
                    in_sdx[i][j][k]   = 0;
                    in_sdy[i][j][k]   = 0;
                    in_dx[i][j][k]    = 0;
                    in_dy[i][j][k]    = 0;
                    in_data[i][j][k]  = 0;
                    in_valid[i][j][k] = 0;
                end
            end
        end

        // Clear reset, valid, and set ready
        # 30
        rst = 0;

        for(int i = 0; i < MESH_SIDE; i++) begin // Loop routers (x)
            for(int j = 0; j < MESH_SIDE; j++) begin // (y)
                for(int k = NORTH; k <= SW; k++) begin // Loop ports
                    out_ready[i][j][k] = 1; // Note the ready is for the outputs
                    in_valid[i][j][k] = 0;
                end
            end
        end

        // Run simulation and finish
        #2000
        $fclose(file);
        $finish;

    end

    // Handle inputs for each router
    // (Injection of packets into the network)
    always @(posedge clk) begin
        for(int i = 0; i < MESH_SIDE; i++) begin // Loop routers (x)
            for(int j = 0; j < MESH_SIDE; j++) begin // (y)

                tmpdat_i = i[3:0]; // convert int to 4 bit logic for data stamp
                tmpdat_j = j[3:0];

                // If ready and adjust probability of injection
                if(in_ready[i][j][LOCAL] && ($urandom_range(100)<=TB_I_PERCENT)) begin
                    in_valid[i][j][LOCAL] = 1;
                    in_data[i][j][LOCAL]  = {tmpdat_i,tmpdat_j,$stime}; // Cat coords and timestamp
                    in_dx[i][j][LOCAL]    = $urandom_range(3);
                    in_dy[i][j][LOCAL]    = $urandom_range(3);
                    in_sdx[i][j][LOCAL]   = in_dx[i][j][LOCAL] < 1 ? 1 : 0;
                    in_sdy[i][j][LOCAL]   = in_dy[i][j][LOCAL] < 1 ? 1 : 0;
                end else begin
                    in_valid[i][j][LOCAL] = 0;
                end
            end
        end
    end

    // Write outputs to file
    always @(posedge clk) begin
        str = ""; // Clear str

        for(int i = 0; i < MESH_SIDE; i++) begin // Loop routers (x)
            for(int j = 0; j < MESH_SIDE; j++) begin // (y)
                if(out_valid[i][j][LOCAL]) begin
                    str = $sformatf("%sOutput[%0d][%0d]: Dx:%0d Dy:%0d sDx:%0d sDy:%0d Data:%h\n",
                        str, i, j,
                        out_dx[i][j][LOCAL],
                        out_dy[i][j][LOCAL],
                        out_sdx[i][j][LOCAL],
                        out_sdy[i][j][LOCAL],
                        out_data[i][j][LOCAL]
                    ); // %0d = remove leading zeros (formatted as space)
                end
            end
        end
        $fwrite(file, "Time:%d\n%s\n",$stime, str); // leave time 0-padded

    end

endmodule

// LEGACY CODE
/*
always @(posedge clk) begin
        if(in_ready[1][1][LOCAL]) begin // for now just local port of middle router (1,1)
            in_valid[1][1][LOCAL] = 1;
            in_data[1][1][LOCAL]  = {4'b0001,4'b0001,$stime};//{128{4'h1}};
            in_dx[1][1][LOCAL]    = $urandom_range(3);
            in_dy[1][1][LOCAL]    = $urandom_range(3);
            in_sdx[1][1][LOCAL]   = in_dx[1][1][LOCAL] < 1 ? 1 : 0;
            in_sdy[1][1][LOCAL]   = in_dy[1][1][LOCAL] < 1 ? 1 : 0;
        end else begin
            in_valid[1][1][LOCAL] = 0;
        end
    end
*/
