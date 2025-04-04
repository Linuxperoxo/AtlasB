#    /--------------------------------------------O
#    |                                            |
#    |  COPYRIGHT : (c) 2025 per Linuxperoxo.     |
#    |  AUTHOR    : Linuxperoxo                   |
#    |  FILE      : atlas.s                       |
#    |                                            |
#    O--------------------------------------------/

.include "asm/video/mode.s"
.include "asm/cpu/gdt.s"
.include "asm/io/ata.s"

.equ MAGIC_FLAG, 0xAB00

.equ VBE_DEFAULT_MODE, 0x117

.section .atlas.text.atlas, "ax", @progbits
.code16
.align 4
.type .AtlasReal, @function
.AtlasReal:
  cli

  movw $0xA000, %sp # NOTE: Configurando stack

  movw $.ModeInfo, %di # NOTE: Parameter Struct ptr: Lugar onde as informações do modo serão colocadas 
  xorw %bx,        %bx # NOTE: Parameter Mode: Modo a ser carregado, se %bx == 0 então vamos usar o modo default
  #call GetMode         # NOTE: Quando retornar, se a BIOS suportar o modo, a struct .ModeInfo vai estar totalmente preenchida

  xorw %bx, %bx # NOTE: Parameter Mode: Mesma ideia do %bx no GetMode
  #call SetMode  # NOTE: Quando retornar, vamos está no novo modo de vídeo

  # NOTE: Carregando GDT para ir para o modo protegido
  lgdt GDTP

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
  movl $0xb8000, %edi
  
  pushl $.AtlasStruct # NOTE: Preenchendo os dados de boot e suas informações
  pushl $0x0000001
  pushl $1
  pushl $0
  call ataLBA_R

  leal .AtlasStruct, %ebx

  hlt

# NOTE: Para melhor entendimento dessa parte veja as seguintes documentações
#       -> https://wiki.osdev.org/VESA_Video_Modes
#       -> https://wiki.osdev.org/User:Omarrx024/VESA_Tutorial

.section .atlas.data.atlas, "aw", @progbits
.align 4
.type .ModeInfo, @object
.ModeInfo:
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

# NOTE: Essa struct deve ser os primeiros bits de qualquer arquivo
#       que vai ser inicializado pelo Atlas

# NOTE:
#   AtlasMagic:    .word -> Esses 2 byte é uma flag mágica para dizer ao atlas que é uma imagem válida, aqui deve ter a flag 0xAB00
#   AtlasLoadDest: .long -> Aqui é o endereço de memória onde a imagem deve ser carregada
#   AtlasOffset:   .long -> Aqui é o offset dentro da imagem para a função main, ou seja, o atlas vai passar o controle para o endereço .AtlasLoadDest + .AtlasOffset
#   AtlasImgSize:  .long -> Tamanho total em bytes da image, isso é importante para o atlas saber quantos setores precisa carregar, quando adicionar um fs para o Atlas não vamos mais precisar dessa informação

# NOTE: OBS: Caso essa struct seja feita em C, use __attribute__((packed)) para evitar alinhamento pelo compilador. Para zig use packed struct

.section .atlas.struct.atlas, "w", @nobits
.align 4
.type .AtlasStruct, @object
.AtlasStruct:
  AtlasMagic:    .word
  AtlasLoadDest: .long
  AtlasOffset:   .long
  AtlasImgSize:  .long
