module interface_test_tb;
    localparam integer WIDTH = 4;
    logic clk, valid;
    router_if intf_in();
    router_if intf_out();

    interface_test ift_test_inst (
        .clk(clk),
        .valid(valid),
        .intf_in(intf_in),
        .intf_out(intf_out)
    );

    initial begin
        $display("########## Starting test ##########");
        clk = 0;
        valid = 0;
        intf_in.s_delta_x = '1;
        intf_in.s_delta_y = '1;
        intf_in.dest_x = '1;
        intf_in.dest_y = '1;
        intf_in.data = '1;
        $monitor("sdx: %b\tsdy: %b\tdx: %b\tdy: %b\tdata: %b\t",intf_out.s_delta_x,\
                    intf_out.s_delta_y,intf_out.dest_x,intf_out.dest_y,intf_out.data);

        #10
        clk = 1;
        valid = 1;
        $monitor("sdx: %b\tsdy: %b\tdx: %b\tdy: %b\tdata: %b\t",intf_out.s_delta_x,\
                    intf_out.s_delta_y,intf_out.dest_x,intf_out.dest_y,intf_out.data);

        #10
        clk = 0;
        valid = 0;
        intf_in.s_delta_x = '0;
        intf_in.s_delta_y = '0;
        intf_in.dest_x = '0;
        intf_in.dest_y = '0;
        intf_in.data = '0;
        $monitor("sdx: %b\tsdy: %b\tdx: %b\tdy: %b\tdata: %b\t",intf_out.s_delta_x,\
                    intf_out.s_delta_y,intf_out.dest_x,intf_out.dest_y,intf_out.data);

        #10
        clk = 1;
        valid = 0;
        $monitor("sdx: %b\tsdy: %b\tdx: %b\tdy: %b\tdata: %b\t",intf_out.s_delta_x,\
                    intf_out.s_delta_y,intf_out.dest_x,intf_out.dest_y,intf_out.data);

        #10
        clk = 0;
        $monitor("sdx: %b\tsdy: %b\tdx: %b\tdy: %b\tdata: %b\t",intf_out.s_delta_x,\
                    intf_out.s_delta_y,intf_out.dest_x,intf_out.dest_y,intf_out.data);

        #10
        clk = 1;
        valid = 1;
        $monitor("sdx: %b\tsdy: %b\tdx: %b\tdy: %b\tdata: %b\t",intf_out.s_delta_x,\
                    intf_out.s_delta_y,intf_out.dest_x,intf_out.dest_y,intf_out.data);
        $finish();

    end

endmodule
