// -----------------------------------------------------------------------
// Global parameters
// This file collects all general parameters of the design
// -----------------------------------------------------------------------

package global_params;
    localparam integer DATA_WIDTH = 512; // Bits
    localparam integer MESH_SIDE  = 4; // Idea is to have square mesh

    localparam integer TB_I_PERCENT = 100; // Injection rate

    // Enumerate port names
    typedef enum {NORTH, EAST, SOUTH, WEST, LOCAL, NE, NW, SE, SW} port_t;

endpackage
