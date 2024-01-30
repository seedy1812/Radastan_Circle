do_one: macro
    ld (hl),e
    inc hl
endm

do_16: macro
    do_one
    do_one
    do_one
    do_one
    do_one
    do_one
    do_one
    do_one
    do_one
    do_one
    do_one
    do_one
    do_one
    do_one
    do_one
    do_one
endm

;; c = start x
;; d = end x
;; e = value to fill
;; hl = start of line
line16_draw:
    ld a,c  ; 2 pixels per byte
    cp d
    ret z

    srl a   ; if odd then 2 nibble has to be set
    add hl,a

    ld a,c
    srl a   ; if odd then 2 nibble has to be set
    
    jr nc ,.even_start

    ;  odd start to the line

    ld a,(hl)   ; mask out the 2nd nibble
    and $f0
    or e        ; or in the colour
    ld (hl),a   ; write back

    inc c       ; pretend start point is next one
    inc hl      ; so it starts at the next byte
.even_start:
    ld a,d  ; end - start /2 ( 2 nibbles per byte )
    sub c
    sra a   ; length  /2 

    push hl ; save fill pointer
 
    sla a           ;2 instructions to write 2 pixels 
    ld b,0
    ld c,a
    ld hl,.line_end ;calc return address
    sbc hl,bc       ;so we dont have loop or any dec carry jump tests

    ld a,e
    swapnib
    or e        ; e = 0x11 * colour
    ld e,a

    ex (sp),hl ; restore the fillpointer and where we are going to jump to
    ret

    do_16
    do_16
    do_16
    do_16
    do_16
    do_16
    do_16
    do_16
    do_16
    do_16
    do_16
    do_16
    do_16
    do_16
    do_16
    do_16

.line_end:
    srl d   ; if d is even the no extra nibble
    ret nc

    ld a,(hl)
    and $0f
    ld d,a      ; save 2nd nibble
    ld a,$f0
    and e        ; 1st nibble is the colour
    or d
    ld (hl),a

    ret  








