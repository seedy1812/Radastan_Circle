    ;; -----------------------------------------------

    ;; Circle (x,y,r) routine

cx: db    0
cy: db    0       ; center
cr: db    0       ; radius


circle:
    push    af
    push    bc
    push    de
    push    hl      ; keep registers.
    push    iy

    ;; (b,c) stores the current arc point coordinates (x,y)
    ld      a,(cr)
    ld      b,a     ; x = r
    ld      c,0     ; y = 0
    ld      hl,0    ; error = 0 (I need 16 bits)

    ld      a,(cx)
    ld      d,a
    ld      a,(cy)
    ld      e,a     ; (d,e) contains the center coordinates (xc, yc)

    ld      a,b
    and     a
    jp      z,.outloop   ; if radius = 0, we exit

.loop:

    ld      a,d
    add     a,b
    cp      128
    jr      c,._xlt128
    ld      a,128
 ._xlt128:
    ld      ixl,a       ; xo - x

    ld      a,d
    sub     b
    jr      nc,.xgt0
    ld      a,0
.xgt0:
    ld      ixh,a       ; xo + x

    ld      a,e
    add     a,c
   ; ld      (y),a       ; yo + y
    ld iyl,a
    call    line_span        ; (xo + x, yo + y) quarter 2/4

;/////////////////////////////////////////

    ld      a,e
    sub     c

 ;   ld      (y),a       ; yo - y
    ld iyl,a
    call    line_span       ; (xo + x, yo - y) ; qauter 2/4

    ;; ---------------------

    ld      a,d
    sub     c
    jr      nc,.xgt0y
    ld      a,0
.xgt0y:
    ld      ixh,a       ; xo - y
  

    ld      a,d
    add     a,c
    cp      128
    jr      c,._xlt128y
    ld      a,128
 ._xlt128y:  
    ld      ixl,a       ; xo + y

    ld      a,e
    add     a,b

 ;   ld      (y),a       ; yo + y
    ld iyl,a
    call    line_span   ;bottom 4/4


    ld      a,e
    sub     b

  ;  ld      (y),a       ; yo - y
    ld iyl,a
    call    line_span       ; (xo + x, yo - x) ; top 1/4


    ld      a,c
    add     hl,a
    add     hl,a
    inc     hl      ; error += 1 + 2*y
    inc     c       ; y++


    push    de
    push    hl
    ld      e,b
    ld      d,0
    and     a           ; clear carry flag
    sbc     hl,de       ; error - x
    dec     hl
    bit     7,h         ; is error - x <= 0 ?
    pop     hl
    jr      nz,.skip1    ; if error - x <= 0, skip

    and     a
    sbc     hl,de
    sbc     hl,de
    inc     hl          ; error += 1 - 2*x
    dec     b       ; x--

.skip1:
    pop     de      

    ld      a,b
    cp      c       ; if y >= x, then exit
    jp      nc,.loop

.outloop:
    pop     iy
    pop     hl
    pop     bc
    pop     de
    pop     af      ; recovers former register values.
    ret


; iyl = y
; ixh = x1
; ixl = x2

line_span:
    ld a,iyl
    cp     96                  ; only draw is y < 192
    ret nc

    exx

    ld d,64
    ld e,iyl
    mul

    ld hl,(back_buffer)
    add hl,de

    ld c,ixh

    ld a,ixl
    ld d,a

    cp c
    jr c,.same
    
    ld a,(rainbow)
    ld e,a


    call line16_draw


;; c = start x
;; d = end x
;; e = value to fill
;; hl = start of line
.same:
    exx
 
    ret
