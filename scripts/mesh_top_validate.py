############################ Mesh top validate ############################
# This file checks the ascii file from the mesh_top_tb
# Output coords are checked against the intended, and results are printed
###########################################################################
import os

# Find the file "mesh_top_tb.txt" from scripts dir
input_filename = os.path.join(os.path.realpath(os.path.dirname(__file__)),"../ascii_files/mesh_top_tb.txt")


with open(input_filename, "r") as file:
    correct_cnt = 0 # Declare counters for right and wrong routing
    fail_cnt = 0
    fail_str = "The failing packet(s) coords and times:\n"
    cur_time = ""

    for line in file:
        if "Time:" in line:
            cur_time = line
        if "Output" in line:
            tmp_list = line.split()
            output_coords = tmp_list[0].replace("Output","").replace("]","").replace("[","").replace(":","")
            intend_coords = tmp_list[1].replace("Dx:","") + tmp_list[2].replace("Dy:","")
            
            if output_coords == intend_coords: # If route correct
                correct_cnt += 1
            else: # If route wrong
                fail_cnt += 1
                fail_str += "Output:"+output_coords+" Intended:"+intend_coords+" "+cur_time
                # Append coords and time to the failing string
    print("#### Mesh Top Routing Validation Script #####\n")
    print("Packets Routed:\n{}\tCorrect\n{}\tIncorrect\n".format(correct_cnt,fail_cnt))
    if fail_cnt: # If fails also print times for debugging
        print(fail_str+"\n")