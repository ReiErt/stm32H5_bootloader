# Name of the final output file (without extension)
TARGET = blink

BUILD_DIR = build

# Target ARM Cortex core (STM32H563ZI uses Cortex-M33)
MCU = cortex-m33

# Tells the preprocessor to define the STM32H5xx flavor for the linker script
# Equivalent to #define STM32H563xx 1 at the top of every src file
STM32H5xx_flavor = -DSTM32H563xx 

# Compiler to use. Note: Ensure you have arm-none-eabi-gcc installed and in your PATH
CC = arm-none-eabi-gcc

# Common CPU flags for Cortex-M33 with single-precision FPU
CPU_FLAGS = -mthumb -mcpu=$(MCU) -mfloat-abi=hard -mfpu=fpv5-sp-d16

# Path to CMSIS (you should clone this from STM32CubeH5 repo)
CMSIS = lib/STM32CubeH5/Drivers/CMSIS

# Path to STM32H5xx-specific device files
DEVICE = $(CMSIS)/Device/ST/STM32H5xx

# Startup assembly file for STM32H563xx (from CMSIS Templates)
STARTUP = $(DEVICE)/Source/Templates/gcc/startup_stm32h563xx.s

# System initialization source file (CMSIS system clock setup)
SYSTEM = $(DEVICE)/Source/Templates/system_stm32h5xx.c

# Include paths for CMSIS headers and device headers
INCLUDES = \
  -I$(CMSIS)/Core/Include \
  -I$(DEVICE)/Include \
  -Ilib/STM32CubeH5/Drivers/STM32H5xx_HAL_Driver/Inc \
  -Iconfig

# Compiler flags for C files
CFLAGS = $(CPU_FLAGS) -Wall -O0 -g $(INCLUDES) -DSTM32H563xx

# Linker flags
# -T: use the custom linker script
# -nostartfiles: do not link the standard startup files
LDFLAGS = -TSTM32H563ZITx_FLASH.ld $(CPU_FLAGS) -nostartfiles -Wl,-Map=$(BUILD_DIR)/$(TARGET).map

SOURCES = main.c \
		  $(STARTUP) \
		  $(SYSTEM) \
		  lib/STM32CubeH5/Drivers/STM32H5xx_HAL_Driver/Src/STM32h5xx_hal.c	\
		  lib/STM32CubeH5/Drivers/STM32H5xx_HAL_Driver/Src/STM32h5xx_hal_gpio.c \
	   	  lib/STM32CubeH5/Drivers/STM32H5xx_HAL_Driver/Src/STM32h5xx_hal_rcc.c \
		  lib/STM32CubeH5/Drivers/STM32H5xx_HAL_Driver/Src/STM32h5xx_hal_cortex.c

# List of object files to compile and link
OBJS = $(BUILD_DIR)/main.o \
       $(BUILD_DIR)/lib/STM32CubeH5/Drivers/CMSIS/Device/ST/STM32H5xx/Source/Templates/system_stm32h5xx.o \
       $(BUILD_DIR)/lib/STM32CubeH5/Drivers/CMSIS/Device/ST/STM32H5xx/Source/Templates/gcc/startup_stm32h563xx.o \
	   $(BUILD_DIR)/lib/STM32CubeH5/Drivers/STM32H5xx_HAL_Driver/Src/STM32h5xx_hal.o \
       $(BUILD_DIR)/lib/STM32CubeH5/Drivers/STM32H5xx_HAL_Driver/Src/STM32h5xx_hal_gpio.o \
       $(BUILD_DIR)/lib/STM32CubeH5/Drivers/STM32H5xx_HAL_Driver/Src/STM32h5xx_hal_rcc.o \
	   $(BUILD_DIR)/lib/STM32CubeH5/Drivers/STM32H5xx_HAL_Driver/Src/STM32h5xx_hal_cortex.o

# Default rule to build the ELF output
all: $(BUILD_DIR)/$(TARGET).elf

# Rule to link all object files into the final ELF binary
$(BUILD_DIR)/$(TARGET).elf: $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)
	arm-none-eabi-objcopy -O ihex $@ $(BUILD_DIR)/$(TARGET).hex
	arm-none-eabi-objdump -d $@ > $(BUILD_DIR)/$(TARGET).lst

# Compile C files to build/ path
$(BUILD_DIR)/%.o: %.c
	@if not exist "$(dir $@)" mkdir "$(dir $@)"
	$(CC) $(CFLAGS) -c $< -o $@

# Compile assembly files to build/ path
$(BUILD_DIR)/%.o: %.s
	@if not exist "$(dir $@)" mkdir "$(dir $@)"
	$(CC) $(CPU_FLAGS) -c $< -o $@


# Clean rule (Windows-friendly `del` command to remove build artifacts)
clean:
	del /Q /S $(BUILD_DIR)\* 2>nul || echo Nothing to clean