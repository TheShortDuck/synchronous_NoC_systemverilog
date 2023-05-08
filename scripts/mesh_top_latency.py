############################# Mesh top latency ############################
# This file checks the ascii file from the mesh_top_tb
# Latency is calculated from the time the packet is sent from the source
# Both overall latency and latency per router is calculated
###########################################################################
import os

# Find the file "mesh_top_tb.txt" from scripts dir
input_filename = os.path.join(os.path.realpath(os.path.dirname(__file__)),"../ascii_files/mesh_top_tb.txt")

with open(input_filename, "r") as file:
    output_time = 0
    overall_latency = 0
    hop_latency = 0
    latency_cnt = 0

    for line in file:
        if "Time:" in line:
            output_time = int(line.split()[1])
        if "Output" in line:
            tmp_list = line.split()
            out_coords_tmp = tmp_list[0].replace("Output","").replace("]","").replace("[","").replace(":","")
            output_x = int(out_coords_tmp[0])
            output_y = int(out_coords_tmp[1])
            
            data_tmp = tmp_list[5].replace("Data:","")
            input_x = int(data_tmp[0])
            input_y = int(data_tmp[1])
            input_time = int(data_tmp[2:],16) # Convert hex to dec

            # Calculate the number of hops
            if abs(output_x - input_x) > abs(output_y - input_y):
                hop_cnt = abs(output_x - input_x)
            else:
                hop_cnt = abs(output_y - input_y)

            # Calculate overall latency
            overall_latency += output_time - input_time
            # find out the latency per hop
            hop_latency += (output_time - input_time) / (hop_cnt+1) # +1 to match the amount of routers
            latency_cnt += 1

print("#### Mesh Top Latency Calculation Script ####\n")
print("Average Overall Latency:    {}".format(round(overall_latency/latency_cnt,2)))
print("Average Latency per Router: {}\n".format(round(hop_latency/latency_cnt,2)))
