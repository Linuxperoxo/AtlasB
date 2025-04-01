#    /--------------------------------------------O
#    |                                            |
#    |  COPYRIGHT : (c) 2025 per Linuxperoxo.     |
#    |  AUTHOR    : Linuxperoxo                   |
#    |  FILE      : vga.s                         |
#    |                                            |
#    O--------------------------------------------/

.ifndef VGA
.equ VGA, 0
  .equ VGA_FRAMEBUFFER, 0xB8000
  .equ VGA_CH_COLOR, 0x0F
  .equ VGA_BC_COLOR, 0x00
  .equ VGA_WIDTH, 80
  .equ VGA_HEIGHT, 25

  .section .atlas.text.vga, "ax", @progbits
  .code32
  .global VGA_W
  .align 4
  .type VGA_W, @function
  VGA_W:
    # TODO:

  .global VGA_C
  .align 4
  .type VGA_C, @function
  VGA_C:
    # TODO:
.else
  .warning "asm/io/vga.s is already defined!"
.endif
