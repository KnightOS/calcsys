port_monitor:
    kcall(drawMainWindow)
    kcall(draw_portmon)
    pcall(fastCopy)
.loop:
    pcall(flushKeys)
    corelib(appWaitKey)
    cp kF3
    kcall(z, sys_showMenu)
    cp kDown
    jr z, .down
    cp kUp
    jr z, .up
    jr .loop
.down:
    kld(a, (portmon_offset))
    add a, 4
    kld((portmon_offset), a)
    jr port_monitor
.up:
    kld(a, (portmon_offset))
    add a, -4
    kld((portmon_offset), a)
    jr port_monitor

draw_portmon:
    in a, (2) ; Check flash
    bit 2, a
    jr z, _
    kld(hl, portmon_corelib_menu_flash_unlocked)
    kld((corelib_menu), hl)
    jr ++_
_:
    kld(hl, portmon_corelib_menu_flash_locked)
    kld((corelib_menu), hl)
_:
    kld(hl, portmon_corelib_menu_actions)
    kld((corelib_menu + 2), hl)

    kld(a, (portmon_offset))
    ld c, a
    ld e, 6 * 1 + 2
    kcall(.col)
    ld e, 6 * 2 + 2
    kcall(.col)
    ld e, 6 * 3 + 2
    kcall(.col)
    ld e, 6 * 4 + 2
    kcall(.col)
    ld e, 6 * 5 + 2
    kcall(.col)
    ld e, 6 * 6 + 2
    kcall(.col)
    ld e, 6 * 7 + 2
    kcall(.col)
    ld e, 6 * 8 + 2
    kcall(.col)
    ret
.col:
    ld d, 2
    ld b, 4
.loop:
    ld a, c
    pcall(drawHexA)
    ld a, ':'
    pcall(drawChar)
    in a, (c)
    pcall(drawHexA)
    inc c
    ld a, 7
    add a, d
    ld d, a
    djnz .loop
    ret

portmon_toggle_flash:
    in a, (2) ; Check flash
    bit 2, a
    jr z, .unlock
    pcall(lockFlash)
    kjp(port_monitor)
.unlock:
    kcall(confirm_dangerous)
    kjp(nz, hex_editor)
    pcall(unlockFlash)
    kjp(port_monitor)

portmon_offset:
    .db 0

portmon_corelib_menu_flash_locked:
    .db 65 ; Width of menu
    .db 2
    .db "Unlock Flash", 0
    .db "Back to home", 0
portmon_corelib_menu_flash_unlocked:
    .db 65 ; Width of menu
    .db 2
    .db "Lock Flash", 0
    .db "Back to home", 0
portmon_corelib_menu_actions:
    .dw portmon_toggle_flash
    .dw menu_main
