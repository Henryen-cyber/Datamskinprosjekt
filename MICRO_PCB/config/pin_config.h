#ifndef PIN_CONFIG_H
#define PIN_CONFIG_H

// $[ACMP0]
// [ACMP0]$

// $[ACMP1]
// [ACMP1]$

// $[ACMP2]
// [ACMP2]$

// $[ACMP3]
// [ACMP3]$

// $[ADC0]
// [ADC0]$

// $[ADC1]
// [ADC1]$

// $[BU]
// [BU]$

// $[CAN0]
// [CAN0]$

// $[CAN1]
// [CAN1]$

// $[CMU]
// [CMU]$

// $[CSEN]
// [CSEN]$

// $[DBG]
// [DBG]$

// $[EBI]
// [EBI]$

// $[ETH]
// [ETH]$

// $[ETM]
// [ETM]$

// $[GPIO]
// [GPIO]$

// $[I2C0]
// [I2C0]$

// $[I2C1]
// [I2C1]$

// $[I2C2]
// [I2C2]$

// $[IDAC0]
// [IDAC0]$

// $[LCD]
// [LCD]$

// $[LESENSE]
// [LESENSE]$

// $[LETIMER0]
// [LETIMER0]$

// $[LETIMER1]
// [LETIMER1]$

// $[LEUART0]
// [LEUART0]$

// $[LEUART1]
// [LEUART1]$

// $[LFXO]
// [LFXO]$

// $[PCNT0]
// [PCNT0]$

// $[PCNT1]
// [PCNT1]$

// $[PCNT2]
// [PCNT2]$

// $[PRS.CH0]
// [PRS.CH0]$

// $[PRS.CH1]
// [PRS.CH1]$

// $[PRS.CH2]
// [PRS.CH2]$

// $[PRS.CH3]
// [PRS.CH3]$

// $[PRS.CH4]
// [PRS.CH4]$

// $[PRS.CH5]
// [PRS.CH5]$

// $[PRS.CH6]
// [PRS.CH6]$

// $[PRS.CH7]
// [PRS.CH7]$

// $[PRS.CH8]
// [PRS.CH8]$

// $[PRS.CH9]
// [PRS.CH9]$

// $[PRS.CH10]
// [PRS.CH10]$

// $[PRS.CH11]
// [PRS.CH11]$

// $[PRS.CH12]
// [PRS.CH12]$

// $[PRS.CH13]
// [PRS.CH13]$

// $[PRS.CH14]
// [PRS.CH14]$

// $[PRS.CH15]
// [PRS.CH15]$

// $[PRS.CH16]
// [PRS.CH16]$

// $[PRS.CH17]
// [PRS.CH17]$

// $[PRS.CH18]
// [PRS.CH18]$

// $[PRS.CH19]
// [PRS.CH19]$

// $[PRS.CH20]
// [PRS.CH20]$

// $[PRS.CH21]
// [PRS.CH21]$

// $[PRS.CH22]
// [PRS.CH22]$

// $[PRS.CH23]
// [PRS.CH23]$

// $[QSPI0]
// [QSPI0]$

// $[SDIO]
// [SDIO]$

// $[TIMER0]
// [TIMER0]$

// $[TIMER1]
// [TIMER1]$

// $[TIMER2]
// [TIMER2]$

// $[TIMER3]
// [TIMER3]$

// $[TIMER4]
// [TIMER4]$

// $[TIMER5]
// [TIMER5]$

// $[TIMER6]
// [TIMER6]$

// $[UART0]
// [UART0]$

// $[UART1]
// [UART1]$

// $[USART0]
// [USART0]$

// $[USART1]
// [USART1]$

// $[USART2]
// USART2 CLK on PB5
#ifndef USART2_CLK_PORT                         
#define USART2_CLK_PORT                          gpioPortB
#endif
#ifndef USART2_CLK_PIN                          
#define USART2_CLK_PIN                           5
#endif
#ifndef USART2_CLK_LOC                          
#define USART2_CLK_LOC                           1
#endif

// USART2 CS on PB6
#ifndef USART2_CS_PORT                          
#define USART2_CS_PORT                           gpioPortB
#endif
#ifndef USART2_CS_PIN                           
#define USART2_CS_PIN                            6
#endif
#ifndef USART2_CS_LOC                           
#define USART2_CS_LOC                            1
#endif

// USART2 RX on PB4
#ifndef USART2_RX_PORT                          
#define USART2_RX_PORT                           gpioPortB
#endif
#ifndef USART2_RX_PIN                           
#define USART2_RX_PIN                            4
#endif
#ifndef USART2_RX_LOC                           
#define USART2_RX_LOC                            1
#endif

// USART2 TX on PB3
#ifndef USART2_TX_PORT                          
#define USART2_TX_PORT                           gpioPortB
#endif
#ifndef USART2_TX_PIN                           
#define USART2_TX_PIN                            3
#endif
#ifndef USART2_TX_LOC                           
#define USART2_TX_LOC                            1
#endif

// [USART2]$

// $[USART3]
// [USART3]$

// $[USART4]
// [USART4]$

// $[USART5]
// [USART5]$

// $[USB]
// [USB]$

// $[VDAC0]
// [VDAC0]$

// $[WFXO]
// [WFXO]$

// $[WTIMER0]
// [WTIMER0]$

// $[WTIMER1]
// [WTIMER1]$

// $[WTIMER2]
// [WTIMER2]$

// $[WTIMER3]
// [WTIMER3]$

// $[CUSTOM_PIN_NAME]
#ifndef MOSI_SPI_DQ4_A16_PORT                   
#define MOSI_SPI_DQ4_A16_PORT                    gpioPortB
#endif
#ifndef MOSI_SPI_DQ4_A16_PIN                    
#define MOSI_SPI_DQ4_A16_PIN                     3
#endif

#ifndef MISO_SPI_DQ5_C17_PORT                   
#define MISO_SPI_DQ5_C17_PORT                    gpioPortB
#endif
#ifndef MISO_SPI_DQ5_C17_PIN                    
#define MISO_SPI_DQ5_C17_PIN                     4
#endif

#ifndef SPI_CLK_DQ6_A15_PORT                    
#define SPI_CLK_DQ6_A15_PORT                     gpioPortB
#endif
#ifndef SPI_CLK_DQ6_A15_PIN                     
#define SPI_CLK_DQ6_A15_PIN                      5
#endif

#ifndef SPI_CS_DQ7_C18_PORT                     
#define SPI_CS_DQ7_C18_PORT                      gpioPortB
#endif
#ifndef SPI_CS_DQ7_C18_PIN                      
#define SPI_CS_DQ7_C18_PIN                       6
#endif

// [CUSTOM_PIN_NAME]$

#endif // PIN_CONFIG_H

