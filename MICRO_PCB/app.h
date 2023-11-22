/***************************************************************************//**
 * @file
 * @brief Top level application functions
 *******************************************************************************
 * # License
 * <b>Copyright 2020 Silicon Laboratories Inc. www.silabs.com</b>
 *******************************************************************************
 *
 * The licensor of this software is Silicon Laboratories Inc. Your use of this
 * software is governed by the terms of Silicon Labs Master Software License
 * Agreement (MSLA) available at
 * www.silabs.com/about-us/legal/master-software-license-agreement. This
 * software is distributed to you in Source Code format and is governed by the
 * sections of the MSLA applicable to Source Code.
 *
 ******************************************************************************/

#ifndef APP_H
#define APP_H
#include <stdio.h>

typedef struct {
    float x;
    float y;
    float z;
} Vector3;

typedef struct {
    Vector3 position;
    Vector3 target;
    Vector3 forward;
    float pitch;
    float yaw;
    Vector3 up;
    uint8_t near_clip;
    uint8_t far_clip;
    uint8_t field_of_view; // in radians
} Camera;

/***************************************************************************//**
 * Initialize application.
 ******************************************************************************/
void app_init(void);

/***************************************************************************//**
 * App ticking function.
 ******************************************************************************/
void app_process_action(int pan);
void spi_send_data();
void set_camera_position(Vector3 pos);
void pan_camera(float t);
void move_camera_x(int dir);
void move_camera_z(int dir);
void camera_pitch(float pitch);
void camera_yaw(float yaw);
void app_reset();

#endif  // APP_H
