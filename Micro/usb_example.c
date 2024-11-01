/*
 * usb_hid_example.c
 *
 *  Created on: 4 Oct 2023
 *      Author: stian
 */


/**************************************************************************//**
 * @file main.c
 * @brief USB host stack HID keyboard example project.
 * @author Energy Micro AS
 * @version 3.20.0
 ******************************************************************************
 * @section License
 * <b>(C) Copyright 2012 Energy Micro AS, http://www.energymicro.com</b>
 *******************************************************************************
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 * 4. The source and compiled code may only be used on Energy Micro "EFM32"
 *    microcontrollers and "EFR4" radios.
 *
 * DISCLAIMER OF WARRANTY/LIMITATION OF REMEDIES: Energy Micro AS has no
 * obligation to support this Software. Energy Micro AS is providing the
 * Software "AS IS", with no express or implied warranties of any kind,
 * including, but not limited to, any implied warranties of merchantability
 * or fitness for any particular purpose or warranties against infringement
 * of any proprietary rights of a third party.
 *
 * Energy Micro AS will not be liable for any consequential, incidental, or
 * special damages, or any other relief, or for any claim by any third party,
 * arising from your use of this Software.
 *
 *****************************************************************************/
#include <stdio.h>
#include "app.h"
#include "em_device.h"
#include "em_cmu.h"
#include "bsp.h"
#include "em_usb.h"
#include "usbkbdscancodes.h"

/**************************************************************************//**
 *
 * This example shows how the USB host stack can be used to serve a
 * HID keyboard.
 *
 *****************************************************************************/

/*** Typedef's and defines. ***/

//#define DO_SUSPEND_CURRENT_TEST       /* For internal Energy Micro testing. */
//#define DO_RESET_FROM_SUSPEND_TEST    /* For internal Energy Micro testing. */

char test;
char test2;
int spi_send = 0;
int update_count = 0;

/* Timer indices. */
#define KBD_LED_TIMER     1
#define KBD_POLL_TIMER    0
#define KBD_SUSPEND_TIMER 2

#define KBD_USB_ADDRESS   1     /* USB address used for keyboard. */
#define KBD_INT_IN_HC     2     /* Host channel nr. used for keyboard     */
                                /* interrupt IN endpoint. Ch. 0 and 1     */
                                /* defaults to the control endpoint (EP0) */
#define KBD_IN_REPORT_LEN 8     /* Length of keyboard interrupt IN report.*/

/* USB HID Descriptor. */
typedef struct
{
  uint8_t   bLength;            /* Numeric expression that is the total size of the HID descriptor.       */
  uint8_t   bDescriptorType;    /* Constant name specifying type of HID descriptor.                       */
  uint16_t  bcdHID;             /* Numeric expression identifying the HID Class Specification release.    */
  uint8_t   bCountryCode;       /* Numeric expression identifying country code of the localized hardware. */
  uint8_t   bNumDescriptors;    /* Numeric expression specifying the number of class descriptors.         */
  uint8_t   bReportDescriptorType;  /* Constant name identifying type of class descriptor.                */
  uint16_t  wDescriptorLength;  /* Numeric expression that is the total size of the Report descriptor.    */
} USB_HIDDescriptor_TypeDef;


/*** Function prototypes. ***/

static bool CheckDevice( void );
static void HidCheckKeyPress( void );
static int  HidSetIdle( uint8_t duration, uint8_t reportId );
static int  HidSetProtocol( void );
static int  HidSetReport( uint8_t value );
static void InitKbd( void );
static void LedTimeout( void );
static void PollTimeout( void );
static void PrintDeviceStrings( USBH_Device_TypeDef *dev );
static void SuspendTimeout( void );

/*** Variables ***/

STATIC_UBUF(                tmpBuf, 1024 );
static USBH_Device_TypeDef  device;
static USBH_Ep_TypeDef      ep;
static volatile bool        ledTimerDone;
static volatile bool        pollTimerDone;
static volatile bool        suspendTimerDone;


/**************************************************************************//**
 * @brief main - the entrypoint after reset.
 *****************************************************************************/
