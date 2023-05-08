// -----------------------------------------------------------------------
// Testbench instantiating barebone router configuration
// Two routers (without diagonals connected)
// One act as a source and the other as a destination
// -----------------------------------------------------------------------

`timescale 1ns/1ps
import global_params::*;

// --------------------------- Testbench Entity ---------------------------
module two_router_tb;
    logic clk;
    logic rst;

    // Interfaces
    router_if intf_in[NORTH:LOCAL]();
    router_if intf_out[NORTH:LOCAL]();
    router_if intf_in_2[NORTH:LOCAL]();
    router_if intf_out_2[NORTH:LOCAL]();

    // Router 1
    logic [DATA_WIDTH-1:0] north_data, east_data, south_data, west_data, local_data;
    logic [$clog2(MESH_SIDE)-1:0] north_dest_x, east_dest_x;
    logic [$clog2(MESH_SIDE)-1:0] south_dest_x, west_dest_x, local_dest_x;
    logic [$clog2(MESH_SIDE)-1:0] north_dest_y, east_dest_y;
    logic [$clog2(MESH_SIDE)-1:0] south_dest_y, west_dest_y, local_dest_y;
    logic north_sdx, east_sdx, south_sdx, west_sdx, local_sdx;
    logic north_sdy, east_sdy, south_sdy, west_sdy, local_sdy;
    logic north_valid, east_valid, south_valid, west_valid, local_valid;
    logic [4:0] ready_sigs;

    // Router 2
    logic [DATA_WIDTH-1:0] north_data_2, east_data_2, south_data_2, west_data_2, local_data_2;
    logic [$clog2(MESH_SIDE)-1:0] north_dest_x_2, east_dest_x_2;
    logic [$clog2(MESH_SIDE)-1:0] south_dest_x_2, west_dest_x_2, local_dest_x_2;
    logic [$clog2(MESH_SIDE)-1:0] north_dest_y_2, east_dest_y_2;
    logic [$clog2(MESH_SIDE)-1:0] south_dest_y_2, west_dest_y_2, local_dest_y_2;
    logic north_sdx_2, east_sdx_2, south_sdx_2, west_sdx_2, local_sdx_2;
    logic north_sdy_2, east_sdy_2, south_sdy_2, west_sdy_2, local_sdy_2;
    logic north_valid_2, east_valid_2, south_valid_2, west_valid_2, local_valid_2;


    // File variables
    int file, file_2;
    string str, str_2;

// --------------------------- Module Instances --------------------------
    router_x_y #( // Router for 2d mesh (x and y)
        .X_COORD(1),
        .Y_COORD(1)
    ) router_inst (
        .clk(clk),
        .rst(rst),
        .intf_in(intf_in),
        .intf_out(intf_out)
    );
    router_x_y #( // Second router instance (located to the east)
        .X_COORD(2),
        .Y_COORD(1)
    ) router_inst_2 (
        .clk(clk),
        .rst(rst),
        .intf_in(intf_in_2),
        .intf_out(intf_out_2)
    );

// ----------------------------- Connections -----------------------------
    // Connect routers
    assign intf_in_2[WEST].data = intf_out[EAST].data; // East to West
    assign intf_in_2[WEST].dest_x = intf_out[EAST].dest_x;
    assign intf_in_2[WEST].dest_y = intf_out[EAST].dest_y;
    assign intf_in_2[WEST].s_delta_x = intf_out[EAST].s_delta_x;
    assign intf_in_2[WEST].s_delta_y = intf_out[EAST].s_delta_y;
    assign intf_in_2[WEST].valid = intf_out[EAST].valid;
    assign intf_in_2[WEST].ready = intf_out[EAST].ready;

    // Assign Router 1
    assign north_data = intf_out[NORTH].data;
    assign east_data =  intf_out[EAST].data;
    assign south_data = intf_out[SOUTH].data;
    assign west_data =  intf_out[WEST].data;
    assign local_data = intf_out[LOCAL].data;

    assign north_dest_x = intf_out[NORTH].dest_x;
    assign east_dest_x =  intf_out[EAST].dest_x;
    assign south_dest_x = intf_out[SOUTH].dest_x;
    assign west_dest_x =  intf_out[WEST].dest_x;
    assign local_dest_x = intf_out[LOCAL].dest_x;

    assign north_dest_y = intf_out[NORTH].dest_y;
    assign east_dest_y =  intf_out[EAST].dest_y;
    assign south_dest_y = intf_out[SOUTH].dest_y;
    assign west_dest_y =  intf_out[WEST].dest_y;
    assign local_dest_y = intf_out[LOCAL].dest_y;

    assign north_sdx = intf_out[NORTH].s_delta_x;
    assign east_sdx =  intf_out[EAST].s_delta_x;
    assign south_sdx = intf_out[SOUTH].s_delta_x;
    assign west_sdx =  intf_out[WEST].s_delta_x;
    assign local_sdx = intf_out[LOCAL].s_delta_x;

    assign north_sdy = intf_out[NORTH].s_delta_y;
    assign east_sdy =  intf_out[EAST].s_delta_y;
    assign south_sdy = intf_out[SOUTH].s_delta_y;
    assign west_sdy =  intf_out[WEST].s_delta_y;
    assign local_sdy = intf_out[LOCAL].s_delta_y;

    assign north_valid = intf_out[NORTH].valid;
    assign east_valid =  intf_out[EAST].valid;
    assign south_valid = intf_out[SOUTH].valid;
    assign west_valid =  intf_out[WEST].valid;
    assign local_valid = intf_out[LOCAL].valid;

    // Assign Router 2
    assign north_data_2 = intf_out_2[NORTH].data;
    assign east_data_2 =  intf_out_2[EAST].data;
    assign south_data_2 = intf_out_2[SOUTH].data;
    assign west_data_2 =  intf_out_2[WEST].data;
    assign local_data_2 = intf_out_2[LOCAL].data;

    assign north_dest_x_2 = intf_out_2[NORTH].dest_x;
    assign east_dest_x_2 =  intf_out_2[EAST].dest_x;
    assign south_dest_x_2 = intf_out_2[SOUTH].dest_x;
    assign west_dest_x_2 =  intf_out_2[WEST].dest_x;
    assign local_dest_x_2 = intf_out_2[LOCAL].dest_x;

    assign north_dest_y_2 = intf_out_2[NORTH].dest_y;
    assign east_dest_y_2 =  intf_out_2[EAST].dest_y;
    assign south_dest_y_2 = intf_out_2[SOUTH].dest_y;
    assign west_dest_y_2 =  intf_out_2[WEST].dest_y;
    assign local_dest_y_2 = intf_out_2[LOCAL].dest_y;

    assign north_sdx_2 = intf_out_2[NORTH].s_delta_x;
    assign east_sdx_2 =  intf_out_2[EAST].s_delta_x;
    assign south_sdx_2 = intf_out_2[SOUTH].s_delta_x;
    assign west_sdx_2 =  intf_out_2[WEST].s_delta_x;
    assign local_sdx_2 = intf_out_2[LOCAL].s_delta_x;

    assign north_sdy_2 = intf_out_2[NORTH].s_delta_y;
    assign east_sdy_2 =  intf_out_2[EAST].s_delta_y;
    assign south_sdy_2 = intf_out_2[SOUTH].s_delta_y;
    assign west_sdy_2 =  intf_out_2[WEST].s_delta_y;
    assign local_sdy_2 = intf_out_2[LOCAL].s_delta_y;

    assign north_valid_2 = intf_out_2[NORTH].valid;
    assign east_valid_2 =  intf_out_2[EAST].valid;
    assign south_valid_2 = intf_out_2[SOUTH].valid;
    assign west_valid_2 =  intf_out_2[WEST].valid;
    assign local_valid_2 = intf_out_2[LOCAL].valid;


    assign ready_sigs = {
        intf_in[NORTH].ready,
        intf_in[EAST].ready,
        intf_in[SOUTH].ready,
        intf_in[WEST].ready,
        intf_in[LOCAL].ready
    };

// ------------------------------ Testbench ------------------------------
    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Open file (create if not exist)
        file = $fopen("/home/andreas/Bachelor/low_latency_NoC/ascii_files/two_router_tb.txt", "w+"); // verilog_lint: w
        file_2 = $fopen("/home/andreas/Bachelor/low_latency_NoC/ascii_files/two_router_tb_2.txt", "w+"); // verilog_lint: w

        #1;
        clk = 0;
        rst=1;
        intf_in[NORTH].s_delta_x = 0;
        intf_in[NORTH].s_delta_y = 0;
        intf_in[NORTH].dest_x = 0;
        intf_in[NORTH].dest_y = 0;
        intf_in[NORTH].data = 0;

        intf_in[EAST].s_delta_x = 0;
        intf_in[EAST].s_delta_y = 0;
        intf_in[EAST].dest_x = 0;
        intf_in[EAST].dest_y = 0;
        intf_in[EAST].data = 0;

        intf_in[SOUTH].s_delta_x = 0;
        intf_in[SOUTH].s_delta_y = 0;
        intf_in[SOUTH].dest_x = 0;
        intf_in[SOUTH].dest_y = 0;
        intf_in[SOUTH].data = 0;

        intf_in[WEST].s_delta_x = 0;
        intf_in[WEST].s_delta_y = 0;
        intf_in[WEST].dest_x = 0;
        intf_in[WEST].dest_y = 0;
        intf_in[WEST].data = 0;

        intf_in[LOCAL].s_delta_x = 0;
        intf_in[LOCAL].s_delta_y = 0;
        intf_in[LOCAL].dest_x = 0;
        intf_in[LOCAL].dest_y = 0;
        intf_in[LOCAL].data = 0;

        intf_out[NORTH].ready = 0;
        intf_out[EAST].ready  = 0; // EAST
        intf_out[SOUTH].ready = 0;
        intf_out[WEST].ready  = 0; // WEST
        intf_out[LOCAL].ready = 0;

        intf_in[NORTH].valid = 0;
        intf_in[EAST].valid = 0;
        intf_in[SOUTH].valid = 0;
        intf_in[WEST].valid = 0;
        intf_in[LOCAL].valid = 0;

        // input 2
        intf_in_2[NORTH].s_delta_x = 0;
        intf_in_2[NORTH].s_delta_y = 0;
        intf_in_2[NORTH].dest_x = 0;
        intf_in_2[NORTH].dest_y = 0;
        intf_in_2[NORTH].data = 0;

        intf_in_2[EAST].s_delta_x = 0;
        intf_in_2[EAST].s_delta_y = 0;
        intf_in_2[EAST].dest_x = 0;
        intf_in_2[EAST].dest_y = 0;
        intf_in_2[EAST].data = 0;

        intf_in_2[SOUTH].s_delta_x = 0;
        intf_in_2[SOUTH].s_delta_y = 0;
        intf_in_2[SOUTH].dest_x = 0;
        intf_in_2[SOUTH].dest_y = 0;
        intf_in_2[SOUTH].data = 0;

        intf_in_2[WEST].s_delta_x = 0;
        intf_in_2[WEST].s_delta_y = 0;
        intf_in_2[WEST].dest_x = 0;
        intf_in_2[WEST].dest_y = 0;
        intf_in_2[WEST].data = 0;

        intf_in_2[LOCAL].s_delta_x = 0;
        intf_in_2[LOCAL].s_delta_y = 0;
        intf_in_2[LOCAL].dest_x = 0;
        intf_in_2[LOCAL].dest_y = 0;
        intf_in_2[LOCAL].data = 0;

        intf_out_2[NORTH].ready = 0;
        intf_out_2[EAST].ready  = 0; // EAST
        intf_out_2[SOUTH].ready = 0;
        intf_out_2[WEST].ready  = 0; // WEST
        intf_out_2[LOCAL].ready = 0;

        intf_in_2[NORTH].valid = 0;
        intf_in_2[EAST].valid = 0;
        intf_in_2[SOUTH].valid = 0;
        intf_in_2[WEST].valid = 0;
        intf_in_2[LOCAL].valid = 0;

        // Reset clear
        #30 rst = 0;

        intf_out[NORTH].ready = 1;
        intf_out[EAST].ready  = 1; // EAST
        intf_out[SOUTH].ready = 1;
        intf_out[WEST].ready  = 1; // WEST
        intf_out[LOCAL].ready = 1;

        intf_in[NORTH].valid = 0;
        intf_in[EAST].valid = 0;
        intf_in[SOUTH].valid = 0;
        intf_in[WEST].valid = 0;
        intf_in[LOCAL].valid = 0;

        // input 2
        intf_out_2[NORTH].ready = 1;
        intf_out_2[EAST].ready  = 1; // EAST
        intf_out_2[SOUTH].ready = 1;
        intf_out_2[WEST].ready  = 1; // WEST
        intf_out_2[LOCAL].ready = 1;

        intf_in_2[NORTH].valid = 0;
        intf_in_2[EAST].valid = 0;
        intf_in_2[SOUTH].valid = 0;
        intf_in_2[WEST].valid = 0;
        intf_in_2[LOCAL].valid = 0;

        #1000
        $fclose(file);
        $fclose(file_2);
        $finish;

    end

    // Data generation and injection
    always @(posedge clk) begin
        if(intf_in[NORTH].ready) begin
            intf_in[NORTH].valid = 1;
            intf_in[NORTH].data = {128{4'h1}};
            intf_in[NORTH].dest_x = $urandom_range(2,1);
            intf_in[NORTH].dest_y = $urandom_range(1);
            intf_in[NORTH].s_delta_x = intf_in[NORTH].dest_x < 1 ? 1 : 0;
            intf_in[NORTH].s_delta_y = intf_in[NORTH].dest_y < 1 ? 1 : 0;
        end else begin
            intf_in[NORTH].valid = 0;
        end
        if(intf_in[EAST].ready) begin
            intf_in[EAST].valid = 1;
            intf_in[EAST].data = {128{4'h2}};
            intf_in[EAST].dest_x = $urandom_range(1);
            intf_in[EAST].dest_y = $urandom_range(2,1);
            intf_in[EAST].s_delta_x = intf_in[EAST].dest_x < 1 ? 1 : 0;
            intf_in[EAST].s_delta_y = intf_in[EAST].dest_y < 1 ? 1 : 0;
        end else begin
            intf_in[EAST].valid = 0;
        end
        if(intf_in[SOUTH].ready)  begin
            intf_in[SOUTH].valid = 1;
            intf_in[SOUTH].data = {128{4'h3}};
            intf_in[SOUTH].dest_x = $urandom_range(2);
            intf_in[SOUTH].dest_y = $urandom_range(2,1);
            intf_in[SOUTH].s_delta_x = intf_in[SOUTH].dest_x < 1 ? 1 : 0;
            intf_in[SOUTH].s_delta_y = intf_in[SOUTH].dest_y < 1 ? 1 : 0;
        end else begin
            intf_in[SOUTH].valid = 0;
        end
        if(intf_in[WEST].ready) begin
            intf_in[WEST].valid = 1;
            intf_in[WEST].data = {128{4'h4}};
            intf_in[WEST].dest_x = $urandom_range(2,1);
            intf_in[WEST].dest_y = $urandom_range(2);
            intf_in[WEST].s_delta_x = intf_in[WEST].dest_x < 1 ? 1 : 0;
            intf_in[WEST].s_delta_y = intf_in[WEST].dest_y < 1 ? 1 : 0;
        end else begin
            intf_in[WEST].valid = 0;
        end
        if(intf_in[LOCAL].ready) begin
            intf_in[LOCAL].valid = 1;
            intf_in[LOCAL].data = {128{4'h5}};
            intf_in[LOCAL].dest_x = $urandom_range(2);
            intf_in[LOCAL].dest_y = $urandom_range(2);
            intf_in[LOCAL].s_delta_x = intf_in[LOCAL].dest_x < 1 ? 1 : 0;
            intf_in[LOCAL].s_delta_y = intf_in[LOCAL].dest_y < 1 ? 1 : 0;
        end else begin
            intf_in[LOCAL].valid = 0;
        end
    end

    // Write to files every clock cycle
    always @(posedge clk)begin
        str= ""; // Clear str
        // Append to str if outgoing ports valid
        if(north_valid) str = $sformatf("%sNorth: %h\n",str, north_data);
        if(east_valid)  str = $sformatf("%sEast:  %h\n",str, east_data);
        if(south_valid) str = $sformatf("%sSouth: %h\n",str, south_data);
        if(west_valid)  str = $sformatf("%sWest:  %h\n",str, west_data);
        if(local_valid) str = $sformatf("%sLocal: %h\n",str, local_data);
        $fwrite(file, "Time:%d\n%s\n",$stime, str); // Write to file

        str_2 = "";
        str_2 = $sformatf("%sNorth: %h\n",str_2, intf_out_2[NORTH].data);
        str_2 = $sformatf("%sEast:  %h\n",str_2, intf_out_2[EAST].data);
        str_2 = $sformatf("%sSouth: %h\n",str_2, intf_out_2[SOUTH].data);
        str_2 = $sformatf("%sWest:  %h\n",str_2, intf_out_2[WEST].data);
        str_2 = $sformatf("%sLocal: %h\n",str_2, intf_out_2[LOCAL].data);
        str_2 = $sformatf("%sWEST_IN: %h\n",str_2, intf_in_2[WEST].data);
        $fwrite(file_2, "Time:%d\n%s\n",$stime, str_2); // Write to file

    end

endmodule
