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

/***************************************************************************//**
 * Initialize application.
 ******************************************************************************/
#include "spidrv.h"
#include "em_usart.h"
#include <stdbool.h>
#include <stdio.h>
#include <math.h>

// Fixed-point scale factor, e.g., 1/1024 for 10-bit fractional values.
#define FIXED_POINT_SCALE 1024

// Define a 4x4 matrix type
typedef float Matrix4x4[4][4];

// Define a 4D vector type
typedef float Vector4[4];

// Struct to represent a point with fixed-point coordinates.
typedef struct {
    float x;
    float y;
    float z;
} Vector3;

typedef struct {
    Vector3 position;
    Vector3 forward;
    Vector3 up;
    uint8_t near_clip;
    uint8_t far_clip;
    uint8_t field_of_view; // in radians
} Camera;

// Struct to represent a circle with fixed-point values.
typedef struct {
    Vector3 center;
    float radius;
    float diffusion;   // Diffusion factor
    float color;       // Color data
} Circle;

// Struct to represent the world with four circles.
typedef struct {
    Circle circles[1];
} World;

// The entire world, ready to be transmitted to FPGA
// Modify based on time/input
World world;
Camera camera;

char * test_msg2;

SPIDRV_HandleData_t handleData;
SPIDRV_Handle_t handle = &handleData;

void TransferComplete( SPIDRV_Handle_t handle,
                       Ecode_t transferStatus,
                       int itemsTransferred )
{
  if ( transferStatus == ECODE_EMDRV_SPIDRV_OK )
  {
    // Success !
    test_msg2 = "Heartbeat\0";
  }
}


uint8_t buffer[2];

/***************************************************************************//**
 * App ticking function.
 ******************************************************************************/
void spi_send_data(char value)
{
  //SPIDRV_MTransmitB( handle, buffer, 10 );
  buffer[0] = value;
  buffer[1] = value;

  SPIDRV_MTransmit( handle, &world, 24, TransferComplete);
}


void multiplyMatrices(Matrix4x4 result, Matrix4x4 matrix1, Matrix4x4 matrix2) {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            result[i][j] = 0;
            for (int k = 0; k < 4; k++) {
                result[i][j] += matrix1[i][k] * matrix2[k][j];
            }
        }
    }
}

// Function to apply a 4x4 matrix to a 4D vector
void multiplyMatrixVector(Vector4 result, Matrix4x4 matrix, Vector4 vector) {
    for (int i = 0; i < 4; i++) {
        result[i] = 0;
        for (int j = 0; j < 4; j++) {
            result[i] += matrix[i][j] * vector[j];
        }
    }
}

// Function to calculate the rotation matrix based on look-at parameters
void lookAt(Matrix4x4 rotation_matrix, float camera_pos[3], float target[3], float up[3]) {
    // Calculate the forward vector (the direction the camera is looking)
    float forward[3];
    for (int i = 0; i < 3; i++) {
        forward[i] = target[i] - camera_pos[i];
    }

    // Normalize the forward vector
    float forward_length = sqrt(forward[0] * forward[0] + forward[1] * forward[1] + forward[2] * forward[2]);
    for (int i = 0; i < 3; i++) {
        forward[i] /= forward_length;
    }

    // Calculate the right vector (perpendicular to the forward and up vectors)
    float right[3];
    for (int i = 0; i < 3; i++) {
        right[i] = forward[(i + 1) % 3] * up[(i + 2) % 3] - forward[(i + 2) % 3] * up[(i + 1) % 3];
    }

    // Normalize the right vector
    float right_length = sqrt(right[0] * right[0] + right[1] * right[1] + right[2] * right[2]);
    for (int i = 0; i < 3; i++) {
        right[i] /= right_length;
    }

    // Calculate the up vector (perpendicular to the forward and right vectors)
    for (int i = 0; i < 3; i++) {
        up[i] = right[(i + 1) % 3] * forward[(i + 2) % 3] - right[(i + 2) % 3] * forward[(i + 1) % 3];
    }

    // Create the rotation matrix
    for (int i = 0; i < 3; i++) {
        rotation_matrix[0][i] = right[i];
        rotation_matrix[1][i] = up[i];
        rotation_matrix[2][i] = -forward[i];
    }

    // Set the last row and column of the rotation matrix
    for (int i = 0; i < 4; i++) {
        rotation_matrix[i][3] = 0.0f;
        rotation_matrix[3][i] = (i == 3) ? 1.0f : 0.0f;
    }
}


/***************************************************************************//**
 * Initialize application.
 ******************************************************************************/
void app_init(void)
{
//  SWO_Setup_test();

  // Initialize the first circle.
  world.circles[0].center.x = 512;
  world.circles[0].center.y = 8;
  world.circles[0].center.z = 512;
  world.circles[0].radius = 256;
  world.circles[0].diffusion = 512;
  world.circles[0].color = 0xFF00;

  test_msg2 = "First\0";

    buffer[0] = 15;
    //buffer[1] = 15;
    //buffer[2] = 33;
    //buffer[3] = 19;
    //buffer[4] = 1;
    //buffer[5] = 77;
    //buffer[6] = 51;
    //buffer[7] = 7;

    SPIDRV_Init_t initData = SPIDRV_MASTER_USART1;


    // Init
    SPIDRV_Init( handle, &initData );

    test_msg2 = "Second\0";

}

/***************************************************************************//**
 * App ticking function.
 ******************************************************************************/
void app_process_action(void)
{
  // Define camera's position, target, and up vector
  Vector3 camera_pos = {125.0, 0.0, -10.0};
  camera.position = camera_pos;

  float target[3] = {0.0, 0.0, 100.0};
  float up[3] = {0.0, 1.0, 0.0};

  // Set circle ref
  Circle *circle1 = &world.circles[0];
  Vector4 original_position = {circle1->center.x, circle1->center.y, circle1->center.z, 1.0f};

  // Define the camera's transformation matrix (identity for camera at 0, 0, 0)
  Vector3 *cam_pos = &camera.position;

  Matrix4x4 translation_matrix = {{1, 0, 0, cam_pos->x},
                                 {0, 1, 0, cam_pos->y},
                                 {0, 0, 1, cam_pos->z},
                                 {0, 0, 0, 1}};

  // Create a rotation matrix based on the look-at parameters
  Matrix4x4 rotation_matrix;
  lookAt(rotation_matrix, cam_pos, target, up);

  // Combine the matrices for the object
  Matrix4x4 combined_matrix;
  multiplyMatrices(combined_matrix, translation_matrix, rotation_matrix);

  // Apply the transformations to the object's position
  Vector4 transformed_position;
  multiplyMatrixVector(transformed_position, combined_matrix, original_position);

  // The object is now in the camera's coordinate system
  printf("Transformed Position: (%.2f, %.2f, %.2f)\n",
         transformed_position[0], transformed_position[1], transformed_position[2]);

}
