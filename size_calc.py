from math import log2, ceil


def bits(n):
    return ceil(log2(n))

def max_of(bits):
    return 2**bits - 1

viewport_width = 640
viewport_height = 480
viewport_focal_length = viewport_width / 2 # 90 deg

s_sphere_x_non_fixed_point_bits = 12 + 1 # including signed bit
fp_bits = 3 

sphere_z_non_fixed_point_bits = s_sphere_x_non_fixed_point_bits - 1 # does not use signed bit
sphere_z_fp_bits = fp_bits

s_sphere_y_non_fixed_point_bits = 11 + 1 # including signed bit
sphere_y_fp_bits = fp_bits

sphere_r_bits = 6
sphere_r_multiplier = 8

s_pixel_x_bits = bits(viewport_width) # including signed bit
s_pixel_y_bits = bits(viewport_height) # including signed bit


pixelx_sqrd_bits = bits((max_of(s_pixel_x_bits - 1)) ** 2)
originx_sqrd_bits = bits(max_of(s_sphere_x_non_fixed_point_bits - 1) ** 2) + fp_bits
s_dotx_bits = bits(max_of(s_pixel_x_bits - 1) * max_of(s_sphere_x_non_fixed_point_bits - 1)) + 1 + fp_bits

pixely_sqrd_bits = bits((max_of(s_pixel_y_bits - 1)) ** 2)
originy_sqrd_bits = bits(max_of(s_sphere_y_non_fixed_point_bits - 1) ** 2) + sphere_y_fp_bits
s_doty_bits = bits(max_of(s_pixel_y_bits - 1) * max_of(s_sphere_y_non_fixed_point_bits - 1)) + 1 + sphere_y_fp_bits

originz_sqrd_bits = bits(max_of(sphere_z_non_fixed_point_bits) ** 2) + sphere_z_fp_bits
dotz_bits = bits(viewport_focal_length * max_of(sphere_z_non_fixed_point_bits)) + sphere_z_fp_bits

originr_sqrd_bits = bits((max_of(sphere_r_bits) * sphere_r_multiplier) ** 2)


a_times_two_bits = bits(2 * (max_of(pixelx_sqrd_bits) + max_of(pixely_sqrd_bits) + (viewport_focal_length / 2) ** 2))

b_bits = bits(2 * (max_of(s_dotx_bits - 1 - fp_bits) + max_of(s_doty_bits - 1 - sphere_y_fp_bits) + max_of(dotz_bits - sphere_z_fp_bits))) + 1 + fp_bits
b_sqrd_bits = bits(max_of(b_bits - 1 - fp_bits) ** 2) + fp_bits

c_times_two_bits = bits(2 * (max_of(originx_sqrd_bits - fp_bits) + max_of(originy_sqrd_bits - sphere_y_fp_bits) + max_of(originz_sqrd_bits - sphere_z_fp_bits))) + fp_bits

a_times_c_bits = bits(max_of(a_times_two_bits) * max_of(c_times_two_bits))

dis_bits = b_sqrd_bits
dis_sqrt_bits = bits(max_of(dis_bits - fp_bits)**0.5) + fp_bits

dist_bits = bits(max_of(b_bits - fp_bits) / max_of(a_times_two_bits))

print(f"""
Sphere: 
signed x: {s_sphere_x_non_fixed_point_bits} + {fp_bits}
signed y: {s_sphere_y_non_fixed_point_bits} + {sphere_y_fp_bits}
z bits: {sphere_z_non_fixed_point_bits} + {sphere_z_fp_bits}

Pixel:
signed pixel_x: {s_pixel_x_bits}
signed pixel_y: {s_pixel_y_bits}

Calculations:
pixelx_sqrd: {pixelx_sqrd_bits}
pixely_sqrd: {pixely_sqrd_bits}

originx_sqrd: {originx_sqrd_bits}
originy_sqrd: {originy_sqrd_bits}
originz_sqrd: {originz_sqrd_bits}

signed dotx: {s_dotx_bits}
signed doty: {s_doty_bits}
dotz: {dotz_bits}

a_times_two: {a_times_two_bits}
b: {b_bits}
b_sqrd: {b_sqrd_bits}
c_times_two: {c_times_two_bits}

a_times_c: {a_times_c_bits}
dis: {dis_bits}


""")

print(f"""
`define FP_B {fp_bits}
`define PX_X_B {s_pixel_x_bits}
`define PX_X_SQRD_B {pixelx_sqrd_bits}

`define PX_Y_B {s_pixel_y_bits}
`define PX_Y_SQRD_B {pixely_sqrd_bits}

`define S_X_INT_B {s_sphere_x_non_fixed_point_bits}
`define S_X_FP_B {fp_bits}

`define S_Y_INT_B {s_sphere_y_non_fixed_point_bits}
`define S_Y_FP_B {sphere_y_fp_bits}

`define S_Z_INT_B {sphere_z_non_fixed_point_bits}
`define S_Z_FP_B {sphere_z_fp_bits}

`define S_X_SQRD_B {originx_sqrd_bits}
`define S_Y_SQRD_B {originy_sqrd_bits}
`define S_Z_SQRD_B {originz_sqrd_bits}
`define S_R_SQRD_B {originr_sqrd_bits}

`define DOT_X_B {s_dotx_bits}
`define DOT_Y_B {s_doty_bits}
`define DOT_Z_B {dotz_bits}

`define TWO_A_B {a_times_two_bits}
`define B_B {b_bits}
`define B_SQRD_B {b_sqrd_bits}
`define TWO_C_B {c_times_two_bits}

`define A_TIMES_C_B {a_times_c_bits}
`define DIS_B {b_sqrd_bits}
`define DIS_SQRT_B {dis_sqrt_bits}

`define DIST_B {dist_bits}
""")

