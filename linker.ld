/*
 *
 *    /--------------------------------------------O
 *    |                                            |
 *    |  COPYRIGHT : (c) 2025 per Linuxperoxo.     |
 *    |  AUTHOR    : Linuxperoxo                   |
 *    |  FILE      : linker.ld                     |
 *    |                                            |
 *    O--------------------------------------------/
 *
 */

OUTPUT(AtlasB.osb)
OUTPUT_FORMAT(binary)

origin_text  = 0x7C00;
origin_magic = 0x7DFE;

SECTIONS {
  . = origin_text;

  .atlas.text : {
    . = ALIGN(4);
    *(.atlas.text.atlas)
    . = ALIGN(4);
    *(.atlas.text.mode)
  }

  .atlas.data : {
    . = ALIGN(4);
    *(.atlas.data.atlas)
  }

  . = origin_magic;

  .atlas.magic : {
    *(.atlas.mbr.magic)
  }

  /DISCARD/ : {
    *(.note*)
    *(.comment*)
    *(.gnu*)
  }
} 
