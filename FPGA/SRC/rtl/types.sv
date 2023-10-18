typedef struct {
    logic[3:0] red;
    logic[3:0] green;
    logic[3:0] blue;
    } Color_s;

typedef struct {
    logic signed[15:0]  x;
    logic signed[13:0]  y;
    logic signed[15:0]  z;
    } SphereOrigin_s;

typedef struct {
    SphereOrigin_s      origin;
    logic[8:0]          radius;
    Color_s             color;
    } Sphere_s;

typedef struct {
    logic signed[9:0] x;
    logic signed[8:0] y;
    logic       [4:0] z;
    } Pixel_s;

typedef struct {
    Pixel_s direction;
    Color_s color;
    } Ray_s;

typedef struct {
    Sphere_s   sphere;
    Pixel_s    pixel;
    logic[1:0] sphere_amount;
    } World_s;
