buffer
index
next_sphere
closest_index
closest_dist
num_misses

current_job
sphere_x
sphere_y
sphere_z
sphere_r

spherex_sr
spherey_sr
spherez_sr
spherer_sr

sqrt_start
sqrt_busy
dis_sqrt_r
pixel_offset_x
pixel_x
pixel_x_sqrd

dotx_r
doty_r
dotz_r

a_times_two_r
c_times_two_r
b_r
br_sr
a_times_c_r
dis_r
dist_r

intersect_x
intersect_y
intersect_z

norm_x
norm_y
norm_z
busy


        if(state == READY && activate == HIGH) begin
        else if (state == CALCULATING_1 && busy == HIGH) begin
        else if (state == CALCULATING_2 && busy == HIGH) begin
        else if (state == CALCULATING_3 && busy == HIGH) begin
        else if (state == CALCULATING_4 && busy == HIGH) begin
        else if (state == CALCULATING_5 && busy == HIGH) begin
        else if (state == CALCULATING_6 && busy == HIGH && sqrt_busy == LOW) begin
        else if(state == CALCULATING_7 && busy == HIGH && sqrt_busy == LOW) begin
        else if (state == CALCULATING_7 && busy == HIGH && sqrt_start == HIGH && sqrt_busy == HIGH) begin
        else if (state == CALCULATING_8 && busy == HIGH && sqrt_busy == LOW) begin //&& sqrt_busy == HIGH) begin && sqrt_busy == LOW) begin
        else if (state == CALCULATING_9 && busy == HIGH) begin
        else if (state == CALCULATING_10 && busy == HIGH) begin //&& sqrt_busy == HIGH) begin && sqrt_busy == LOW) begin
        else if (state == CALCULATING_11 && busy == HIGH) begin //&& sqrt_busy == HIGH) begin && sqrt_busy == LOW) begin
        else if (state == CALCULATING_12 && busy == HIGH) begin //&& sqrt_busy == HIGH) begin && sqrt_busy == LOW) begin
        else if (state == CALCULATING_13 && busy == HIGH) begin //&& sqrt_busy == HIGH) begin && sqrt_busy == LOW) begin
        else if (state == COLORING_1 && busy == HIGH) begin
        else if (state == COLORING_2 && busy == HIGH) begin
        else if (state == FINISHED && busy == HIGH) begin
        else if (activate == LOW) begin
            state               <= READY;
            busy                <= LOW;
            current_job         <= 0;
            pixel_offset_x      <= 0;
            sqrt_start          <= LOW;
        end
    end
