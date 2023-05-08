module interface_test ( // Dumb test to feed interface to register
    input logic clk,
    input logic valid,
    router_if.in_p intf_in,
    router_if.out_p intf_out
);
    always_ff @(posedge clk) begin
        if(valid) begin // This is enough to update register only when valid, values still retained
            intf_out.data <= intf_in.data;// Not allowed update intf to intf, must be each port
        end
    end
endmodule
