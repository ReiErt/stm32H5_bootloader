#include "lib\STM32CubeH5\Drivers\CMSIS\Device\ST\STM32H5xx\Include\stm32h563xx.h"
#include "lib\STM32CubeH5\Drivers\STM32H5xx_HAL_Driver\Inc\stm32h5xx_hal_rcc.h"
#include "lib\STM32CubeH5\Drivers\STM32H5xx_HAL_Driver\Inc\stm32h5xx_hal_gpio.h"

void delay_ms(uint32_t ms)
{
    for (uint32_t i = 0; i < ms * 16000; ++i)
    {
        __asm__("nop");
    }
}

static void MX_GPIO_Init(void)
{
    /* GPIO Ports Clock Enable */
    __HAL_RCC_GPIOB_CLK_ENABLE();
    __HAL_RCC_GPIOG_CLK_ENABLE();
    __HAL_RCC_GPIOF_CLK_ENABLE();
    __HAL_RCC_GPIOC_CLK_ENABLE();
    __HAL_RCC_GPIOA_CLK_ENABLE();
}

int main(void)
{
    MX_GPIO_Init();
    // Enable GPIOB, GPIOG, and GPIOF clocks via AHB4ENR
    RCC->AHB4ENR |= (1 << 1); // GPIOB
    RCC->AHB4ENR |= (1 << 6); // GPIOG
    RCC->AHB4ENR |= (1 << 5); // GPIOF

    // Set PB5, PG5, PF5 to output mode
    GPIOB->MODER &= ~(3UL << (5 * 2));
    GPIOB->MODER |= (1UL << (5 * 2));

    GPIOG->MODER &= ~(3UL << (5 * 2));
    GPIOG->MODER |= (1UL << (5 * 2));

    GPIOF->MODER &= ~(3UL << (5 * 2));
    GPIOF->MODER |= (1UL << (5 * 2));

    GPIOB->MODER &= ~(3UL << (0 * 2));
    GPIOB->MODER |= (1UL << (0 * 2));

    GPIOF->MODER &= ~(3UL << (4 * 2));
    GPIOF->MODER |= (1UL << (4 * 2));

    GPIOG->MODER &= ~(3UL << (4 * 2));
    GPIOG->MODER |= (1UL << (4 * 2));

    GPIOB->OTYPER &= ~(1 << 0);         // Push-pull
    GPIOB->OSPEEDR |= (3UL << (0 * 2)); // High speed
    GPIOB->PUPDR &= ~(3UL << (0 * 2));  // No pull-up/down

    GPIO_InitTypeDef gpio_init_structure;
    gpio_init_structure.Pin = GPIO_PIN_0;
    gpio_init_structure.Mode = GPIO_MODE_OUTPUT_PP;
    gpio_init_structure.Pull = GPIO_NOPULL;
    gpio_init_structure.Speed = GPIO_SPEED_FREQ_VERY_HIGH;

    HAL_GPIO_Init(GPIOB, &gpio_init_structure);

    while (1)
    {
        GPIOB->ODR ^= (1 << 5);
        GPIOG->ODR ^= (1 << 5);
        GPIOF->ODR ^= (1 << 5);
        GPIOB->ODR ^= (1 << 0);
        GPIOF->ODR ^= (1 << 4);
        GPIOG->ODR ^= (1 << 4);
        delay_ms(100);
    }
}
// main.c

void __libc_init_array(void)
{
    // Do nothing. This function exists in .s startup file. We need to call it and just return.
}
