
__ROM_BASE = 0x08000000;
__ROM_SIZE = 0x00078000;

/*--------------------- Embedded RAM Configuration ----------------------------*/
__RAM_BASE = 0x20000000;
__RAM_SIZE = 0x00010000;

__STACK_SIZE = 0x00000800;


MEMORY
{
    FLASH (rx)      : ORIGIN = __ROM_BASE, LENGTH = __ROM_SIZE
    RAM   (rwx)     : ORIGIN = __RAM_BASE, LENGTH = __RAM_SIZE - 256
    SCRATCH_Y(rwx)  : ORIGIN = __RAM_BASE + __RAM_SIZE - 256, LENGTH = 256

}

ENTRY(Reset_Handler)

SECTIONS
{

  .text :
  {
    KEEP(*(.vectors))
    *(.text*)

    KEEP(*(.init))
    KEEP(*(.fini))

    /* .ctors */
    *crtbegin.o(.ctors)
    *crtbegin?.o(.ctors)
    *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
    *(SORT(.ctors.*))
    *(.ctors)

    /* .dtors */
    *crtbegin.o(.dtors)
    *crtbegin?.o(.dtors)
    *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
    *(SORT(.dtors.*))
    *(.dtors)

    *(.rodata*)

    KEEP(*(.eh_frame*))
  } > FLASH


  .flash_range : ALIGN(4)
  {
      FILL(0xff)
      __section_table_start = .;
      __data_section_table = .;

      xxx_data_load_addr = LOADADDR(.data);
      xxx_data_addr = ADDR(.data);

      LONG(LOADADDR(.data));
      LONG(    ADDR(.data));
      LONG(  SIZEOF(.data));

      __data_section_table_end = .;

      __bss_section_table = .;
      LONG(    ADDR(.bss));
      LONG(  SIZEOF(.bss));
      __bss_section_table_end = .;
      __section_table_end = . ;
      /* End of Global Section Table */
      *(.after_vectors*)

  } > FLASH


  .ARM.extab :
  {
    *(.ARM.extab* .gnu.linkonce.armextab.*)
  } > FLASH

  __exidx_start = .;
  .ARM.exidx :
  {
    *(.ARM.exidx* .gnu.linkonce.armexidx.*)
  } > FLASH
  __exidx_end = .;


  __etext = ALIGN (4);

  .data : AT (__etext)
  {
    __data_start__ = .;
    *(vtable)
    *(.data)
    *(.data.*)

    . = ALIGN(4);
    /* preinit data */
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP(*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);

    . = ALIGN(4);
    /* init data */
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP(*(SORT(.init_array.*)))
    KEEP(*(.init_array))
    PROVIDE_HIDDEN (__init_array_end = .);

    . = ALIGN(4);
    /* finit data */
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP(*(SORT(.fini_array.*)))
    KEEP(*(.fini_array))
    PROVIDE_HIDDEN (__fini_array_end = .);

    KEEP(*(.jcr*))
    . = ALIGN(4);
    /* All data end */
    __data_end__ = .;

  } > RAM



  .bss :
  {
    . = ALIGN(4);
    __bss_start__ = .;
    *(.bss)
    *(.bss.*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end__ = .;
  } > RAM AT > RAM

    .heap (COPY):
    {
        __end__ = .;
        end = __end__;
        *(.heap*)
        __HeapLimit = .;
    } > RAM


    .flash_end : {
        __flash_binary_end = .;
    } > FLASH



    .stack_dummy (COPY):
    {
        *(.stack*)
    } > SCRATCH_Y

    __StackTop       = ORIGIN(RAM) + LENGTH(RAM) ;/*  */
    __StackLimit     = ORIGIN(RAM) + LENGTH(RAM) - __STACK_SIZE; /*  */
    __StackBottom    = __StackTop; /* init value*/

    PROVIDE(__stack = __StackTop);
    PROVIDE(_sstack = __StackTop);
    PROVIDE(_estack = __StackBottom);


    /* Check if data + heap + stack exceeds RAM limit */
  ASSERT(__StackLimit >= __HeapLimit, "region RAM overflowed with stack")

    /* assign unused never call function to panic. 
    _close_r  = panic;
    _kill     = panic;
    _getpid   = panic;
    _fstat_r  = panic;
    _isatty_r = panic;
    _lseek_r  = panic;*/
}