void usb_example( void )
{
  int connectionResult;
  uint8_t hidReport;
  USBH_Init_TypeDef initstruct = USBH_INIT_DEFAULT;

  test = 'm';
  test2 = 'm';

  CMU_ClockSelectSet( cmuClock_HF, cmuSelect_HFXO );
  CMU_ClockEnable(cmuClock_GPIO, true);

  printf( "\n\nEFM32 USB Host HID keyboard example.\n" );

  USBH_Init( &initstruct );     /* Initialize USB HOST stack */

  for (;;)
  {
    /* Wait for ever on keyboard attach... */
    printf( "\nWaiting for USB keyboard plug-in...\n" );
    connectionResult = USBH_WaitForDeviceConnectionB( tmpBuf, 0 );

    if ( connectionResult == USB_STATUS_DEVICE_MALFUNCTION )
    {
      printf( "\nA malfunctioning device was attached, please remove device.\n" );
      test2 = 'k';
    }

    else if ( connectionResult == USB_STATUS_PORT_OVERCURRENT )
    {
      printf( "\nVBUS overcurrent condition, please remove device.\n" );
      test2 = 'n';
    }

    else if ( connectionResult == USB_STATUS_OK )
    {
      printf( "\nA device was attached...\n" );
      test2 = 'm';

      /* Check if a valid USB HID keyboard device is attached. */
      if ( CheckDevice() )
      {
        /* Initialize and configure keyboard. */
        InitKbd();

        hidReport = 0;
        pollTimerDone = false;
        USBTIMER_Start( KBD_POLL_TIMER, ep.epDesc.bInterval, PollTimeout );

        /*--------------- MAIN Keyboard polling loop ------------------------*/
        while ( USBH_DeviceConnected() )
        {


          if ( pollTimerDone )
          {
            HidCheckKeyPress();                  /* Any key pressed ? */
            pollTimerDone = false;
            USBTIMER_Start( KBD_POLL_TIMER, ep.epDesc.bInterval, PollTimeout );
          }


          if (spi_send == 1) {
              spi_send = 0;
              spi_send_data();
          }

        }
        printf( "\n\nDevice removal detected...\n" );
        /*-------------------------------------------------------------------*/
      }
    }

    USBTIMER_Stop( KBD_POLL_TIMER );

    /* Wait for malfunctional device or unknown HID keyboard removal. */
    while ( USBH_DeviceConnected() ){}


    /* Disable USB peripheral, power down USB port. */
    USBH_Stop();
  }
}

/**************************************************************************//**
 * @brief
 *   Check if a newly attached device is a valid HID keyboard.
 *
 * @return True if valid HID keyboard device, false otherwise.
 *****************************************************************************/
static bool CheckDevice( void )
{
  int i;

  /* Get all device descriptors. */

  if ( USBH_QueryDeviceB( tmpBuf, sizeof(tmpBuf), USBH_GetPortSpeed() )
       == USB_STATUS_OK)
  {
    /* Print basic device information. */
    printf( "\nDevice VID/PID is 0x%04X/0x%04X, device bus speed is %s",
            ((USBH_Device_TypeDef*)tmpBuf)->devDesc.idVendor,
            ((USBH_Device_TypeDef*)tmpBuf)->devDesc.idProduct,
            USBH_GetPortSpeed() == PORT_FULL_SPEED ? "FULL" : "LOW" );
    PrintDeviceStrings( (USBH_Device_TypeDef*)tmpBuf );

    /* Print all descriptors on console. */
    USBH_PrintDeviceDescriptor(        USBH_QGetDeviceDescriptor(        tmpBuf ) );
    USBH_PrintConfigurationDescriptor( USBH_QGetConfigurationDescriptor( tmpBuf, 0 ), USB_CONFIG_DESCSIZE );
    USBH_PrintInterfaceDescriptor(     USBH_QGetInterfaceDescriptor(     tmpBuf, 0, 0 ) );

    for ( i=0; i<USBH_QGetInterfaceDescriptor( tmpBuf, 0, 0 )->bNumEndpoints; i++ )
    {
      USBH_PrintEndpointDescriptor(    USBH_QGetEndpointDescriptor( tmpBuf, 0, 0, i ) );
    }

    /* Qualify the device */
    if ( ( USBH_QGetInterfaceDescriptor( tmpBuf, 0, 0 )->bInterfaceClass    == USB_CLASS_HID          ) /*&&
         ( USBH_QGetInterfaceDescriptor( tmpBuf, 0, 0 )->bInterfaceProtocol == USB_CLASS_HID_KEYBOARD )  */  )
    {
      printf( "\nValid HID keyboard device.\n" );
      return true;
    }
    else
    {
      printf( "\nNot a valid HID keyboard device, please remove device.\n" );
    }
  }
  else
  {
    printf( "\nDevice enumeration failure, please remove device.\n" );
  }

  return false;
}

