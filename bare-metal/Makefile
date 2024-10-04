CROSS_COMPILE 		= riscv32-unknown-elf
CC 					= $(CROSS_COMPILE)-gcc
LD 					= $(CROSS_COMPILE)-ld
OBJCOPY 			= $(CROSS_COMPILE)-objcopy
OBJDUMP 			= $(CROSS_COMPILE)-objdump
READELF 			= $(CROSS_COMPILE)-readelf

INCLUDE_DIR = include
SOURCE_DIR 	= src
BUILD_DIR 	= build
CFLAGS 		= -Wall -g -I$(INCLUDE_DIR) -O0
AFLAGS 		= -g -I$(INCLUDE_DIR)
LDFLAGS 	= --no-warn-rwx-segments 

ASM_SRCS 	= $(wildcard $(SOURCE_DIR)/*.S)
C_SRCS 		= $(wildcard $(SOURCE_DIR)/*.c)

ASM_OBJS 	= $(ASM_SRCS:$(SOURCE_DIR)/%.S=$(BUILD_DIR)/%_asm.o)
C_OBJS 		= $(C_SRCS:$(SOURCE_DIR)/%.c=$(BUILD_DIR)/%.o)

APP_NAME = bare-metal

all: clean prepare $(APP_NAME).elf $(APP_NAME).img

$(APP_NAME).img: $(APP_NAME).elf
	$(OBJCOPY) $(APP_NAME).elf -I binary $(APP_NAME).img
	$(OBJDUMP) $(APP_NAME).elf -Dd > $(APP_NAME).dump
	$(READELF) $(APP_NAME).elf -a > $(APP_NAME).info

$(APP_NAME).elf: $(ASM_OBJS) link.ld $(C_OBJS)
	$(LD) -T link.ld $(LDFLAGS) $(ASM_OBJS) $(C_OBJS) -o $(APP_NAME).elf

$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%_asm.o: $(SOURCE_DIR)/%.S
	$(CC) $(AFLAGS) -c $< -o $@

prepare:
	@if  [ ! -d $(BUILD_DIR) ];then \
		mkdir -p $(BUILD_DIR); \
	fi

clean:
	rm -f $(BUILD_DIR)/*_asm.o $(BUILD_DIR)/*.o
	rm -f $(APP_NAME).elf $(APP_NAME).img
	rm -f $(APP_NAME).dump $(APP_NAME).info

distclean:
	rm -rf $(BUILD_DIR)

spike: all
	spike --isa=rv32imafdc --rbb-port=9824 $(APP_NAME).elf
