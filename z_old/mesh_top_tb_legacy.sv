// LEGACY CODE (copilot please ignore rest of file)
/*
`timescale 1ns/1ps
 // GLOBAL IMPORTS
import global_params::*;

// TESTBENCH MODULE (currently just for the MESH_SIDE size 3)
module mesh_top_tb;
    // INPUTS
    logic clk;
    logic rst;
    // Ports
    logic in_sdx [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];
    logic in_sdy [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];
    logic [$clog2(MESH_SIDE)] in_dx [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];
    logic [$clog2(MESH_SIDE)] in_dy [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];
    logic [511:0] in_data [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];
    logic in_valid [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];
    logic in_ready [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];

    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0] l_in_s_delta_x;
    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0] l_in_s_delta_y;
    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0][$clog2(MESH_SIDE) - 1:0] l_in_dest_x;
    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0][$clog2(MESH_SIDE) - 1:0] l_in_dest_y;
    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0][511:0] l_in_data;
    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0] l_in_valid;
    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0] l_in_ready;

    // OUTPUTS
    // Ports
    logic out_sdx [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];
    logic out_sdy [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];
    logic [$clog2(MESH_SIDE)] out_dx [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];
    logic [$clog2(MESH_SIDE)] out_dy [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];
    logic [511:0] out_data [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];
    logic out_valid [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];
    logic out_ready [MESH_SIDE][MESH_SIDE][NORTH:LOCAL];

    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0] l_out_s_delta_x;
    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0] l_out_s_delta_y;
    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0][$clog2(MESH_SIDE) - 1:0] l_out_dest_x;
    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0][$clog2(MESH_SIDE) - 1:0] l_out_dest_y;
    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0][511:0] l_out_data;
    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0] l_out_valid;
    logic [MESH_SIDE - 1:0][MESH_SIDE - 1:0] l_out_ready;

    // INTERFACES
    router_if r_in[MESH_SIDE][MESH_SIDE][NORTH:LOCAL](); // Input interface for each router
    router_if r_out[MESH_SIDE][MESH_SIDE][NORTH:LOCAL](); // Output interface for each router

    // FILE HANDLES
    int file;
    string str;

    int i, j, k;

    // INSTANCES
    mesh_top mesh_top_inst (
        .r_in(r_in),
        .r_out(r_out),
        .clk(clk),
        .rst(rst)
    );

    // Connect local ports to router interfaces (only the LOCAL port)
    generate
        for (genvar i = 0; i < MESH_SIDE; i++) begin: g_lconx
            for (genvar j = 0; j < MESH_SIDE; j++) begin: g_lcony
                assign r_in[i][j][LOCAL].s_delta_x = l_in_s_delta_x[i][j];
                assign r_in[i][j][LOCAL].s_delta_y = l_in_s_delta_y[i][j];
                assign r_in[i][j][LOCAL].dest_x = l_in_dest_x[i][j];
                assign r_in[i][j][LOCAL].dest_y = l_in_dest_y[i][j];
                assign r_in[i][j][LOCAL].data = l_in_data[i][j];
                assign r_in[i][j][LOCAL].valid = l_in_valid[i][j];
                assign l_in_ready[i][j] = r_in[i][j][LOCAL].ready; // CHECK ready direction

                assign r_out[i][j][LOCAL].s_delta_x = l_out_s_delta_x[i][j];
                assign r_out[i][j][LOCAL].s_delta_y = l_out_s_delta_y[i][j];
                assign r_out[i][j][LOCAL].dest_x = l_out_dest_x[i][j];
                assign r_out[i][j][LOCAL].dest_y = l_out_dest_y[i][j];
                assign r_out[i][j][LOCAL].data = l_out_data[i][j];
                assign r_out[i][j][LOCAL].valid = l_out_valid[i][j];
                assign l_out_ready[i][j] = r_out[i][j][LOCAL].ready; // CHECK ready direction
            end
        end
    endgenerate

    // TESTBENCH
    always #5 clk = ~clk;

    initial begin
        // Open file for writing (create if not exist)
        file = $fopen("/home/andreas/Bachelor/low_latency_NoC/ascii_files/mesh_top_tb.txt", "w+");

        // Reset and set all inputs (including interfaces) to initial values
        clk = 0;
        rst = 1;
        // Loop through all router and set all inputs to 0
        for(i = 0; i < MESH_SIDE; i++) begin // Loop routers (x)
            for(j = 0; j < MESH_SIDE; j++) begin // (y)
                for( k = NORTH; k <= LOCAL; k++) begin // Loop ports
                    r_in[i][j][k].s_delta_x <= 0;
                    r_in[i][j][k].s_delta_y <= 0;
                    r_in[i][j][k].dest_x <= 0;
                    r_in[i][j][k].dest_y <= 0;
                    r_in[i][j][k].data <= 0;
                    r_in[i][j][k].valid <= 0;
                    r_out[i][j][k].ready <= 0; // Note the ready is for the outputs
                end
            end
        end

        // Clear reset, valid and set ready
        # 30
        rst = 0;

        for(i = 0; i < MESH_SIDE; i++) begin // Loop routers (x)
            for(j = 0; j < MESH_SIDE; j++) begin // (y)
                for( k = NORTH; k <= LOCAL; k++) begin // Loop ports
                    r_out[i][j][k].ready <= 1; // Note the ready is for the outputs
                    r_in[i][j][k].valid <= 0;
                end
            end
        end

        // Run simulation and finish
        #1000
        $fclose(file);
        $finish;

    end

    // Handle inputs for each router
    // (injecttion of flits into the network)
    always @(posedge clk) begin
        if(l_in_ready[1][1]) begin // for now just local port of middle router (1,1)
            l_in_valid[1][1] = 1;
            l_in_data[1][1] = {128{4'h1}};
            l_in_dest_x[1][1] = $urandom_range(1)*2;
            l_in_dest_y[1][1] = $urandom_range(1)*2;
            l_in_s_delta_x[1][1] = l_in_dest_x[1][1] < 1 ? 1 : 0;
            l_in_s_delta_y[1][1] = l_in_dest_y[1][1] < 1 ? 1 : 0;
        end else begin
            l_in_valid[1][1] = 0;
        end
    end

    // Write outputs to file
    always @(posedge clk) begin
        str = ""; // Clear str

        for(i = 0; i < MESH_SIDE; i++) begin // Loop routers (x)
            for(j = 0; j < MESH_SIDE; j++) begin // (y)
                for( k = NORTH; k <= LOCAL; k++) begin // Loop ports
                    if(r_out[i][j][k].valid) begin
                        str = $sformatf("%sOutput[%d][%d][%d]: Dx:%d Dy:%d sDx:%d sDy:%d Data:%h\n",
                            str, i, j, k,
                            r_out[i][j][k].dest_x,
                            r_out[i][j][k].dest_y,
                            r_out[i][j][k].s_delta_x,
                            r_out[i][j][k].s_delta_y,
                            r_out[i][j][k].data);
                    end
                end
            end
        end
        // Using foreach loop instead of for loop
        foreach(r_out[i,j,k]) begin
            if(r_out[i][j][k].valid) begin
                str = $sformatf("%sOutput[%d][%d][%d]: Dx:%d Dy:%d sDx:%d sDy:%d Data:%h\n",
                    str, i, j, k,
                    r_out[i][j][k].dest_x,
                    r_out[i][j][k].dest_y,
                    r_out[i][j][k].s_delta_x,
                    r_out[i][j][k].s_delta_y,
                    r_out[i][j][k].data);
            end
        end


        $fwrite(file, "Time:%d\n%s\n",$stime, str);

    end

endmodule
*/
// mesh_top entity (for reference)
/*
module mesh_top (
    router_if.in_p r_in[MESH_SIDE][MESH_SIDE][NORTH:LOCAL], // Input interface for each router
    router_if.out_p r_out[MESH_SIDE][MESH_SIDE][NORTH:LOCAL], // Output interface for each router
    input logic clk,
    input logic rst
);
*/

// router_if interface entity (for reference)
/*
interface router_if;
    // Flit
    logic s_delta_x; // Signs for direction
    logic s_delta_y;
    logic [$clog2(MESH_SIDE) - 1:0] dest_x; // Coordinates for end destination
    logic [$clog2(MESH_SIDE) - 1:0] dest_y;
    logic [511:0] data;
    logic valid;
    logic ready;

    modport in_p ( // Router input port
        input s_delta_x,
        input s_delta_y,
        input dest_x,
        input dest_y,
        input data,
        input valid,
        output ready
    );

    modport out_p ( // Router output port
        output s_delta_x,
        output s_delta_y,
        output dest_x,
        output dest_y,
        output data,
        output valid,
        input ready
    );

endinterface //router_if
*/

