 #    /--------------------------------------------O
 #    |                                            |
 #    |  COPYRIGHT : (c) 2025 per Linuxperoxo.     |
 #    |  AUTHOR    : Linuxperoxo                   |
 #    |  FILE      : atlas.s                       |
 #    |                                            |
 #    O--------------------------------------------/

.section .atlas.text, "ax", @progbits
.code16
.align 4
.type .AtlasReal, @function
.AtlasReal:
  cli
  
  # NOTE: Pegando as informações do modo 0x117 do VBE 1024x768 2^16 cores
  xorw %ax,         %ax
  movw %ax,         %es
  movw $.Mode_Info, %di
  movw $0x4F01,     %ax
  movw $0x117,      %cx
  int  $0x10

  # NOTE: Habilitando modo 0x117 e limpando a memoria de vídeo
  movw $0x4F02, %ax
  movw $0x4117, %bx
  int  $0x10

  # NOTE: Carregando GDT para ir para o modo protegido
  lgdt .gdt_ptr

  # NOTE: Habilitando bit do gdt em cr0
  movl %cr0, %eax
  orl  $1,   %eax
  movl %eax, %cr0

  # NOTE: Configurando segmento de dados
  movw $0x10, %ax
  movw %ax,   %ds
  movw %ax,   %ss
  movw %ax,   %fs
  movw %ax,   %gs
  movw %ax,   %es

  # NOTE: Configurando segmento de código com far jmp, ljmp(long jump) serve para mudar 
  #       o segmento de código, já o jmp apenas modifica o offset dentro do segmento atual
  ljmp $0x08, $.AtlasProtected

.code32
.align 4
.type .AtlasProtected, @function
.AtlasProtected:

  # NOTE: Pegando ponteiro para framebuffer
  movl .ModeInfo_PhysBasePtr, %edi
  movl $0xFFFF, 0(%edi) # NOTE: Escrita de teste, escrevendo um pixel branco

  hlt

.section .atlas.data, "a", @progbits
.type .gdt_start, @object
.gdt_start:
  .long 0x00000000
  .long 0x00000000

  .word 0xFFFF
  .word 0x0000
  .byte 0x00
  .byte 0b10011010
  .byte 0b11001111
  .byte 0x00

  .word 0xFFFF
  .word 0x0000
  .byte 0x00
  .byte 0b10010010
  .byte 0b11001111
  .byte 0x00
.gdt_end:

.align 4
.type .gdt_ptr, @object
.gdt_ptr:
  .word .gdt_end - .gdt_start
  .long .gdt_start

.align 4
.type .Mode_Info, @object
.Mode_Info:
  .ModeInfo_ModeAttributes:         .space      2,0 
  .ModeInfo_WinAAttributes:         .space      1,0
  .ModeInfo_WinBAttributes:         .space      1,0 
  .ModeInfo_WinGranularity:         .space      2,0 
  .ModeInfo_WinSize:                .space      2,0 
  .ModeInfo_WinASegment:            .space      2,0 
  .ModeInfo_WinBSegment:            .space      2,0 
  .ModeInfo_WinFuncPtr:             .space      4,0 
  .ModeInfo_BytesPerScanLine:       .space      2,0 
  .ModeInfo_XResolution:            .space      2,0
  .ModeInfo_YResolution:            .space      2,0 
  .ModeInfo_XCharSize:              .space      1,0 
  .ModeInfo_YCharSize:              .space      1,0 
  .ModeInfo_NumberOfPlanes:         .space      1,0 
  .ModeInfo_BitsPerPixel:           .space      1,0 
  .ModeInfo_NumberOfBanks:          .space      1,0 
  .ModeInfo_MemoryModel:            .space      1,0 
  .ModeInfo_BankSize:               .space      1,0
  .ModeInfo_NumberOfImagePages:     .space      1,0 
  .ModeInfo_Reserved_page:          .space      1,0
  .ModeInfo_RedMaskSize:            .space      1,0 
  .ModeInfo_RedMaskPos:             .space      1,0
  .ModeInfo_GreenMaskSize:          .space      1,0 
  .ModeInfo_GreenMaskPos:           .space      1,0 
  .ModeInfo_BlueMaskSize:           .space      1,0
  .ModeInfo_BlueMaskPos:            .space      1,0
  .ModeInfo_ReservedMaskSize:       .space      1,0 
  .ModeInfo_ReservedMaskPos:        .space      1,0 
  .ModeInfo_DirectColorModeInfo:    .space      1,0

  # NOTE: VBE 2.0 extensions 
  .ModeInfo_PhysBasePtr:            .space      4,0
  .ModeInfo_OffScreenMemOffset:     .space      4,0 
  .ModeInfo_OffScreenMemSize:       .space      2,0    

.section .atlas.mbr.magic, "a", @progbits
.word 0xAA55
