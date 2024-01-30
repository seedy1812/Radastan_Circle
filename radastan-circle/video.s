VIDEO_LORES_PALETTE_MASK        equ     %00001111
VIDEO_LORES_DFILE0              equ     %00000000
VIDEO_LORES_DFILE1              equ     %00010000
VIDEO_RADASTAN_ACTIVE_NO        equ     %00000000
VIDEO_RADASTAN_ACTIVE_YES       equ     %00100000



CR_6A:   db 0


video_setup:
        ld d,$6A
        call get_CR
        ld (CR_6A),a

        ld d,$68
        call get_CR
        or %100
        nextreg 68,a

         ld b, 0
        call video_set_LORES_pallete

;        ld b, VIDEO_LORES_DFILE0
;        call video_set_LORES_DFile

        ld b, VIDEO_RADASTAN_ACTIVE_YES
        call video_set_LORES_Enable
        
        nextreg $15,%10000011 ; low rez , LSU , over border , sprite visible :: Sprite and Layer System Setup

        ret


;video_inc_Palette
        ld a,(CR_6A)
        inc a
        and VIDEO_LORES_PALETTE_MASK
        ld b,a
        ld a,(CR_6A)
        and ~VIDEO_LORES_PALETTE_MASK
        jr video_set_LORES_write

;video_swap_DFILE:
        ld a,(CR_6A)
        xor VIDEO_LORES_DFILE1
        ld b,0
;       jr video_set_LORES_write

video_swap:
        ld a,(back_buffer_DFILE)
        ld b,a
        ld a,(CR_6A)
        and ~VIDEO_LORES_DFILE1
        or b
        nextreg $6a,a
        ld (CR_6A),a
        ret






video_set_LORES_Enable:
        ld a,(CR_6A)
        and  %11011111
        jr video_set_LORES_write


;video_set_LORES_DFile:
        ld a,(CR_6A)
        and  %11101111
        jr video_set_LORES_write

video_set_LORES_pallete:
        ld a,(CR_6A)
        and  %11110000
video_set_LORES_write:
        or b
        nextreg $6a,a
        ld (CR_6A),a
        ret


cls:
        ld      hl,(back_buffer)
        ld      (dma_buffer),hl
        ; transfer the DMA "program" to the port
        ld      hl,CLSDMA_Start
        ld      b,CLSDMA_End - CLSDMA_Start
        ld      c,DMA_PORT
        otir
        ret


;set_screen_page:
    ld bc, $123b   
    or %1011      ; shadow layer2 , is visible and layer 2 write paging
    out (c), a
    ret

FillDMA_SourceValue  db 0

CLSDMA_Start:  ; set zero from address 0
        db $83
        db  %01111101                           ; R0-Transfer mode, A -> B
        dw  FillDMA_SourceValue                 ; R0-Port A, Start address (source)
        dw  128*96                                           ; R0-Block length

        db  %00100100                    ; R1 - A fixed memory

        db  %00010000                    ; R2 - B incrementing memory

        db      %10101101                 ; R4-Continuous
dma_buffer:
        dw      $0000                     ; R4-Block Address

        db      $cf                                                     ; R6 - Load
        db      $87                                                     ; R6 - enable DMA;
CLSDMA_End:


copy_backdrop:
        ld bc , 96*(128/2)
        ld hl,xenon1_slr
        ld de,(back_buffer)
        ldir
        ret;

flip_screens:

        ld a,1
        call bcd_add_byte

        call reset_sprite_index
        
        call draw_irq_counter

        call bcd_draw

        call palette_add_sprites

        call draw_dx_dy

        call draw_circle_info

        ret



back_buffer_DFILE db VIDEO_LORES_DFILE1
back_buffer:    dw $4000
front_buffer:   dw $6000

swap_buffers:
        push hl
        push de

        ld hl,(back_buffer)
        ld bc,(front_buffer)

        ld a,(back_buffer_DFILE)
        xor VIDEO_LORES_DFILE1
        ld (back_buffer_DFILE),a


        ld (front_buffer),hl
        ld (back_buffer),bc

        call video_swap 

        pop de
        pop hl
        ret