/**************************************************************************//**
 * @brief Initialize console I/O redirection.
 *****************************************************************************/

/**************************************************************************//**
 * @brief
 *   Check if a button has been pressed on the keyboard. Prints the ASCII
 *   equivalent of the keyboard scancode on the console.
 *****************************************************************************/
int callBackFunc(USB_Status_TypeDef status, uint32_t xferred, uint32_t remaining) {
  if ( tmpBuf[ 2 ] )
      {
        char c = USB_HidScancodeToAscii( tmpBuf[ 2 ] );
        if ( c ) {
            if (c == 'e') {
                pan_camera(0.02);
                app_process_action(1);
                spi_send = 1;
            } else if(c == 'q') {
                pan_camera(-0.02);
                app_process_action(1);
                spi_send = 1;
            }
            // Move around
            else if(c == 'w') {
                move_camera_z(-1);
                app_process_action(0);
                spi_send = 1;
            } else if(c == 'a') {
                move_camera_x(1);
                app_process_action(0);
                spi_send = 1;
            } else if(c == 's') {
                move_camera_z(1);
                app_process_action(0);
                spi_send = 1;
            } else if(c == 'd') {
                move_camera_x(-1);
                app_process_action(0);
                spi_send = 1;
            }
            // Look around
            else if(c == 'l') {
                camera_yaw(1);
                app_process_action(0);
                spi_send = 1;
            } else if(c == 'j') {
                camera_yaw(-1);
                app_process_action(0);
                spi_send = 1;
            } else if(c == 'i') {
                camera_pitch(1);
                app_process_action(0);
                spi_send = 1;
            } else if(c == 'k') {
                camera_pitch(-1);
                app_process_action(0);
                spi_send = 1;
            } else if (c == 'r' && test != 'r') {
                app_reset();
                app_process_action(0);
                spi_send = 1;
            } else if (c == 'p' && test != 'p') {
                spi_send = 1;
            } else if (c == 'u' && test != 'u') {
                app_process_action(0);
            } else {
                test = c;
            }
            test = c;

        }
      }
}

static void HidCheckKeyPress( void )
{
  char c;
  test2 = 'b';

  USBH_Read(&ep, tmpBuf, ep.epDesc.wMaxPacketSize, 3, callBackFunc);


}

/**************************************************************************//**
 * @brief
 *   Send HID class USB_HID_SET_IDLE setup command to the keyboard.
 *
 * @param[in] duration  How often the keyboard shall report status changes.
 * @param[in] reportId  The ID of the status change report.
 *
 * @return USB_STATUS_OK, or an appropriate USB transfer error code.
 *****************************************************************************/
static int HidSetIdle( uint8_t duration, uint8_t reportId )
{
  return USBH_ControlMsgB(
                    &device.ep0,
                    USB_SETUP_DIR_H2D | USB_SETUP_RECIPIENT_INTERFACE |
                    USB_SETUP_TYPE_CLASS_MASK,            /* bmRequestType */
                    USB_HID_SET_IDLE,                     /* bRequest      */
                    (duration<<8)| reportId,              /* wValue        */
                    0,                                    /* wIndex        */
                    0,                                    /* wLength       */
                    NULL,                                 /* void* data    */
                    1000 );                               /* int timeout   */
}

/**************************************************************************//**
 * @brief
 *   Send HID class USB_HID_SET_PROTOCOL setup command to the keyboard.
 *
 * @return USB_STATUS_OK, or an appropriate USB transfer error code.
 *****************************************************************************/
static int HidSetProtocol( void )
{
  return USBH_ControlMsgB(
                    &device.ep0,
                    USB_SETUP_DIR_H2D | USB_SETUP_RECIPIENT_INTERFACE |
                    USB_SETUP_TYPE_CLASS_MASK,            /* bmRequestType */
                    USB_HID_SET_PROTOCOL,                 /* bRequest      */
                    0,                                    /* wValue 0=boot protocol */
                    0,                                    /* wIndex        */
                    0,                                    /* wLength       */
                    NULL,                                 /* void* data    */
                    1000 );                               /* int timeout   */
}

/**************************************************************************//**
 * @brief
 *   Send HID class USB_HID_SET_REPORT setup command to the keyboard.
 *
 * @param[in] value Bitmask corresponding to keyboard LED indicators.
 *
 * @return USB_STATUS_OK, or an appropriate USB transfer error code.
 *****************************************************************************/
