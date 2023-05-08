# Low latency Network on chip
The NoC is a two-dimensional mesh with added diagonals.

The Systemverilog language is used and the target simulators are Vivado or Icarus Verilog.

Packet and network size can be set in the ```global_params.sv``` file, by default the network is 4x4 and the data width of the packets are 512 bits.