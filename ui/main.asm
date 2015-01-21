menu_main:
    ; Set corelib menu
    kld(hl, menu_main_corelib_menu)
    kld((corelib_menu), hl)
    kld(hl, menu_main_corelib_menu_actions)
    kld((corelib_menu + 2), hl)

.redraw:
    kcall(drawMainWindow)
    ld de, 0x0608
    ld b, 6
    kld(hl, menu_main_text)
    pcall(drawStr)
    xor a
    kcall(.drawCaret)
.loop:
    pcall(fastCopy)
    ld b, a
    pcall(flushKeys)
    corelib(appWaitKey)
    cp kMODE
    kjp(z, exit)
    cp kF3
    kcall(z, sys_showMenu)
    jr z, .redraw
    cp kUp
    jr z, .up
    cp kDown
    jr z, .down
    cp kEnter
    jr z, .enter
    cp k2nd
    jr z, .enter
    jr .loop
.up:
    ld a, b
    or a ; cp 0
    jr z, .loop
    kcall(.drawCaret)
    dec a
    kcall(.drawCaret)
    jr .loop
.down:
    ld a, b
    cp (end@menu_main_options - menu_main_options) / 2 - 1
    jr z, .loop
    kcall(.drawCaret)
    inc a
    kcall(.drawCaret)
    jr .loop
.enter:
    ld a, b
    add a, a
    kld(hl, menu_main_options)
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld e, (hl) \ inc hl \ ld d, (hl)
    ex de, hl
    kld(bc, 0)
    add hl, bc
    jp (hl)
.drawCaret:
    kld(hl, caret_icon)
    ld d, 2
    ld e, 8
    push af
        add a, a
        ld b, a
        add a, a
        add a, b ; A *= 6
        add a, e
        ld e, a
    pop af
    ld b, 5
    pcall(putSpriteXOR)
    ret

menu_main_text:
    .db "Hex Editor\n"
    .db "Disassembler\n"
    .db "Port Monitor\n"
    .db "Filesystem\n"
    .db "Help\n"
    .db "Exit", 0
menu_main_options:
    .dw hex_editor
    .dw exit ;.dw disassembler
    .dw exit ;.dw port_monitor
    .dw exit ;.dw filesystem
    .dw exit ;.dw help
    .dw exit
.end:
menu_main_corelib_menu:
    .db 20 ; Width of menu
    .db 1
    .db "Exit", 0
menu_main_corelib_menu_actions:
    .dw exit
