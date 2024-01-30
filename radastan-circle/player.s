
; http://arsantica-online.com/st-niccc-competition/

    DMA_PORT    equ $6b ;//: zxnDMA

    OPT Z80
    OPT ZXNEXTREG   
IS_SNA = 0
IS_NEX = 1-IS_SNA

if IS_SNA==1
	opt	sna=start:StackStart
endif

if IS_NEX==1
    seg     CODE_SEG, 4:$0000,$8000                 ; flat address
;   seg     RASTADAN_SEG, $30:$0000,$0000            ; Beast man sprites;

    seg     CODE_SEG
endif

	include "irq.s"

    org $8200                    ; Start of application
StackEnd:
	ds	128
StackStart:
    ds  2

start:
    ld sp , StackStart

    call palette_setup
    call palette_clear
    call bcd_load_sprites
go: 
    nextreg 7,%11 ;/ 14mhz
    call video_setup
    call init_circle
frame_loop:
    call copy_backdrop
    call init_vbl
    call drawBox
    call a_circle
    call wait_vbl
    call flip_screens
    call swap_buffers
    call controller_circle

;    call show_palette
    jr frame_loop
_palette: ds 16*2

drawBox:
    ld hl, (back_buffer)

    ld b, 80
    ld c,80
    ld d,90
    ld e,4
    
;; c = start x
;; d = end x
;; e = value to fill
;; hl = start of line
.loop:
    push bc
    push de
    push hl
    call line16_draw
    pop hl
    add hl,128/2

    pop de
    pop bc
   
    inc c
    inc d
    inc d
    djnz .loop


    ret


include "video.s"
include "line_16.s"
include "palette.s"
include "bcd_number.s"
include "circle.s"


init_circle;
        ld a, 49
        ld (cr),a

        ld a, 101
        ld(cx),A

        ld a,60
        ld(cy),a
        ret;

a_circle:

rainbow equ *+1
    ld a,1
    inc A
    and 15
    ld (rainbow),A
    ld e,a
    call circle
    ret

if 0
LO_RES_SCROLL_X equ $32
LO_RES_SCROLL_Y equ $33

controller:
 	ld a,(is_pressed)
	ld (was_pressed),a
    ld d,a

    in a,(31)
  	ld (is_pressed),a

    ld e,a

    bit 0,e
    jr z ,.no_right
.right
    ld hl ,dx
    dec (hl)
    ld a, (hl)
    nextreg LO_RES_SCROLL_X,a
.no_right:
    bit 1,e
    jr z ,.no_left
.left
    ld hl ,dx
    inc (hl)
    ld a, (hl)
    nextreg LO_RES_SCROLL_X,a
.no_left:
    bit 2,e
    jr z ,.no_up
.up
    ld hl ,dy
    dec (hl)
    ld a, (hl)
    nextreg LO_RES_SCROLL_Y,a

.no_up:
    bit 3,e
    jr z ,.no_down
.down
    ld hl ,dy
    inc (hl)
    ld a, (hl)
    nextreg LO_RES_SCROLL_Y,a

.no_down:
    bit 4,e
    jr z ,.no_fireA
.fireA:
	ld a,d

	bit 4,a
    call z,video_swap_DFILE
.no_fireA:

    bit 5,e
    jr z ,.no_fireB
.fireB:
	ld a,d

	bit 5,a
    call z,video_switch_ActivePalette_ULA
.no_fireB:


    bit 6,e
    jr z ,.no_fireC
.fireC:
	ld a,(was_pressed)

	bit 6,a
    call z,video_inc_Palette
.no_fireC:

    ret
endif

controller_circle:
 	ld a,(is_pressed)
	ld (was_pressed),a
    ld d,a

    in a,(31)
  	ld (is_pressed),a

    ld e,a

    bit 0,e
    jr z ,.no_right
.right
    ld hl ,cx
    dec (hl)
    ld a, (hl)
.no_right:
    bit 1,e
    jr z ,.no_left
.left
    ld hl ,cx
    inc (hl)
    ld a, (hl)
.no_left:
    bit 2,e
    jr z ,.no_up
.up
    ld hl ,cy
    dec (hl)
    ld a, (hl)

.no_up:
    bit 3,e
    jr z ,.no_down
.down
    ld hl ,cy
    inc (hl)
    ld a, (hl)

.no_down:
    bit 4,e
    jr z ,.no_fireA
.fireA:
	ld a,d

	bit 4,a

    ld hl ,cr
    inc (hl)
    ld a, (hl)
.no_fireA:

    bit 5,e
    jr z ,.no_fireB
.fireB:
    ld hl ,cr
    dec (hl)
    ld a, (hl)
.no_fireB:
    ret


pal: db 0

was_pressed: db 0
is_pressed: db 0

dx: db 0
dy: db 0

if IS_NEX==1
;    seg RASTADAN_SEG

xenon1_slr:    incbin "pi11.nxi"
xenon1_pal:     incbin "pi11.nxp"


xenon2_slr:    incbin "x2.nxi"
xenon2_pal:     incbin "x2.pal"


 _1:
 	savenex "player.nex",start,StackStart


endif

