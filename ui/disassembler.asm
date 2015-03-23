disassembler:
.redraw:
    kcall(drawMainWindow)
    kcall(drawDasm)
.loop:
    pcall(fastCopy)
    pcall(flushKeys)
    corelib(appWaitKey)
    cp kClear
    kjp(z, menu_main)
    cp kF3
    kcall(z, sys_showMenu)
    jr z, .redraw
    cp kDown
    jr z, .down
    cp kUp
    jr z, .up
    cp kH
    kjp(z, dasm_hexedit)
    jr .loop
.down:
    kld(hl, (dasm_address))
    kld(a, (first_width))
    ld c, a
    ld b, 0
    add hl, bc
    kld((dasm_address), hl)
    jr .redraw
.up:
    kld(hl, (dasm_address))
    dec hl
    kld((dasm_address), hl)
    jr .redraw

dasm_address:
    .dw 0
first_width:
    .db 0
jump_point:
    .dw 0

dasm_jump_context:
    kld(hl, (jump_point))
    kld((dasm_address), hl)
    kjp(disassembler)

dasm_hexedit:
    kld(hl, (dasm_address))
    kld((hexedit_address), hl)
    kjp(hex_editor)

drawDasm:
    kld(hl, dasm_corelib_menu_no_jump)
    kld((corelib_menu), hl)
    kld(hl, dasm_corelib_menu_actions_no_jump)
    kld((corelib_menu + 2), hl)

    ld de, 0x0208
    kld(hl, (dasm_address))
    ld b, 8
.loop:
    pcall(drawHexHL)
    ld a, ':' \ pcall(drawChar)
    ld a, 4 \ add a, d \ ld d, a

    ld a, (hl)
    inc hl
    push bc
    push hl
    push de
        ; TODO: Check for prefixes here
        kld(de, main_series_strings)
        add a, a \ jr nc, $+3 \ inc d
        add a, e \ ld e, a \ jr nc, $+3 \ inc d
        ex de, hl
        ld e, (hl) \ inc hl \ ld d, (hl)
        ex de, hl
        kld(de, 0)
        add hl, de
        ld a, (hl)
        cp inst_simple
        kjp(z, .draw_simple)
        cp inst_imm8
        kjp(z, .draw_imm8)
        cp inst_imm16
        kjp(z, .draw_imm16)
        cp inst_imms8
        kjp(z, .draw_imms8)
.cont:
    pop de
    pop hl
    pop bc
    pcall(newline)
    ld d, 2
    djnz .loop
    ret
    ; TODO: Merge instruction formats and do something more clever than this
.draw_imm8:
        ld a, b
        cp 8
        jr nz, _
        ld a, 2 \ kld((first_width), a)
_:
        pop de
        inc hl
        pcall(drawStr)
        xor a \ ld b, 1 \ cpir
        ld b, h \ ld c, l
        pop hl
    ld a, (hl)
    inc hl
        push hl
        pcall(drawHexA)
        ld h, b \ ld l, c
        pcall(drawStr)
        push de
        jr .cont
.draw_imm16:
        ld a, b
        cp 8
        jr nz, _
        ld a, 3 \ kld((first_width), a)
_:
        inc hl
        pop de
        pcall(drawStr)
        pop hl
        ld a, b
        ld c, (hl) \ inc hl
        ld b, (hl) \ inc hl
        push hl
        cp 8
        kcall(z, .setGOTO)
        ld h, b \ ld l, c
        pcall(drawHexHL)
        push de
        kjp(.cont)
.draw_imms8:
        ld a, b
        cp 8
        jr nz, _
        ld a, 2 \ kld((first_width), a)
_:
        pop de
        inc hl
        pcall(drawStr)
        pop hl
        ld a, (hl)
        inc hl
        push hl
        add a, l \ ld l, a \ jr nc, $+3 \ inc h
        pcall(drawHexHL)
        push de
        kjp(.cont)
.draw_simple:
        ld a, b
        cp 8
        jr nz, _
        ld a, 1 \ kld((first_width), a)
_:
        pop de \ push de
        inc hl
        pcall(drawStr)
        kjp(.cont)
.setGOTO:
    kld((jump_point), bc)

    kld(hl, dasm_corelib_menu_jump)
    kld((corelib_menu), hl)
    kld(hl, dasm_corelib_menu_actions)
    kld((corelib_menu + 2), hl)

    kld(hl, jumpPoint@dasm_corelib_menu_jump)
    ; Write address into corelib menu
    ld a, b
    and 0xF0 \ rrca \ rrca \ rrca \ rrca \ and 0xF
    kcall(.drawDigit)
    ld a, b
    and 0xF
    kcall(.drawDigit)
    ld a, c
    and 0xF0 \ rrca \ rrca \ rrca \ rrca \ and 0xF
    kcall(.drawDigit)
    ld a, c
    and 0xF
    kcall(.drawDigit)
    ret
.drawDigit:
    push hl
        kld(hl, .hex)
        add a, l \ ld l, a \ jr nc, $+3 \ inc h
        ld a, (hl)
    pop hl
    ld (hl), a
    inc hl
    ret
.hex:
    .db "0123456789ABCDEF"

dasm_corelib_menu_no_jump:
    .db 64
    .db 5
    .db "Go to address", 0
    .db "Go to thread", 0
    .db "Hex edit here", 0
    .db "Marks", 0
    .db "Back to home", 0
dasm_corelib_menu_jump:
    .db 64
    .db 6
    .db "Jump to 0x"
.jumpPoint:
    .db "0000", 0
    .db "Go to address", 0
    .db "Go to thread", 0
    .db "Hex edit here", 0
    .db "Marks", 0
    .db "Back to home", 0
dasm_corelib_menu_actions:
    .dw dasm_jump_context
dasm_corelib_menu_actions_no_jump:
    .dw menu_main;.dw dasm_goto_address
    .dw menu_main;.dw dasm_goto_thread
    .dw dasm_hexedit
    .dw menu_main;.dw dasm_marks
    .dw menu_main

#include "core/dasm_data.asm"
