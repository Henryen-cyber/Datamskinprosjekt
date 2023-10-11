typedef struct Color {
    logic[3:0] red;
    logic[3:0] green;
    logic[3:0] blue;
    };

typedef struct SphereOrigin {
    logic signed[15:0]  x;
    logic signed[13:0]  y;
    logic signed[15:0]  z;
    };

typedef struct Sphere {
    SphereOrigin        origin;
    logic signed[8:0]   radius;
    Color               color;
    };

typedef struct World {
    Sphere sphere;   
    };

typedef struct Pixel {
    logic signed[8:0] x;
    logic signed[8:0] y;
    parameter z = 15;
    };
