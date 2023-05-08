// TBD
module route_logic #(
    parameter integer X_COORD = 0,
    parameter integer Y_COORD = 0
) (
    input logic clk,
    input logic rst,
    input logic req,
    output logic ack,
    router_if.in_p  intf_in,
    router_if.out_p intf_out
);
    logic [511:0] data_reg;
    logic s_delta_x_reg;
    logic s_delta_y_reg;
    logic [$clog2(MESH_SIDE) - 1:0] dest_x_reg;
    logic [$clog2(MESH_SIDE) - 1:0] dest_y_reg;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            data_reg <= '0;
            s_delta_x_reg <= '0;
            s_delta_y_reg <= '0;
            dest_x_reg <= '0;
            dest_y_reg <= '0;
        end else begin
            data_reg <= intf_in.data_reg;
            s_delta_x_reg <= intf_in.s_delta_x_reg;
            s_delta_y_reg <= intf_in.s_delta_y_reg;
            dest_x_reg <= intf_in.dest_x_reg;
            dest_y_reg <= intf_in.dest_y_reg;
        end
    end

endmodule
