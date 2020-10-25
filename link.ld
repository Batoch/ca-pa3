/****************************************************************
 *
 *  4190.308 Computer Architecture (Fall 2020)
 *
 *  Project #3: RISC-V Assembly Programming
 *
 *  October 26, 2020
 *
 *  Injae Kang (abcinje@snu.ac.kr)
 *  Sunmin Jeong (sunnyday0208@snu.ac.kr)
 *  Systems Software & Architecture Laboratory
 *  Dept. of Computer Science and Engineering
 *  Seoul National University
 *
 ****************************************************************/


OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x80000000;
  .text.init : { *(.text.init) }
  . = ALIGN(0x1000);
  .tohost : { *(.tohost) }
  . = ALIGN(0x1000);
  .text : { *(.text) }
  . = 0x80010000;
  .data : { *(.data) }
  .bss : { *(.bss) }
  _end = .;
}