static int HidSetReport( uint8_t value )
{
  tmpBuf[ 0 ] = value;

  return USBH_ControlMsgB(
                    &device.ep0,
                    USB_SETUP_DIR_H2D | USB_SETUP_RECIPIENT_INTERFACE |
                    USB_SETUP_TYPE_CLASS_MASK,            /* bmRequestType */
                    USB_HID_SET_REPORT,                   /* bRequest      */
                    2<<8,                                 /* wValue msb=2 => output report */
                    0,                                    /* wIndex        */
                    1,                                    /* wLength       */
                    tmpBuf,                               /* void* data    */
                    1000 );                               /* int timeout   */
}

/**************************************************************************//**
 * @brief
 *   Enumerate and configure a HID keyboard.
 *****************************************************************************/
static void InitKbd( void )
{
  USB_HIDDescriptor_TypeDef *hidd;

  /* Print the HID descriptor, assume that it is located just after   */
  /* the interface descriptor.                                        */

  hidd = (USB_HIDDescriptor_TypeDef*)
         ( (uint8_t*)USBH_QGetInterfaceDescriptor( tmpBuf, 0, 0 ) +
           sizeof( USB_InterfaceDescriptor_TypeDef ) );

  printf( "\nHID descriptor:" );
  printf( "\n bLength                %d",     hidd->bLength               );
  printf( "\n bDescriptorType        0x%02X", hidd->bDescriptorType       );
  printf( "\n bcdHID                 0x%04X", hidd->bcdHID                );
  printf( "\n bCountryCode           0x%02X", hidd->bCountryCode          );
  printf( "\n bNumDescriptors        %d",     hidd->bNumDescriptors       );
  printf( "\n bReportDescriptorType  0x%02X", hidd->bReportDescriptorType );
  printf( "\n wDescriptorLength      %d\n",   hidd->wDescriptorLength     );

  /* Initialize device data structure, assume device has 1 endpoint. */
  USBH_InitDeviceData( &device, tmpBuf, &ep, 1, USBH_GetPortSpeed() );

  USBH_SetAddressB( &device, KBD_USB_ADDRESS );
  USBH_SetConfigurationB( &device, device.confDesc.bConfigurationValue );

  /* Assign a Host Channel to the interrupt IN endpoint. */
  USBH_AssignHostChannel( &ep, KBD_INT_IN_HC );

  HidSetIdle( 0, 0 );
  HidSetProtocol();
}

/**************************************************************************//**
 * @brief
 *   Called each time the keyboard LED timer expires.
 *****************************************************************************/
static void LedTimeout( void )
{
  ledTimerDone = true;
}

/**************************************************************************//**
 * @brief
 *   Called each time the keyboard interrupt IN endpoint should be checked.
 *****************************************************************************/
static void PollTimeout( void )
{
  pollTimerDone = true;
}

/***************************************************************************//**
 * @brief
 *   Print USB device strings.
 *
 * @param[in] dev Pointer to device data structure.
 ******************************************************************************/
static void PrintDeviceStrings( USBH_Device_TypeDef *dev )
{
  uint8_t tmp[ 256 ];

  /* Get and print device string descriptors. */

  if ( dev->devDesc.iManufacturer )
  {
    USBH_GetStringB( dev, tmp, 255, dev->devDesc.iManufacturer,USB_LANGID_ENUS);
    USBH_PrintString( "\niManufacturer = \"",
                      (USB_StringDescriptor_TypeDef*)tmp, "\"" );
  }
  else
  {
    printf( "\niManufacturer = <NONE>" );
  }

  if ( dev->devDesc.iProduct )
  {
    USBH_GetStringB( dev, tmp, 255, dev->devDesc.iProduct, USB_LANGID_ENUS );
    USBH_PrintString( "\niProduct      = \"",
                      (USB_StringDescriptor_TypeDef*)tmp, "\"" );
  }
  else
  {
    printf( "\niProduct      = <NONE>" );
  }

  if ( dev->devDesc.iSerialNumber )
  {
    USBH_GetStringB( dev, tmp, 255, dev->devDesc.iSerialNumber,USB_LANGID_ENUS);
    USBH_PrintString( "\niSerialNumber = \"",
                      (USB_StringDescriptor_TypeDef*)tmp, "\"\n" );
  }
  else
  {
    printf( "\niSerialNumber = <NONE>\n" );
  }
}

static void SuspendTimeout( void )
{
  suspendTimerDone = true;
}
