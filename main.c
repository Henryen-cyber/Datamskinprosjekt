/***************************************************************************//**
 * @file main.c
 * @brief main() function.
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
#include "sl_component_catalog.h"
#include "sl_system_init.h"
#include "app.h"
#include "em_gpio.h"
#include "sl_simple_button_btn0_config.h"
#include "em_cmu.h"
#include "gpiointerrupt.h"
#include "usb_example.h"

#if defined(SL_CATALOG_POWER_MANAGER_PRESENT)
#include "sl_power_manager.h"
#endif
#if defined(SL_CATALOG_KERNEL_PRESENT)
#include "sl_system_kernel.h"
#else // SL_CATALOG_KERNEL_PRESENT
#include "sl_system_process_action.h"
#endif // SL_CATALOG_KERNEL_PRESENT

char test3;

volatile uint8_t pinInt[16];

// Defines for the interrupt
//#define int_pin SL_SIMPLE_BUTTON_BTN0_PIN
#define int_pin 9
//#define int_port SL_SIMPLE_BUTTON_BTN0_PORT
#define int_port gpioPortE


void gpioCallback(uint8_t pin)
{
  pinInt[pin]++;
}

int main(void)
{
  // Initialize Silicon Labs device, system, service(s) and protocol stack(s).
  // Note that if the kernel is present, processing task(s) will be created by
  // this call.
  sl_system_init();

  // Initialize the application. For example, create periodic timer(s) or
  // task(s) if the kernel is present.
  app_init();

  // Set up the interrupt
  CMU_ClockEnable(cmuClock_GPIO, true);
  GPIO_PinModeSet(int_port, int_pin, gpioModeInputPull, 1);

  GPIOINT_Init();
  GPIOINT_CallbackRegister(int_pin, gpioCallback);
  GPIO_IntConfig(int_port, int_pin, false, true, true);

#if defined(SL_CATALOG_KERNEL_PRESENT)
  // Start the kernel. Task(s) created in app_init() will start running.
  sl_system_kernel_start();
#else // SL_CATALOG_KERNEL_PRESENT
  while (1) {
    // Do not remove this call: Silicon Labs components process action routine
    // must be called from the super loop.
    sl_system_process_action();

    // Application process.
    //app_process_action();

    usb_example();
    test3 = 'y';




#if defined(SL_CATALOG_POWER_MANAGER_PRESENT)
    // Let the CPU go to sleep if the system allows it.
    sl_power_manager_sleep();
#endif
  }
#endif // SL_CATALOG_KERNEL_PRESENT
}
