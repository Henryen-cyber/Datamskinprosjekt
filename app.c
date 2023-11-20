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

#include "spidrv.h"
#include "em_usart.h"
#include <stdbool.h>
#include <stdio.h>
#include <math.h>
#include "app.h"

#define FIXED_POINT_FRACTIONAL_BITS 3
#define N_Spheres 1
#define CAM_SPEED 0.05
#define ROT_SPEED 0.1

// Fixed-point Format: 13.3 (16-bit)
// 11.3 for y-axis
typedef int16_t fixed_point_t;

typedef struct {
  fixed_point_t x;  // 16
  fixed_point_t y;  // 14
  fixed_point_t z;  // 16
} Vector3_fp;

typedef struct {
  Vector3_fp center;       // 46
  fixed_point_t radius;    // 6
  fixed_point_t color;     // 12
} Sphere_fp;

// Define a 4x4 matrix type
typedef float Matrix4x4[4][4];

// Define a 4D vector type
typedef float Vector4[4];

// Struct to represent a Sphere with fixed-point values.
typedef struct {
    Vector3 center;
    float radius;
    float color;       // Color data
} Sphere;

// Struct to represent the world with four Spheres.
typedef struct {
    Sphere Spheres[N_Spheres];
} World;

// Two fixed-point versions of world
// one is most recent ready for sending on interrupt
// the other is being worked on
// 12 bytes, half the size of World using floats
typedef struct {
  Sphere_fp Spheres[N_Spheres];
} World_fp;

uint64_t *current_packed_data;
uint64_t *noncurrent_packed_data;
uint64_t packed_data_1;
uint64_t packed_data_2;

SPIDRV_HandleData_t handleData;
SPIDRV_Handle_t handle = &handleData;


void spi_send_data()
{
  // Go through the memory backwards in msb.
  for (int i = 0; i < 8; i++) {
      // Blocking transmit so that it doesn't overwrite itself
      SPIDRV_MTransmitB( handle, (char *)current_packed_data + (7-i), 1 );
  }

}


fixed_point_t double_to_fixed(double input) {
    return (fixed_point_t)(round(input * (1 << FIXED_POINT_FRACTIONAL_BITS)));
}

Sphere_fp Sphere_to_Sphere_fp (Sphere sphere) {
  Sphere_fp result;

  Vector3_fp center;
  center.x = double_to_fixed(sphere.center.x);
  center.y = double_to_fixed(sphere.center.y);
  center.z = double_to_fixed(sphere.center.z);
  result.center = center;
  result.radius = sphere.radius;
  result.color = sphere.color;

  return result;
}

// Pack data into a 64-bit space
void pack_data(Sphere_fp sphere) {

    *noncurrent_packed_data = 0;

    *noncurrent_packed_data |= ((uint64_t)sphere.center.x & 0xFFFF) << 48;  // 16 bits for x
    *noncurrent_packed_data |= ((uint64_t)sphere.center.y & 0x7FFF) << 33;  // 15 bits for y
    *noncurrent_packed_data |= ((uint64_t)sphere.center.z & 0x7FFF) << 18;  // 15 bits for z
    *noncurrent_packed_data |= ((uint64_t)sphere.radius & 0x3F) << 12;      // 6 bits for radius
    *noncurrent_packed_data |= (uint64_t)sphere.color & 0xFFF;              // 12 bits for color

}

World_fp world_to_world_fp(World world) {
  World_fp world_fp;

  for (int i = 0; i <= N_Spheres; i++) {
      world_fp.Spheres[i] = Sphere_to_Sphere_fp(world.Spheres[i]);
  }

  return world_fp;
}

//uint64_t world_fp_to_spi_data(World_fp world_fp) {
//  uint64_t packed_data = pack_data(world_fp.Spheres[0]);
//  return packed_data;
//}

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

void normalize(Vector3 *vec) {
    float length = sqrt(vec->x * vec->x + vec->y * vec->y + vec->z * vec->z);
    if (length != 0.0f) {
        vec->x /= length;
        vec->y /= length;
        vec->z /= length;
    }
}

void cross(Vector3 *result, Vector3 v1, Vector3 v2) {
    result->x = v1.y * v2.z - v1.z * v2.y;
    result->y = v1.z * v2.x - v1.x * v2.z;
    result->z = v1.x * v2.y - v1.y * v2.x;
}

