   OPT Z80
    OPT ZXNEXTREG  

   org $8000
IM_2_Table:
    dw vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl
    dw vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl
    dw vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl
    dw vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl
    dw vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl
    dw vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl
    dw vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl
    dw vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl,vbl
    dw vbl

init_vbl:
    di
    nextreg $22,%110
    nextreg $23,192
    im 2
    ld a, IM_2_Table>>8
    ld i,a
    ei
    ret

irq_counter: db 0
irq_last_count: db 0

wait_vbl:
    ld a,2
    out ($fe),a
    halt
    ld a,(irq_counter)
    ld (irq_last_count),a
    ld a,0
    ld (irq_counter),a

    out ($fe),a
    ret
    
    org $8181

vbl:
    di
    push af
    push hl
    ld hl,irq_counter
    inc (hl)
    pop hl
    pop af
    ei
    reti

