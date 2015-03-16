#include "kernel.inc"
#include "corelib.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 20
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END
name:
    .db "calcsys", 0
start:
    kcall(init)
    kjp(menu_main)

init:
    pcall(getLcdLock)
    pcall(getKeypadLock)
    kld(de, corelibPath)
    pcall(loadLibrary)
    pcall(allocScreenBuffer)
    ret

exit:
    pcall(exitThread)

drawMainWindow:
    kld(hl, windowTitle)
    ld a, 0b00000100 ; Draw window with a menu
    corelib(drawWindow)
    ret

confirm_dangerous:
    kld(hl, dangerous_text)
    kld(de, dangerous_options)
    ld b, 0
    xor a
    corelib(showMessage)
    cp 1
    ret

; Shows the menu currently loaded into corelib_menu
sys_showMenu:
    kld(hl, (corelib_menu))
    ld c, (hl)
    inc hl
    corelib(showMenu)
    cp 0xFF
    ret z
    add a, a
    kld(hl, (corelib_menu + 2))
    add a, l \ ld l, a \ jr nc, $+3 \ inc h
    ld e, (hl) \ inc hl \ ld d, (hl)
    pop hl
    ex de, hl
    kld(bc, 0)
    add hl, bc
    jp (hl)

prompt_hex_8:
    ld a, charsetHex
    corelib(setCharSet)
    ld bc, 4
    kld(ix, zero_x_text)
    ld a, '0'
    ld (ix + 0), a
    ld a, 'x'
    ld (ix + 1), a
    xor a
    ld (ix + 2), a
    ld (ix + 3), a
    corelib(promptString)
    xor a
    corelib(setCharSet)
    ret

zero_x_text:
    .db "0x", 0, 0, 0

corelib_menu:
    .dw menu_main_corelib_menu
    .dw menu_main_corelib_menu_actions

#include "ui/main.asm"
#include "ui/hexedit.asm"
#include "ui/disassembler.asm"
#include "ui/portmon.asm"

corelibPath:
    .db "/lib/core", 0
windowTitle:
    .db "CalcSys", 0
caret_icon:
    .db 0b10000000
    .db 0b11000000
    .db 0b11100000
    .db 0b11000000
    .db 0b10000000
dangerous_text:
    .db "This action may be\ndangerous.\nContinue?", 0
dangerous_options:
    .db 2, "No", 0, "Yes", 0
