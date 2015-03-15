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
    cp kLeft
    jr z, .left
    cp kRight
    jr z, .right
    jr .loop
.down:
    kld(a, (portmon_selection))
    add a, 4
    kld((portmon_selection), a)
    kcall(.try_scroll)
    jr port_monitor
.up:
    kld(a, (portmon_selection))
    or a ; cp 0
    jr z, port_monitor
    add a, -4
    kld((portmon_selection), a)
    kcall(.try_scroll)
    jr port_monitor
.left:
    kld(a, (portmon_selection))
    dec a
    kld((portmon_selection), a)
    kcall(.try_scroll)
    jr port_monitor
.right:
    kld(a, (portmon_selection))
    inc a
    kld((portmon_selection), a)
    kcall(.try_scroll)
    jr port_monitor
.try_scroll:
    ; If offset is 0x20 away from selection, scroll
    kld(a, (portmon_offset))
    ld b, a
    kld(a, (portmon_selection))
    sub b
    jr c, .scroll_up
    cp 0x20
    jr z, .scroll_down
    ret
.scroll_down:
    kld(a, (portmon_offset))
    add a, 4
    kld((portmon_offset), a)
    ret
.scroll_up:
    kld(a, (portmon_offset))
    add a, -4
    kld((portmon_offset), a)
    ret

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
    ; Draw selection
    kld(a, (portmon_offset))
    ld b, a
    kld(a, (portmon_selection))
    sub b
    ld d, a
    ld e, 4
    pcall(div8by8) ; A -> remainder, D -> result
    add a, a \ add a, a \ add a, a \ ld b, a \ add a, a \ add a, b
    add a, 1
    ld e, a ; X

    ld a, d
    add a, a \ ld b, a \ add a, a \ add a, b ; A *= 6
    add a, 8
    ld l, a ; Y

    ld bc, (5 << 8) + 21 ; Width, height
    
    pcall(rectXOR)
    ret
.col:
    ld d, 2
    ld b, 4
.loop:
    ld a, c
    pcall(drawHexA)
    ld a, '='
    pcall(drawChar)
    in a, (c)
    pcall(drawHexA)
    inc c
    ld a, 4
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
portmon_selection:
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
