OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv","elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x80000000, LENGTH = 8M
    RAM1 (xrw)  : ORIGIN = 0x80800000, LENGTH = 8M
    RAM2 (xrw)  : ORIGIN = 0x81000000, LENGTH = 1M #Don't Use, Reserved for OpenOCD work area
}
SECTIONS
{
  .text.init :
  {
    __text_start = .;
    . = ALIGN(4);
    *(.text.init)
  }>FLASH 

  .text :
  {
    . = ALIGN(4);
    *(.text .text.*)
    __text_end = .;
  }>FLASH

  .rodata :
  {
    . = ALIGN(4);
    *(.rodata .rodata.*)
    __rodata_end = .;
  }>FLASH AT>FLASH

  .data :
  {
    . = ALIGN(4);
    *(.data .data.*)
  }>RAM1

  .sdata :
  {
    . = ALIGN(4);
    *(.sdata .sdata.*)
  }>RAM1

  .sbss :
  {
    . = ALIGN(4);
    *(.dynsbss)
    *(.sbss .sbss.*)
    *(.scommon)
  }>RAM1

  .bss :
  {
    . = ALIGN(4);
    *(.dynbss)
    *(.bss .bss.*)
  }>RAM1

  . = ALIGN(4);                                                                 
  _ebss = .;                                                                    
  _stack_top = MIN(_ebss + 0x800, (ORIGIN(RAM1) + LENGTH(RAM1) - 0x20));
}