float dot(Vector3 v1, Vector3 v2) {
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

float vector_length(Vector3 vector) {
  return sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
}

// Function to calculate the rotation matrix based on look-at parameters
void lookAt(Matrix4x4 rotation_matrix, Vector3 camera_pos, Vector3 target, Vector3 up) {
      Vector3 forward, right, newUp;

      // Calculate the forward vector (the direction the camera is looking)
      forward.x = target.x - camera_pos.x;
      forward.y = target.y - camera_pos.y;
      forward.z = target.z - camera_pos.z;
      normalize(&forward);

      // Calculate the right vector (perpendicular to the forward and up vectors)
      cross(&right, forward, up);
      normalize(&right);

      // Calculate the up vector (perpendicular to the forward and right vectors)
      cross(&newUp, right, forward);
      normalize(&newUp);

      // Create the rotation matrix
      rotation_matrix[0][0] = right.x;
      rotation_matrix[0][1] = newUp.x;
      rotation_matrix[0][2] = forward.x;
      rotation_matrix[0][3] = 0.0f;

      rotation_matrix[1][0] = right.y;
      rotation_matrix[1][1] = newUp.y;
      rotation_matrix[1][2] = forward.y;
      rotation_matrix[1][3] = 0.0f;

      rotation_matrix[2][0] = right.z;
      rotation_matrix[2][1] = newUp.z;
      rotation_matrix[2][2] = forward.z;
      rotation_matrix[2][3] = 0.0f;

      rotation_matrix[3][0] = 0.0;//dot(camera_pos, right);
      rotation_matrix[3][1] = 0.0;//dot(camera_pos, newUp);
      rotation_matrix[3][2] = 0.0;//dot(camera_pos, forward);
      rotation_matrix[3][3] = 1.0f;
}

// World to compute on, in floating point
World world;
Camera camera;
Vector4 original_original_position;


/***************************************************************************//**
 * Initialize application.
 ******************************************************************************/
void app_init(void)
{
  // Initialize the first Sphere.
    world.Spheres[0].center.x = 0;
    world.Spheres[0].center.y = 0;
    world.Spheres[0].center.z = 0;
    world.Spheres[0].radius = 4;
    world.Spheres[0].color = 2;

    Vector3 pos = {0.0, 0.0, 400.0};
    camera.position = pos;
    Vector3 target = {0.0, 0.0, 0.0};
    camera.target = target;
    Vector3 up = {0.0, 1.0, 0.0};
    normalize(&up);
    camera.yaw = 90.0 * 3.14/4.0;
    camera.up = up;
    original_original_position[0] = 0.0;
    original_original_position[1] = 0.0;
    original_original_position[2] = 0.0;
    original_original_position[3] = 1.0;


    current_packed_data = &packed_data_1;
    //*current_packed_data = 0b0000000000000000000000000010000000110100011000001110000000000010;
    noncurrent_packed_data = &packed_data_2;

  SPIDRV_Init_t initData = SPIDRV_MASTER_USART1;

  SPIDRV_Init( handle, &initData );


}

void app_reset()
{
  // Initialize the first Sphere.
    world.Spheres[0].center.x = 0;
    world.Spheres[0].center.y = 0;
    world.Spheres[0].center.z = 0;
    world.Spheres[0].radius = 4;
    world.Spheres[0].color = 2;

    Vector3 pos = {0.0, 0.0, 400.0};
    camera.position = pos;
    Vector3 target = {0.0, 0.0, 0.0};
    camera.target = target;
    Vector3 up = {0.0, 1.0, 0.0};
    normalize(&up);
    camera.yaw = 90.0 * 3.14/4.0;
    camera.up = up;
    original_original_position[0] = 0.0;
    original_original_position[1] = 0.0;
    original_original_position[2] = 0.0;
    original_original_position[3] = 1.0;


}

void printMatrix(Matrix4x4 printmatix) {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            printf("%f\n", printmatix[i][j]);
        }
    }
}

void set_camera_position(Vector3 pos) {
  camera.position.x = pos.x;
  camera.position.y = pos.y;
  camera.position.z = pos.z;
}

float glob_t = 0.0;

