//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2023 09:26:13 PM
// Design Name: 
// Module Name: types
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

package Types;

typedef struct packed {
    logic signed [15:0] x;
    logic signed [13:0] y;
    logic signed [15:0] z;
    logic signed [5:0] r;
    logic signed [11:0] c;
} Sphere;

typedef struct packed {
    logic [3:0] r;
    logic [3:0] g;
    logic [3:0] b;
} Color;

endpackage