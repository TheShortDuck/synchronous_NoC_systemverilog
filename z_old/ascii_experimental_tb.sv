`timescale 1ns/1ps

module ascii_experimental_tb;
logic [512:0] ascii [16];

integer i;
int file;

initial begin
    // Open file for writing
    file = $fopen("/home/andreas/Bachelor/low_latency_NoC/ascii_files/append_out.txt", "w+");
    $readmemh("/home/andreas/Bachelor/low_latency_NoC/ascii_files/ascii_network.hex", ascii);
    for (i = 0; i < 16; i = i + 1) begin
        // Timestamp the ascii value
        ascii[i][512:504] = $stime;

        // Append value to file
        $display("ascii[%d] = %h", i, ascii[i]);
        $fwrite(file, "ascii[%d] = %h\ttime=%d\n", i, ascii[i],$stime);
        #10;
    end
    // Write the memory to a file
    $writememh("/home/andreas/Bachelor/low_latency_NoC/ascii_files/ascii_network_out.hex", ascii);
    $fclose(file); // Close the file
    $finish;
end

endmodule