void pan_camera(float t) {
  Vector3 temp = {camera.target.x - camera.position.x,
                camera.target.y - camera.position.y,
                camera.target.z - camera.position.z};
  glob_t += t;
  if (glob_t > 6.28) {
      glob_t -= 6.28;
  }

  float camX = sinf(glob_t) * vector_length(temp);
  float camZ = cosf(glob_t) * vector_length(temp);

  camera.position.x = camX;
  camera.position.z = camZ;
}

void move_camera_x(int dir) {
  Vector3 right = {0.0, 0.0, 0.0};
  cross(&right, camera.up, camera.forward);
  normalize(&right);

  dir*=20;

  camera.position.x += CAM_SPEED * dir * right.x;
  camera.position.y += CAM_SPEED * dir * right.y;
  camera.position.z += CAM_SPEED * dir * right.z;

}

void move_camera_z(int dir) {
    dir *= 20;
    camera.position.x += CAM_SPEED * dir * camera.forward.x;
    camera.position.y += CAM_SPEED * dir * camera.forward.y;
    camera.position.z += CAM_SPEED * dir * camera.forward.z;
}

void camera_pitch(float pitch) {
  camera.pitch += pitch * ROT_SPEED;

  if (camera.pitch < -89) {
      camera.pitch = -89;
  } else if (camera.pitch > 89) {
      camera.pitch = 89;
  }
}

void camera_yaw(float yaw) {
  camera.yaw += yaw * ROT_SPEED;
}

/***************************************************************************//**
 * App ticking function.
 ******************************************************************************/
void app_process_action(int pan)
{
   World_fp world_fp;

   camera.forward.x = cosf(camera.yaw) * cosf(camera.pitch);
   camera.forward.y = sinf(camera.pitch);
   camera.forward.z = sinf(camera.yaw) * cosf(camera.pitch);

   Vector3 camera_right = {0.0,0.0,0.0};
   cross(&camera_right, camera.up, camera.forward);
   normalize(&camera_right);

   // Set Sphere ref
   Sphere *Sphere1 = &world.Spheres[0];

   Matrix4x4 translation_matrix = {{1,0,0,-camera.position.x},
                                   {0,1,0,-camera.position.y},
                                   {0,0,1,-camera.position.z},
                                   {0,0,0,1}};
   printf("Translation: \n");
   printMatrix(translation_matrix);

   Vector3 temp = {0.0, 0.0, 0.0};

      // Create a rotation matrix based on the look-at parameters
      if (pan) {
          temp.x = camera.position.x + camera.target.x;
          temp.y = camera.position.y + camera.target.y;
          temp.z = camera.position.z + camera.target.z;
          normalize(&temp);
      } else {
          temp.x = camera.forward.x;
          temp.y = camera.forward.y;
          temp.z = camera.forward.z;
      }


   // Create a rotation matrix based on the look-at parameters
       Matrix4x4 rotation_matrix = {{camera_right.x, camera_right.y, camera_right.z, 0},
                                       {camera.up.x, camera.up.y, camera.up.z, 0},
                                       {temp.x, temp.y, temp.z, 0},
                                       {0,0,0,1}};

   printf("\nRotation: \n");
   printMatrix(rotation_matrix);

   // Combine the matrices for the object
   Matrix4x4 combined_matrix;
   multiplyMatrices(combined_matrix, rotation_matrix, translation_matrix);

   printf("\nTranslation: \n");
   printMatrix(combined_matrix);
   // Apply the transformations to the object's position
   Vector4 transformed_position;
   multiplyMatrixVector(transformed_position, combined_matrix, original_original_position);

   Sphere1->center.x = -transformed_position[0];
   Sphere1->center.y = transformed_position[1];
   Sphere1->center.z = -transformed_position[2];

   // Update current world_fp data
   world_fp = world_to_world_fp(world);

   // Pack world_fp into 64 bits in our bit-scheme
   //*current_packed_data = world_fp_to_spi_data(world_fp);
   pack_data(world_fp.Spheres[0]);

   // Swap what world to work on
   if (current_packed_data == &packed_data_1) {
       current_packed_data = &packed_data_2;
       noncurrent_packed_data = &packed_data_1;
   } else {
       current_packed_data = &packed_data_1;
       noncurrent_packed_data = &packed_data_2;
   }

   // The object is now in the camera's coordinate system
   printf("Transformed Position: (%.2f, %.2f, %.2f)\n",
          transformed_position[0], transformed_position[1], transformed_position[2]);

}
