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

void app_init(void)
{
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
void app_process_action(char value)
{
  //SPIDRV_MTransmitB( handle, buffer, 10 );
  buffer[0] = value;
  buffer[1] = value;

  SPIDRV_MTransmit( handle, buffer, 2, TransferComplete );
}
