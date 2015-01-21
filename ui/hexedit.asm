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
    jr .loop
.down:
    kld(hl, (hexedit_address))
    ld bc, 8
    add hl, bc
    kld((hexedit_address), hl)
    jr .redraw
.up:
    kld(hl, (hexedit_address))
    ld bc, -8
    add hl, bc
    kld((hexedit_address), hl)
    jr .redraw

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
        pcall(drawHexA)
        ld a, ' ' \ pcall(drawChar)
        djnz .inner_loop
    pop bc
    pcall(newline)
    ld d, 2
    djnz .outer_loop
    ret

hexedit_address:
    .dw 0
hexedit_offset:
    .dw 0

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

hexedit_corelib_menu_flash_locked:
    .db 55 ; Width of menu
    .db 4
    .db "Go to address", 0
    .db "Memory banks", 0
    .db "Unlock Flash", 0
    .db "Back", 0
hexedit_corelib_menu_flash_unlocked:
    .db 55 ; Width of menu
    .db 4
    .db "Go to address", 0
    .db "Memory banks", 0
    .db "Lock Flash", 0
    .db "Back", 0
hexedit_corelib_menu_actions:
    .dw menu_main ;.dw hexedit_goto
    .dw menu_main ;.dw hexedit_banks
    .dw hexedit_toggle_flash
    .dw menu_main
