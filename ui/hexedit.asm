hex_editor:
    ; Set corelib menu
    in a, (2) ; Check flash
    bit 2, a
    jr z, _
    kld(hl, hexedit_corelib_menu_flash_unlocked)
    kld((corelib_menu), hl)
    jr ++_
_:
    kld(hl, hexedit_corelib_menu_flash_locked)
    kld((corelib_menu), hl)
_:
    kld(hl, hexedit_corelib_menu_actions)
    kld((corelib_menu + 2), hl)

.redraw:
    kcall(drawMainWindow)
    kcall(draw_hex_page)
.loop:
    pcall(fastCopy)
    ld b, a
    pcall(flushKeys)
    pcall(waitKey)
    cp kClear
    kjp(z, menu_main)
    cp kF3
    kcall(z, sys_showMenu)
    jr z, .redraw
    cp kDown
    jr z, .down
    cp kUp
    jr z, .up
    cp kLeft
    kjp(z, .left)
    cp kRight
    kjp(z, .right)
    jr .loop
.down:
    kld(hl, hexedit_offset)
    ld a, (hl)
    add a, 8
    ld (hl), a
    bit 6, a ; Check for overflow
    jr z, .redraw
    ld a, (hl)
    add a, -8
    ld (hl), a
    kld(hl, (hexedit_address))
    ld bc, 8
    add hl, bc
    kld((hexedit_address), hl)
    jr .redraw
.up:
    kld(hl, hexedit_offset)
    ld a, (hl)
    add a, -8
    ld (hl), a
    bit 6, a ; Check for overflow
    jr z, .redraw
    ld a, (hl)
    add a, 8
    ld (hl), a
    kld(hl, (hexedit_address))
    ld bc, -8
    add hl, bc
    kld((hexedit_address), hl)
    jr .redraw
.left:
    kld(hl, hexedit_offset)
    ld a, (hl)
    dec a
    ld (hl), a
    bit 6, a ; Check for overflow
    kjp(z, .redraw)
    ld a, 7
    ld (hl), a
    kld(hl, (hexedit_address))
    ld bc, -8
    add hl, bc
    kld((hexedit_address), hl)
    kjp(.redraw)
.right:
    kld(hl, hexedit_offset)
    ld a, (hl)
    inc a
    ld (hl), a
    bit 6, a ; Check for overflow
    kjp(z, .redraw)
    ld a, 64 - 8
    ld (hl), a
    kld(hl, (hexedit_address))
    ld bc, -8
    add hl, bc
    kld((hexedit_address), hl)
    kjp(.redraw)

draw_hex_page:
    ld de, 0x0208
    kld(hl, (hexedit_address))
    ld b, 8
.outer_loop:
    pcall(drawHexHL)
    ld a, ':' \ pcall(drawChar)
    ld a, 4
    add a, d
    ld d, a
    push bc
        ld b, 8
.inner_loop:
        ld a, (hl)
        inc hl
        kcall(.drawEntry)
        djnz .inner_loop
    pop bc
    pcall(newline)
    ld d, 2
    djnz .outer_loop
    ; Highlight selected value
    kld(a, (hexedit_offset))
    ld c, a
    rra \ rra \ rra ; A /= 8
    and 0b00011111
    add a, a \ ld b, a \ add a, a \ add a, b ; A *= 6
    add a, 8
    ld l, a ; Y
    ld a, c
    and 0b111
    ld c, a
    add a, a \ add a, a \ add a, a \ add a, c
    add a, 23
    ld e, a ; X
    ld bc, (5 << 8) + 9
    pcall(rectXOR)
    ret
.drawEntry:
    push de
    push hl
        kld(hl, hexedit_display_mode)
        bit 0, (hl)
        jr z, .hex
        cp 0x20
        jr c, .special
        cp 0x7F
        jr nc, .special
        pcall(drawChar)
        jr .cont
.special:
        ld a, '_'
        pcall(drawChar)
        jr .cont
.hex:
        pcall(drawHexA)
.cont:
    pop hl
    pop de
    ld a, 9
    add a, d
    ld d, a
    ret

hexedit_address:
    .dw 0
hexedit_offset:
    .db 0
hexedit_display_mode:
    .db 0

hexedit_toggle_flash:
    in a, (2) ; Check flash
    bit 2, a
    jr z, .unlock
    pcall(lockFlash)
    kjp(hex_editor)
.unlock:
    kcall(confirm_dangerous)
    kjp(nz, hex_editor)
    pcall(unlockFlash)
    kjp(hex_editor)

hexedit_switch_display:
    kld(hl, hexedit_display_mode)
    inc (hl)
    kjp(hex_editor)

hexedit_corelib_menu_flash_locked:
    .db 65 ; Width of menu
    .db 6
    .db "Go to address", 0
    .db "Memory banks", 0
    .db "Unlock Flash", 0
    .db "Switch mode", 0
    .db "Disassemble here", 0
    .db "Back to home", 0
hexedit_corelib_menu_flash_unlocked:
    .db 65 ; Width of menu
    .db 6
    .db "Go to address", 0
    .db "Memory banks", 0
    .db "Lock Flash", 0
    .db "Switch mode", 0
    .db "Disassemble here", 0
    .db "Back to home", 0
hexedit_corelib_menu_actions:
    .dw menu_main ;.dw hexedit_goto
    .dw menu_main ;.dw hexedit_banks
    .dw hexedit_toggle_flash
    .dw hexedit_switch_display
    .dw menu_main ;.dw hexedit_disassemble
    .dw menu_main
