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
    logic signed [11:0] x;
    logic signed [11:0] y;
    logic signed [11:0] r;
} Circle;

typedef struct packed {
    logic [3:0] r;
    logic [3:0] g;
    logic [3:0] b;
} Color;

endpackage