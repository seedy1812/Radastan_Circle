CR_43:  db 0

PALETTE_ENHANCED_ULA_OFF equ 0<<0
PALETTE_ENHANCED_ULA_ON equ 1<<0
PALETTE_ENHANCED_ULA_MASK equ ~(PALETTE_ENHANCED_ULA_ON)

PALETTE_ULA_FIRST equ 0<<1
PALETTE_ULA_SECOND equ 1<<1
PALETTE_ULA_MASK equ ~PALETTE_ULA_SECOND

PALETTE_LAYER2_FIRST equ 0<<2
PALETTE_LAYER2_SECOND equ 1<<2
PALETTE_LAYER2_MASK equ ~PALETTE_LAYER2_SECOND

PALETTE_SPRITES_FIRST equ 0<<3
PALETTE_SPRITES_SECOND equ 1<<3
PALETTE_SPRITES_MASK equ ~PALETTE_SPRITES_SECOND

PALETTE_RW_SELECT_ULA_FIRST         equ %00000000
PALETTE_RW_SELECT_ULA_SECOND        equ %01000000
PALETTE_RW_SELECT_LAYER2_FIRST      equ %00010000
PALETTE_RW_SELECT_LAYER2_SECOND     equ %01010000
PALETTE_RW_SELECT_SPRITES_FIRST     equ %00100000
PALETTE_RW_SELECT_SPRITES_SECOND    equ %01100000
PALETTE_RW_SELECT_LAYER3_FIRST      equ %00110000
PALETTE_RW_SELECT_LAYER3_SECOND     equ %01110000
PALETTE_RW_SELECT_MASK              equ %10001111


PALLETTE_AUTO_INC_ON                equ 0<<7
PALLETTE_AUTO_INC_OFF                equ 1<<7
PALLETTE_AUTO_INC_MASK                 equ ~(1<<7)

palette_setup:

        ld d,$43
        call get_CR
        ld (CR_43),a

        ld b,PALLETTE_AUTO_INC_ON
        call video_set_Palette_Auto_Increment

        ld b,PALETTE_ENHANCED_ULA_ON
        call video_set_Enhanced_ULA


        ld b,PALETTE_RW_SELECT_ULA_FIRST
        call video_set_RW_Palette

        ld b,PALETTE_ULA_FIRST
        call video_set_ActivePalette_ULA

        ret

get_CR:
        ld bc,$243b
        out (c),d
        ld bc,$253b
        in a,(c)
        ret


video_set_RW_Palette:
        ld a,(CR_43)
        and  PALETTE_RW_SELECT_MASK
        or b
        nextreg $43,a
        ld (CR_43),a
        ret

video_set_Enhanced_ULA:
        ld a,(CR_43)
        and  PALETTE_ENHANCED_ULA_MASK
        jr video_set_ActivePalette_orb

video_set_Palette_Auto_Increment
        ld a,(CR_43)
        and  PALLETTE_AUTO_INC_MASK
        jr video_set_ActivePalette_orb

video_switch_ActivePalette_ULA
        ld a,(CR_43)
        xor  PALETTE_ULA_SECOND
        jr video_set_ActivePalette

video_set_ActivePalette_ULA:
        ld a,(CR_43)
        and  PALETTE_ULA_MASK
        jr video_set_ActivePalette_orb

video_set_ActivePalette_Layer2:
        ld a,(CR_43)
        and  PALETTE_LAYER2_MASK
        jr video_set_ActivePalette_orb

video_set_ActivePalette_Sprites:
        ld a,(CR_43)
        and  PALETTE_SPRITES_MASK
video_set_ActivePalette_orb:
        or b
video_set_ActivePalette:
        nextreg $43,a
        ld (CR_43),a
        ret



palette_clear:

    call show_palette

    ld b,PALETTE_RW_SELECT_SPRITES_FIRST
    call video_set_RW_Palette


    nextreg $40,$e1         ;set the font to white ink - transparent background ?
    nextreg $44,255
    nextreg $44,1

    ld b,PALETTE_RW_SELECT_SPRITES_FIRST
    call video_set_RW_Palette

    nextreg $40,$0         ;set col 0 to white
    nextreg $44,%0101101
    nextreg $44,1

    ret


show_palette:
    ld b, PALETTE_RW_SELECT_ULA_FIRST
    call video_set_RW_Palette
    ld hl,xenon1_pal
    nextreg $40,0         ; start at colour 0 and auto increment
;    call .do_stuff

;    ld b, PALETTE_RW_SELECT_ULA_SECOND
;    call video_set_RW_Palette
;    ld hl,xenon1_pal
;    nextreg $40,0         ; start at colour 0 and auto increment

.do_stuff:
    ld b, 16*2           ; 16 colours 
_next:
    ld a,(hl)
    inc hl
    nextreg $44,a
    ld a,(hl)
    inc hl
    nextreg $44,a
    djnz _next
    ret


 palette_add_sprites:

   ld de, 32
   ld b,16

   ld a,8
   ld (.bcd_y),a

   ld hl, .hex_string
.mid_loop:
   push bc
   ld a,(hl)

   inc hl
   call .print
   add de,16
   pop bc
   djnz .mid_loop
   ret


.hex_string: db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

   ; de = posx 9bit
; a = index
.print
   add a,16
   ld b,a
   ld c,$57

   out (c),e  ; x:lo
 .bcd_y: equ *+1
   ld a,9
   out (c),a ; y

   ld a,1      ; palette offset = 0
   and d       ; no mirror and no rotate
   out (c),a   ; bit 0 msb:x
   
   set 7,b     
   out (c),b   ; visible+ sprite_value
 
   ret



palette_create_sprites
    ld bc, $303b
    ld a,16
    out (c),a ; start at pattern 16
    ld bc,$005b
    ld a,16 ; colours 0 to 15
    ld e,0
.outer_loop:
    ld d,256
.inner_loop:
    out(c),e                ;; create 16 sprites of value 0 to 15
    dec d
    jr nz,.inner_loop
    inc e
    dec a
    jr nz, .outer_loop

    ret
