;Calcsys 1.1
;By Dan Englender
;Feel free to use anything from this source, just send me an email (alfix97@hotmail.com) and
; let me know


#include "ti83plus.inc"
 .addinstr BCALL *       EF   3 NOP 1
#define	linkwait		$6000				; link timeout
#define	numcbregcmds	cbregstr-cbregcmds
#define	numcbregregcmds	cbregregstr-cbregregcmds
#define	freeram	appbackupscreen
#define curback appbackupscreen+10
#define	flagscreen	appbackupscreen+20
#define	tempflag	appbackupscreen+21
#define	port		appbackupscreen
#define	oldport		appbackupscreen+1
#define	oldportval	appbackupscreen+2
#define tempnum appbackupscreen+20
#define	flagoffset	appbackupscreen
#define hexaddr appbackupscreen+30
#define	logaddr	appbackupscreen+40
#define	rompage	appbackupscreen+42
#define	daddr	appbackupscreen+44
#define	instraddr	appbackupscreen+46
#define	backaddr	appbackupscreen+51
#define	hexaddrs	appbackupscreen+53
#define	rompaged	appbackupscreen+55
#define	conaf		appbackupscreen+57		;virtual registers...
#define	conbc		appbackupscreen+59
#define	conde		appbackupscreen+61
#define	conix		appbackupscreen+63
#define	conhl		appbackupscreen+65
#define	temp16	appbackupscreen+67
#define	vattable	appbackupscreen+69
#define	curvataddr	appbackupscreen+154
#define	vatlastaddr	appbackupscreen+156
#define	vatvataddr	appbackupscreen+158
#define	vatcodeaddr	appbackupscreen+160
#define	vatrompage	appbackupscreen+162
#define	data		appbackupscreen+162
#define	apdram	appbackupscreen+164
#define	strbuf	appbackupscreen+164
#define	textbuf	appbackupscreen+300
#define	command	appbackupscreen+450		;used for parsing
#define	args		appbackupscreen+600
;#define	command	savesscreen
#define	gbuf		plotsscreen
;#define	args	savesscreen+256
#define	argument	args
#define	arg	args					
#define	portflags	33			; custom flags
#define	gethexflags	33
#define	disasmflags	33
#define	vatflags	33
#define	iyflags	33
#define	saveflags	35			; link display options
#define	typetype	0
#define	linkb		1
#define	linkc		2
#define	portlog		0
#define	logenabled	1
#define	gethexnoback	2
#define	fastdisasm		3
#define	vatpoop		4
#define	dasmix		5
.org $4000

;------header--------
 .db 080h,0Fh    ;Field: Program length
 .db   00h,0h,00h,00h ;Length=0 (N/A for unsigned apps)
 .db 080h,012h    ;Field: Program type
 .db 1,4
 .db 080h,021h    ;Field: App ID
 .db   01h       ;Id = 1
 .db 080h,031h    ;Field: App Build
 .db   01h       ;Build = 1
 .db 080h,048h    ;Field: App Name
 .db "Calcsys "
 .db 080h,081h    ;Field: App Pages
 .db 01h         ;App Pages = 1
 .db 080h,090h    ;No default splash screen
 .db 03h,026h ,09h,04h, 04h,06fh,01bh,80h     ;Field: Date stamp- 5/12/1999
 .db 02h,0dh,040h                             ;Dummy encrypted TI date stamp signature
 .db 0a1h ,06bh ,099h ,0f6h ,059h ,0bch ,067h 
 .db 0f5h ,085h ,09ch ,09h ,06ch ,0fh ,0b4h ,03h ,09bh ,0c9h 
 .db 03h ,032h ,02ch ,0e0h ,03h ,020h ,0e3h ,02ch ,0f4h ,02dh 
 .db 073h ,0b4h ,027h ,0c4h ,0a0h ,072h ,054h ,0b9h ,0eah ,07ch 
 .db 03bh ,0aah ,016h ,0f6h ,077h ,083h ,07ah ,0eeh ,01ah ,0d4h 
 .db 042h ,04ch ,06bh ,08bh ,013h ,01fh ,0bbh ,093h ,08bh ,0fch 
 .db 019h ,01ch ,03ch ,0ech ,04dh ,0e5h ,075h 
 .db 80h,7Fh      ;Field: Program Image length
 .db   0,0,0,0    ;Length=0, N/A
 .db   0,0,0,0    ;Reserved
 .db   0,0,0,0    ;Reserved
 .db   0,0,0,0    ;Reserved
 .db   0,0,0,0    ;Reserved
;-------------------------

;	ld	hl,generalerrorh
;	call	$59
start:
	ld	hl,appbackupscreen
	ld	bc,767
	bcall	_memclear

	ld	a,1
	ld	(rompage),a
	ld	(rompaged),a
	
mainmenu:
	call	fixnstuffs
	call	prepscreen
	ld	hl,mainmenutext
	call	disptextm
mainmenuloop
	call	getkey
	sub	143
	jp	z,hexeditor
	dec	a
	jp	z,disasm
	dec	a
        jp      z,portmon
        dec		a
        jp      z,sysflags
        dec	a
	jp	z,console
	dec	a
	jp	z,mainmenu2
	dec	a
	jp	z,quit
	jr	mainmenuloop
fixnstuffs:
	res	gethexnoback,(iy+gethexflags)
	res	shiftalock,(iy+shiftflags)
	res	shiftalpha,(iy+shiftflags)
	res	appautoscroll,(iy+appflags)
	ret
mainmenu2:
	call	fixnstuffs
	call	prepscreen
	ld	hl,mainmenu2text
	call	disptextm
mainmenu2loop:
	call	getkey
	sub	143
	jp	z,dispvat
	dec	a
	jp	z,charlist
	dec	a
	jp	z,keyvalmenu
	dec	a
	jp	z,linker
	dec	a
	jp	z,about
	dec	a
	jr	z,mainmenu
	dec	a
	jp	z,quit
	jr	mainmenu2loop
;generalerrorh:
;	call	prepscreen
;	ld	hl,generrorscreen
;	call	disptext
;	ld	hl,10*256
;	ld	(currow),hl
;	ld	a,(errno)
;	call	disphex
;	ld	hl,generalerrorh
;	call	$59
;generrorhloop:
;	call	getkey
;	cp	143
;	jp	z,quit
;	cp	144
;	jp	z,$4080
;	jr	generrorhloop
keyvalmenu:

	call	prepscreen
	ld	hl,keyvalscreen
	call	disptextm
keyvalloop:
	set	appautoscroll,(iy+appflags)
	call	getkey

	sub	143
	jp	z,keyvgetkey
	dec	a
	jr	z,keyvgetcsc
	dec	a
	jr	z,keyvdi
	res	appautoscroll,(iy+appflags)
	dec	a
	jp	z,mainmenu2
	cp	9-143-1-1-1
	jp	z,mainmenu2
	jr	keyvalloop
keyvgetcsc:
	call	prepscreen
keyvgcscloop:
	call	isonpressed
	jr	nc,keyvalmenu
	bcall	_getcsc
	or	a
	jr	z,keyvgcscloop
	call	disphex
	bcall	_newline
	call	waitnokey
	jr	keyvgcscloop
isonpressed:
	in	a,(4)
	rra
	rra
	rra
	rra
	ret
waitnokey:
	ld	a,$FF
	out	(1),a
	ld	a,0
	out	(1),a
waitnokeyloop:
	in	a,(1)
	cp	255
	jr	nz,waitnokeyloop
	ret	


	bcall	_getkey
	or	a
	jp	z,keyvalmenu
	bcall	_newline
	ld	hl,0
	ld	(kbdscancode),hl
	ld	(kbdscancode+2),hl
	ld	(kbdscancode+4),hl
	ld	(kbdscancode+6),hl
	jr	keyvgcscloop
keyvdi:
	call	prepscreen
keyvdiloop:
keyvdiloopi:
	ld	b,7
	ld	a,$Fe
keyvdiloopi2:
	push	af
	out	(1),a
	in	a,(1)
	cp	255
	jr	nz,keyvdifound
	pop	af
	scf
	rla
	djnz	keyvdiloopi2
	call	isonpressed
	jp	nc,keyvalmenu
	jp	keyvdiloop
keyvdifound:
	pop	hl
	push	af
	push	hl
	ld	a,(currow)
	cp	7
	call	z,prepscreen
	ld	hl,discreen
	call	disptext
	pop	af
	call	disphex
	ld	hl,curcol
	inc	(hl)
	ld	hl,discreen2
	call	disptext
	pop	af
	call	disphex
	bcall	_newline
	call	waitnokey
	jp	keyvdiloop




;	xor	a
;	ld	(op5),a
;keyvdi2:
;	call	prepscreen
;keyvdiloop:
;	ld	b,7
;	ld	a,$Fe
;keyvdiloop2:
;	push	af
;	out	(1),a
;	in	a,(1)
;	cp	255
;	jr	nz,keyvdifound
;	pop	af
;	scf
;	rla
;	djnz	keyvdiloop2
;	ld	hl,op5
;	inc	(hl)
;	jr	keyvdiloop
;keyvdiold:
;	pop	af
;	pop	af
;	jr	keyvdi2
;keyvdifound:
;	push	af
;	ld	a,(op5)
;	or	a
;	jr	z,keyvdiold
;	ld	hl,discreen
;	call	disptext
;	pop	af
;	call	disphex
;	ld	hl,curcol
;	inc	(hl)
;	ld	hl,discreen2
;	call	disptext
;	pop	af
;	call	disphex
;;	bcall	_getcsc
;	call	getkey
;	bcall	_getkey
;	or	a
;	jp	z,keyvalmenu
;	bcall	_newline
;	jp	keyvdiloop
keyvgetkey:
	call	prepscreen
	call	getkey
	or	a
	jp	z,keyvalmenu
keyvgetkeyloop:
	call	disphex
	call	getkey
	or	a
	jp	z,keyvalmenu
	push	af
	bcall	_newline
	pop	af
	jr	keyvgetkeyloop
charlist:
	call	prepscreen
	ld	hl,charsetmenu
	call	disptextm
charsetloop:
	call	getkey
	cp	9
	jp	z,mainmenu2
	sub	143
	jp	z,charsetlarge
	dec	a
	jp	z,charsettoken
	dec	a
	jp	z,mainmenu2

	jr	charsetloop
charsetlarge:
	call	prepscreen
	ld	hl,characterscreen
	call	disptext
	ld	hl,7*256+1
	ld	(currow),hl
	call	getnumerich
	push	af
	call	prepscreen
	pop	af
	ld	hl,0
	ld	(pencol),hl
	set	fracdrawlfont,(iy+fontflags)
	push	af
	bcall	_vputmap
	res	fracdrawlfont,(iy+fontflags)
	pop	af
	ld	hl,9
	ld	(pencol),hl
	bcall	_vputmap
	call	getkey
	jp	charlist
charsettoken:
	call	prepscreen
	ld	hl,tokenscreen
	call	disptext
	ld	hl,12*256+1
	ld	(currow),hl
	call	getnumerich
	ld	(temp16),a
	ld	hl,13*256+2
	ld	(currow),hl
	call	getnumerich
	ld	e,a
	ld	a,(temp16)
	ld	d,a
	ld	hl,3
	ld	(currow),hl
	bcall	_puttokstring
	call	getkey
	jp	charlist

dispvat:
	call	prepscreen
	ld	hl,vatmenu
	call	disptextm
dispvatloop:
	call	getkey
	cp	9
	jp	z,mainmenu2
	sub	$8f
	jp	z,vatproglist
	dec	a
	jp	z,vatother
	dec	a
	jp	z,vatgotoprogptr
	dec	a
	jp	z,vatgotosymtab
	dec	a
	jp	z,mainmenu2	
	jr	dispvatloop
vatgotoprogptr:
	ld	hl,(progptr)
vatgotocont
	ld	(hexaddrs),hl
	jp	hexeditor
vatgotosymtab
	ld	hl,symtable
	jp	vatgotocont
;vatapplication:
;	call	prepscreen
;	ld	hl,flagsmenu
;	call	disptext
;	or	a
;	sbc	hl,hl
;	ld	(currow),hl
;	ld	hl,apptoptext
;	call	disptext
;	ld	b,$15
;	ld	hl,$4000
;	ld	de,vattable
;	ld	c,0
;vatapploop:
;	push	bc
;	bcall	_loadaindpaged
;	ld	a,c
;	cp	$80
;	pop	bc
;	jp	z,vatappfound
;	dec	b
;	ld	a,b
;	cp	8
;	jr	nz,vatapploop
;vatappfound:


vatother:
	set	vatpoop,(iy+vatflags)
	jr	vatreal
vatproglist:
	res	vatpoop,(iy+vatflags)
vatreal:
	ld	hl,(progptr)
	ld	(curvataddr),hl
	bit	vatpoop,(iy+vatflags)
	jr	z,vatc1
	ld	hl,symtable
	ld	(curvataddr),hl
vatc1:
vatdotables:
	call	prepscreen
	ld	hl,vatscreen
	call	disptextm


	call	genvattable
	call	dispvattable


vatproglistloop:
	call	getkey
	cp	$94
	jp	z,vatproglistnext
	cp	$95
	jp	z,dispvat
	cp	9
	jp	z,dispvat
	sub	$8f
	jp	z,vatproglistrun
	cp	1
	jp	z,vatproglistrun
	cp	2
	jp	z,vatproglistrun
	cp	3
	jp	z,vatproglistrun
	cp	4
	jp	z,vatproglistrun
	jr	vatproglistloop
vatproglistrun:
	ld	b,a
	ld	hl,vattable
	or	a
	jp	z,vatplrdone
vatproglistrunloop:
	push	bc
	call	nextvataddrb
	ld	a,(hl)
	pop	bc
	or	a
	jp	z,vatdotables
	djnz	vatproglistrunloop
vatplrdone:
	push	hl
	call	prepscreen
	ld	hl,vatinfoscreen
	call	disptextm
	pop	hl
	push	hl
	ld	de,7
	add	hl,de
	ld	a,(hl)
	pop	hl
	or	a
	jp	nz,vatplrarced
	ld	de,9*256+2
	ld	(currow),de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	push	hl
	ex	de,hl
	ld	(vatvataddr),hl
	call	disphexhl
	pop	hl
	ld	de,6*256
	ld	(currow),de
	ld	a,(hl)
	bit	typetype,(iy+saveflags)
	jr	z,vattypereg
	call	disphex
	jr	vatskiptype
vattypereg:
	and	%00011111
	inc	a
	ld	b,a

	push	hl
	ld	hl,vatdesc
	call	find0tab
	call	disptext
	pop	hl
vatskiptype:
	inc	hl
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	push	hl
	inc	de
	ld	a,(de)
	ld	hl,6*256+4
	ld	(currow),hl
	call	disphex
	dec	de
	ld	a,(de)
	call	disphex
	ld	hl,10*256+3
	ld	(currow),hl
	ex	de,hl
	ld	(vatcodeaddr),hl
	call	disphexhl
	pop	hl

	inc	hl

;	ld	a,(hl)
	xor	a
	ld	(vatrompage),a
;	or	a
;	jr	z,dispvatnorompage
;	ld	de,5
;	ld	(currow),de
;	push	hl
;	ld	hl,vatrompages
;	call	disptext
;	pop	hl
;	ld	a,(hl)
;	call	disphex
;dispvatnorompage:

	inc	hl
	inc	hl
	ld	de,6*256+1
	ld	(currow),de
	bit	vatpoop,(iy+vatflags)
	call	z,dispprogvatname
	bit	vatpoop,(iy+vatflags)
	jp	z,vatc6
	dec	hl
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	inc	hl
	push	hl
	bcall	_puttokstring
	pop	hl
	jp	vatc6

vatplrarced:
	ld	(vatrompage),a
;	push	hl
;	call	prepscreen
;	ld	hl,vatinfoscreen
;	call	disptext
;	pop	hl

	ld	de,9*256+2
	ld	(currow),de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	push	hl
	ex	de,hl
	ld	(vatvataddr),hl
	call	disphexhl
	pop	hl
;	ld	b,(hl)
;	and	%00011111
;	inc	b
	ld	de,6*256
	ld	(currow),de
	ld	a,(hl)
	bit	typetype,(iy+saveflags)
	jr	z,vatatypereg
	call	disphex
	jr	vataskiptype
vatatypereg:
	and	%00011111
	inc	a
	ld	b,a

	push	hl
	ld	hl,vatdesc
	call	find0tab
	call	disptext
	pop	hl
vataskiptype:
	inc	hl
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	push	hl

	ld	hl,9
	add	hl,de
	ld	a,(vatrompage)
	ld	b,a
	bcall	_loadcindpaged
	ld	e,c
	ld	d,0
	inc	e
	add	hl,de
	ld	de,10*256+3
	ld	(currow),de
	ld	(vatcodeaddr),hl
	push	bc
	push	hl
	call	disphexhl
	pop	hl
	pop	bc
	inc	hl
	ld	de,6*256+4
	ld	(currow),de
	
	bcall	_loadcindpaged
	ld	a,c

	
	call	disphex
	dec	hl
	bcall	_loadcindpaged
	ld	a,c
	call	disphex

	pop	hl

	inc	hl

	ld	a,(vatrompage)
	ld	de,5
	ld	(currow),de
	push	hl
	ld	hl,vatrompages
	call	disptext
	pop	hl
	ld	a,(hl)
	call	disphex

	inc	hl
	inc	hl
	ld	de,6*256+1
	ld	(currow),de
	bit	vatpoop,(iy+vatflags)
	call	z,dispprogvatname
	bit	vatpoop,(iy+vatflags)
	jr	z,vatc6
	dec	hl
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	inc	hl
	push	hl
	bcall	_puttokstring
	pop	hl




vatc6:



	call	getkey
	ld	hl,(vatcodeaddr)
	cp	$9d
	jr	nz,vatnodisasm

	inc	hl
	inc	hl	
	ld	(daddr),hl
	ld	a,(vatrompage)
	or	a
	jr	z,vok1
	ld	(rompaged),a
vok1:
	jp	disasm
vatnodisasm:
	cp	$a1
	jr	nz,vatnohexedit
	ld	(hexaddrs),hl
	ld	a,(vatrompage)
	or	a
	jr	z,vok2
	ld	(rompage),a
vok2:
	jp	hexeditor
vatnohexedit:
	cp	$af
	jr	nz,vatxorprot ;vatdotables
	ld	hl,(vatvataddr)
	ld	(hexaddrs),hl
	jp	hexeditor
vatxorprot:
	cp	$a9
	jr	nz,vatmode
	ld	hl,(vatvataddr)
	ld	a,(hl)
	cp	5
	jr	z,vatxorok
	cp	6
vatxornokay
	jp	nz,vatdotables
vatxorok:
	xor	3
	ld	(hl),a
	jr	vatxornokay
vatmode:
	cp	$a6
	jr	nz,vatxornokay
	ld	hl,flags+saveflags
	ld	a,1
	xor	(hl)
	ld	(hl),a
	jr	vatxornokay
vatproglistnextdostuff:
	bit	vatpoop,(iy+vatflags)
	jp	z,vatproglist
	jp	vatother
vatproglistnext:
	ld	hl,(vatlastaddr)
	push	hl
	or	a
	ld	de,0
	sbc	hl,de
	pop	hl
	jr	z,vatproglistnextdostuff
	call	nextvataddr
	push	hl
	ld	de,(ptemp)

	bit	vatpoop,(iy+vatflags)
	jr	z,vatc3
	ld	de,(progptr)
vatc3:
	
	or	a
	sbc	hl,de
	pop	hl
	jp	z,moveback
	ld	(curvataddr),hl
	jp	vatdotables
moveback:
	bit	vatpoop,(iy+vatflags)
	jp	z,vatproglist
	jp	vatother
dispvattable:
	ld	b,5
	ld	de,2*256+1
	ld	hl,vattable
dispvattabloop:
	push	bc
	push	de
	ld	(currow),de
	xor	a
	cp	(hl)
	jp	z,dispvattabblanks
	push	hl
	inc	hl
	ld	a,(hl)
	call	disphex
	dec	hl
	ld	a,(hl)
	call	disphex
	ld	hl,curcol
	inc	(hl)
	pop	hl
	bit	vatpoop,(iy+vatflags)
	jr	nz,dispvatstuffsym
	ld	de,9
	add	hl,de
	call	dispprogvatname
	ld	a,(hl)
	ld	e,a
	ld	d,0
	add	hl,de
	inc	hl
dispvatcont:
	pop	de
	inc	de
	pop	bc
	djnz	dispvattabloop
	ret
dispvatstuffsym:
	ld	de,8
	add	hl,de
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	inc	hl
	push	hl
	bcall	_puttokstring
	pop	hl
	jr	dispvatcont
dispprogvatname:
	ld	a,(hl)
	dec	hl
	cp	$5d
	jr	nz,notatoken
	ld	d,$5d
	inc	hl
	inc	hl
	ld	e,(hl)
	ld	a,e
	sub	'A'
	cp 	'Z'+1
	jr	c,oopstoken
	dec	hl
	dec	hl
	push	hl
	bcall	_puttokstring
	pop	hl
	ld	a,(hl)
	jr	skipyestok
oopstoken:
	dec	hl
	dec	hl
	ld	de,(currow)
	call	disptextps
	ld	(currow),de
	ld	a,$dc
	bcall	_putc
	ld	a,(hl)
	jr	skipyestok
notatoken
	ld	a,(hl)
	call	disptextps
skipyestok
	ret
dispvattabblanks:
	pop	de
	pop	bc
dispvatbloop:
	ld	(currow),de
	push	bc
	ld	hl,vatblank
	call	disptext
	pop	bc
	inc	de
	djnz	dispvatbloop
	ret
disptextps:
	push	de
	push	hl
	push	af
	ld	de,strbuf
	bcall	_strcopy
	ld	hl,strbuf
	bcall	_putps
	pop	af
	pop	hl
	pop	de
	ret	
	
lddir:
	ld	a,(hl)
	ld	(de),a
	inc	de
	dec	hl
	dec	bc
	ld	a,b
	or	c
	jr	nz,lddir
	ret
genvattable:
						; copies the next five vat entries to (vattable)
						; if less than five remaining entries, puts a 0
						; starts vat entry copy from (curvataddr)
	ld	hl,(curvataddr)
	ld	de,vattable
	ld	b,5
genvatloop:
	push	bc
	call	isendofvat
	ld	(vatlastaddr),hl
	ld	a,l
	ld	(de),a
	inc	de
	ld	a,h
	ld	(de),a
	inc	de

	bit	vatpoop,(iy+vatflags)
	jr	z,genvatreg	
	ld	bc,9
	call	lddir
	jr	vatc5
	
genvatreg:
	ld	bc,7
	call	lddir
	inc	hl
	ld	c,(hl)			; c = length of name
	dec	hl
	call	lddir
vatc5:
	pop	bc
	djnz	genvatloop
	ret
isendofvat:
	push	hl
	ld	bc,(ptemp)
	bit	vatpoop,(iy+vatflags)
	jr	z,vatc4
	ld	bc,(progptr)
vatc4:
	xor	a
	sbc	hl,bc
	pop	hl
	ret	nz
	ld	(de),a
	pop	bc
	pop	bc
	ld	hl,0
	ld	(vatlastaddr),hl
	ret
nextvataddrb:
	bit	vatpoop,(iy+vatflags)
	jr	nz,nextvataddrbc
	ld	de,8
	add	hl,de
	ld	d,0
	ld	e,(hl)
	add	hl,de
	inc	hl
	ret
nextvataddrbc:
	ld	de,11
	add	hl,de
	ret
nextvataddr:
						; input hl -> start of a vat entry
						; output hl -> start of next vat entry
	bit	vatpoop,(iy+vatflags)
	jr	nz,nextvataddrc

	ld	de,6
	xor	a
	sbc	hl,de
	ld	d,a
	ld	e,(hl)
	or	a
	sbc	hl,de
	dec	hl
	ret
waitenter:
	call	getkey
	cp	5
	jr	nz,waitenter
;	ret
nextvataddrc:
	ld	de,9
	or	a
	sbc	hl,de
	ret
getkeypress:
;	halt
;	call	$0223
	bcall	_getcsc
	ld	l,a
	ld	h,0
	in	a,(4)
	and	%00001000
	ld	de,keymaptable
	jr	nz,loco
	ld	de,keymaptable2
loco:
	add	hl,de
	ld	a,(hl)
	ret
linkquit:
	ld	hl,8*256+0
	ld	(wintop),hl
	jp	mainmenu2
xorflagb:
	ld	hl,flags+saveflags
	ld	a,2
	xor	(hl)
	ld	(hl),a
	jr	conbloop
xorflagc:
	ld	hl,flags+saveflags
	ld	a,4
	xor	(hl)
	ld	(hl),a
	jr	conbloop
linker:


	set	appautoscroll,(iy+appflags)
consolebytes:
;	bcall	_enableapd
        call    prepscreen
	ld	hl,3
	ld	(temp16),hl
	ld	hl,3*256+0
	ld	(wintop),hl
conbloop:
      call	getkeypress
	cp	5
	jr	z,xorflagb
	cp	6
	jr	z,xorflagc
	or	a
	jr	z,conbloopchkr
	cp	$f
	jp	z,linkquit
	cp	$37
	jr	z,linkoutbyte
	cp	'a'
	jr	nz,ookk
	ld	a,'7'
ookk:
	cp	$fe
	jr	nz,linkdisp
	xor	a
linkdisp:
	bcall	_putc
linkblah:
	call	sendbyte
	jr	conbloopchkr
linkoutbyte:
	call	getnumerichc
	jr	linkblah
conbloopchkr:
;	jr	conbloop

	call	getbyte

	jr	nz,conbloop
	ld	de,(temp16)
	ld	hl,(currow)
	ld	(temp16),hl
	ld	(currow),de
	ld	hl,8*256+3
	ld	(wintop),hl
	bit	linkc,(iy+saveflags)
	
	call	z,putc
	set	textinverse,(iy+textflags)
	bit	linkb,(iy+saveflags)
	call	z,disphex
	res	textinverse,(iy+textflags)
	ld	de,(temp16)
	ld	hl,(currow)
	ld	(temp16),hl
	ld	(currow),de
	ld	hl,3*256+0
	ld	(wintop),hl
	jr	conbloop

getbyte:
	in	a,(0)
;	cp	$3e
;	jr	z,noio
	and	d0d1_bits
	cp	d0d1_bits
        jp      z,noio
	di
	ld	hl,iodata
	ld	(hl),a
	ld	bc,15
dblp1:
	in	a,(0)
	and	d0d1_bits
	cp	(hl)
        jp      nz,noio
	dec	bc
	ld	a,b
	or	c
	jr	nz,dblp1
	ld	hl,linkfail
	call	$59
	set	indiconly,(iy+indicflags)
;	bcall	_recabyteio
	call	recbyte
	res	indiconly,(iy+indicflags)
	ld	(iodata),a
	call	$5c
	ld	a,d0hd1h
	out	(0),a
	ld	a,(iodata)
	cp	a
	ei
	ret


recbyte:
	ld	b,8
l43b2:
	ld	de,linkwait
	jr	l43cd
l43b7:
	in	a,(0)
	and	3
	jr	z,l4421
	cp	3
	jp	nz,l43d6
	in	a,(0)
	and	3
	jr	z,l4421
	cp	3
	jp	nz,l43d6
l43cd:
	dec	de
	ld	a,d
	or	e
	jp	nz,l43b7
	jp	$24f2
l43d6:
	cp	2
	jr	z,l4409
	ld	a,1
	out	(0),a
	rr	c
	ld	de,linkwait
l43e3:
	in	a,(0)
	and	3
	cp	2
	jp	z,l43f4
	dec	de
	ld	a,d
	or	e
	jp	nz,l43e3
	jr	l4421
l43f4:
	ld	a,0
	out	(0),a
	ld	d,4
l43fa:
	dec	d
	jr	z,l4405
	in	a,(0)
	and	3
	cp	3
	jr	nz,l43fa
l4405:
	djnz	l43b2
	ld	a,c
	ret
l4409:
	ld	a,2
	out	(0),a
	rr	c
	ld	de,linkwait
l4412:
	in	a,(0)
	and	3
	cp	1
	jp	z,l43f4
	dec	de
	ld	a,d
	or	e
	jp	nz,l4412
l4421:
	jp	$24f2



sendbyte:
	di
	push	af
	ld	a,d0hd1h
	out	(0),a
	pop	af
	set 	indiconly,(iy+indicflags)
	ld	hl,linkfail
	call	$59
;	bcall	_sendabyte
	call	sendit
;	jr	endexio
endexio:
	res	indiconly,(iy+indicflags)
	ld	(iodata),a
	call	$5c
	ld	a,d0hd1h
	out	(0),a
	ld	a,(iodata)
	cp	a
	ei
	ret
linkfail:
;noio:
	ld	a,d0hd1h
	out	(0),a
noio:
	ei
	or	1
	ret

sendit:
	ld	c,a
	ld	b,8
l41e4:
	ld	de,linkwait
	rr	c
	jr	nc,l41f0
	ld	a,2
	jp	l41f2
l41f0:
	ld	a,1
l41f2:
	out	(0),a
l41f4:
	in	a,(0)
	and	3
	jp	z,l420b
	in	a,(0)
	and	3
	jp	z,l420b
	dec	de
	ld	a,d
	or	e
	jp	nz,l41f4
l4208
	jp	$24f4
l420b:
	ld	a,0
	out	(0),a
	ld	de,linkwait
l4212:
	dec	de
	ld	a,d
	or	e
	jr	z,l4208
	in	a,(0)
	and	3
	cp	3
	jp	nz,l4212
	djnz	l41e4
	ret

portmon:
	res	logenabled,(iy+portflags)
	call	prepscreen
	ld	hl,portmenu
	call	disptextm
portmonloop:
	call	getkey
	cp	143
	jp	z,monitorport
	cp	144
	jp	z,monportlog
	cp	145
	jp	z,viewportlog
	cp	146
	jp	z,mainmenu
	cp	9
	jp	z,mainmenu
        jp      portmonloop
viewportlog:
	xor	a
	ld	(port),a
	call	prepscreen
	ld	hl,logname
	rst	20h
	bcall	_chkfindsym
	jp	c,portmon
	ld	hl,501
	add	hl,de
	ld	b,250
viewlogloop:
	push	bc
	dec	hl
	ld	a,(hl)
	dec	a
	call	z,dispportchanged
	dec	a
	call	z,dispportval
	dec	a
	call	z,dispvalout
	dec	hl
	pop	bc
	djnz	viewlogloop
	call	getkey
	jp	portmon
dispportchanged:
	push	af
	push	hl
	ld	a,13
	ld	(curcol),a
	inc	hl
	ld	a,(hl)
	ld	(port),a
	ld	l,a
	ld	h,0
;	bcall	_disphl
	call	disphex
	xor	a
	ld	(curcol),a
	ld	hl,portchangestr
	call	disptext
	pop	hl
	ld	a,(currow)
	inc	a
	cp	8
	call	z,resetcursorlog
	ld	(currow),a
	pop	af
	ret
resetcursorlog:
	push	hl
	call	getkey
	call	prepscreen
	pop	hl
	xor	a
	ret
dispportval:
	push	af
	push	hl
	xor	a
	ld	(curcol),a
	push	hl
	ld	hl,portvalstr
	call	disptext
	pop	hl
	ld	a,2
	ld	(curcol),a
	inc	hl
	ld	a,(hl)
	ld	l,a
	ld	h,0
;	bcall	_disphl
	call	disphex
	ld	a,10
	ld	(curcol),a
	ld	a,(port)
	ld	l,a
	ld	h,0
;	bcall	_disphl
	call	disphex
	pop	hl
	ld	a,(currow)
	inc	a
	cp	8
	call	z,resetcursorlog
	ld	(currow),a
	pop	af
	ret
dispvalout:
	push	af
	push	hl
	xor	a
	ld	(curcol),a
	push	hl
	ld	hl,portoutvalstr
	call	disptext
	pop	hl
	ld	a,2
	ld	(curcol),a
	inc	hl
	ld	a,(hl)
	ld	l,a
	ld	h,0
;	bcall	_disphl
	call	disphex
	ld	a,10
	ld	(curcol),a
	ld	a,(port)
	ld	l,a
	ld	h,0
;	bcall	_disphl
	call	disphex
	pop	hl
	ld	a,(currow)
	inc	a
	cp	8
	call	z,resetcursorlog
	ld	(currow),a
	pop	af
	ret
	
shiftportlog:
				; shifts all the data in the portlog 2 bytes forward
				; returns hl = pointer to portlog
	ld	hl,(logaddr)
	push	hl
	ld	de,497
	add	hl,de
	ld	d,h
	ld	e,l
	inc	de
	inc	de
	ld	bc,498
	lddr
	pop	hl
	ret
logname:
	.db	$15,"portlog",0
monportnomem:
	call	prepscreen
	ld	hl,nomemtext
	call	disptext
	call	getkey
	jp	portmon
monportlog:
	ld	hl,516
	bcall	_enoughmem
	jr	c,monportnomem
	ld	hl,logname
	rst	20h
	bcall	_chkfindsym	
	jr	c,plnodel
	ld	a,b
	or	a
	jr	z,notarchedp
	bcall	_arc_unarc
notarchedp:
	ld	hl,logname
	rst	20h
	bcall	_chkfindsym
	bcall	_delvar
plnodel:
	ld	hl,500
	bcall	_createappvar
	inc	de
	inc	de
	ld	(logaddr),de
	ld	bc,499
	ld	h,d
	ld	l,e
	inc	de
	ld	(hl),0
	ldir
	set	logenabled,(iy+portflags)

	jr	monitorport
addlogport:
	push	af
	call	shiftportlog
	ld	(hl),1
	inc	hl
	ld	a,(port)
	ld	(hl),a
	ld	(oldport),a
	pop	af
	ret
addlogval:
	call	shiftportlog
	ld	(hl),2
	inc	hl
	ld	(hl),a
	ld	(oldportval),a
	ret
addlogout:
	call	shiftportlog
	ld	(hl),3
	inc	hl
	ld	(hl),a
	ret
xorlogging:
	ld	a,(port)
	inc	a
	ld	(oldport),a
	bit	logenabled,(iy+portflags)
	jp	z,otherportmon
	push	iy
	pop	hl
	ld	de,portflags
	add	hl,de
	ld	a,1
	xor	(hl)
	ld	(hl),a

	jp	otherportmon
monitorport:
	res	portlog,(iy+portflags)
monportskipres
	xor	a
	ld	(port),a
	inc	a
	ld	(oldport),a
	ld	c,a
	in	a,(c)
	cpl
	ld	(oldportval),a
otherportmon
	call	prepscreen
	ld	hl,portscreen
	call	disptextm
	ld	hl,6
	ld	(currow),hl
	ld	hl,loggingstr
	bit	portlog,(iy+portflags)
	call	nz,disptext
monitorportloop:
	ld	a,(oldport)
	ld	b,a
	ld	a,(port)
	ld	(oldport),a
	cp	b
	push	bc
	push	af
	call	nz,dispportname
	pop	af
	pop	bc
	bit	portlog,(iy+portflags)
	jr	z,notlogging
	cp	b
	call	nz,addlogport
	jr	nz,lognoval
	ld	c,a
	in	a,(c)
	ld	b,a
	ld	a,(oldportval)
	cp	b
	ld	a,b
	call	nz,addlogval

lognoval:
notlogging:
	ld	hl,6*256+1
	ld	(currow),hl
	ld	a,(port)
;	ld	l,a
;	ld	h,0
;	bcall	_disphl
	call	disphex
        ld      a,(port)
        ld      hl,5*256+3
        ld      (currow),hl
        ld      c,a
        in      a,(c)
        call    disphex
        ld      a,(port)
        ld      hl,5*256+4
        ld      (currow),hl
        ld      c,a
        in      a,(c)
        call    dispbin
        ld	a,(port)
	ld	c,a
	in	a,(c)
	ld	hl,7*256+2
	ld	(currow),hl

	ld	l,a
	ld	h,0
	bcall	_disphl

        bcall   _getcsc
	cp	$2c
	jp	z,xorlogging
        cp      55
        jp      z,outport
        cp      15
        jp      z,portmon
        cp      4
	jr	nz,portnotup
	ld	hl,port
	inc	(hl)
        call    portdelay
portnotup:
        cp      1
	jr	nz,portnotdown
	ld	hl,port
	dec	(hl)
        call    portdelay
portnotdown:
        cp      2
	jr	nz,portnotleft
	ld	hl,port
	dec	(hl)
	dec	(hl)
	dec	(hl)
	dec	(hl)
	dec	(hl)
        call    portdelay
portnotleft:
        cp      3
	jr	nz,portnotright
	ld	hl,port
	inc	(hl)
	inc	(hl)
	inc	(hl)
	inc	(hl)
	inc	(hl)
        call    portdelay
portnotright:
	jp monitorportloop
portdelay:
        ei
        halt
        halt
        halt
        halt
        ret
outport
        ld      hl,0*256+5
        ld      (currow),hl
        ld      hl,portprompt
        call    disptext
        call    getnumerich
	bit	portlog,(iy+portflags)
	call	nz,addlogout
        ld      d,a
        ld     a,(port)
        ld      c,a
        ld      a,d
        out     (c),a
	  inc		a
	ld	(oldport),a
        jp      otherportmon
dispportname:
	ld	hl,7
	ld	(currow),hl
	push	hl
	ld	hl,clrlinestr
	call	disptext
	pop	hl
	ld	(currow),hl
	ld	a,(port)
	cp	$18
	jr	nc,nodispportname

	inc	a
	ld	b,a
	ld	hl,portstrings
	xor	a
portcpirloop:
	push	bc
	ld	b,9
	cpir
	pop	bc
	djnz	portcpirloop
	call	disptext
nodispportname:
	ret
dispbin:
        ld      b,8
dbloop:
        push     bc
        rl      a
        push    af
        ld      a,'0'
        jr      nc,dbone
        inc     a
dbone:
        bcall   _putc
        pop     af
        pop     bc
        djnz    dbloop
        ret

disphexhl:

        push    hl
        ld      a,h
        call    disphex
        pop     hl
        ld      a,l
        jp      disphex
disphex:
        push    hl
        push    bc
        push    af
        rrca
        rrca
        rrca
        rrca
        call    dispha
        pop     af
        call      dispha
        pop     bc
        pop     hl
        ret
dispha:
        and     15
        cp      10
        jr      nc,dhlet
        add     a,48
        jr      dispdh
dhlet:
        add     a,55
dispdh:
        bcall   _putc
        ret
calcinfo:
sysinfo:
	call	prepscreen
	ld	hl,calcinfoscreen
	call	disptextm
	ld	hl,9*256+2
	ld	(currow),hl
	bcall	_memchk
	call	disphexhl
;	bcall	_disphl
	ld	hl,10*256+3
	ld	(currow),hl
	bcall	_getbasever
;	ld	h,a
;	ld	l,100
;	push	bc
 ;       bcall   _htimesl
;	pop	bc
;	ld	e,b
;	ld	d,0
;	add	hl,de
;	bcall	_disphl
	ld	h,a
	ld	l,b
	call	disphexhl
	ld	hl,9*256+4
	ld	(currow),hl
	ld	a,(contrast)
;	ld	h,0
;	ld	l,a
;	bcall	_disphl
	call	disphex
	ld	hl,9*256+5
	ld	(currow),hl
	ld	hl,symtable
	ld	de,(ptemp)
	or	a
	sbc	hl,de
;	bcall	_disphl
	call	disphexhl
	ld	hl,9*256+7
	ld	(currow),hl
	in	a,(6)
;	ld	h,0
;	ld	l,a
;	bcall	_disphl
	call	disphex
	ld	hl,9*256+6
	ld	(currow),hl
	ld	hl,(progptr)
	push	hl
	ld	a,h
	call	disphex
	pop	hl
	ld	a,l
	call	disphex
	call	getkey
	jp	mainmenu2





disptextm:
	ld	b,(hl)
	inc	hl
disptextml:	
	push	bc
	push	hl
	call	disptext
	bcall	_newline
	pop	hl
	xor	a
	ld	c,80
	cpir
	pop	bc
	djnz	disptextml
	ret
disptext:
	push	de
	push	hl
	push	af
	ld	de,strbuf
	bcall	_strcopy
	ld	hl,strbuf
	bcall	_puts
	pop	af
	pop	hl
	pop	de
	ret
prepscreen:
        push    hl
	bcall	_clrscrnfull
	ld	hl,0
	ld	(currow),hl
	bcall	_grbufclr
        pop     hl
	ret

;getnumericb:
;                ; lets user input an 8 bit number in binary
;                ; prompt is @ cursor
;                ; returned in a
;        set     curable,(iy+curflags)
;        ld      hl,(currow)
;        ld      (curback),hl
;        xor     a
;        ld      (tempnum),a
;        ld      hl,tempnum
;        ld      b,8
;getnumbloop:
;        push    bc 
;        push    hl
;        call   getkey
;        pop     hl
;        pop     bc
;        cp      2
;        jr      nz,gnbnotback
;        ld      a,b
;        cp      8
;        jr      z,gnbnb1
;        inc     b
;        ld      a,$20
;        bcall   _putmap
;        ld      a,(curcol)
;        dec     a
;        ld      (curcol),a
;        ld      a,$20
;        bcall   _putmap
;        sla     (hl)
;gnbnb1:
;        xor     a
;gnbnotback:
;        cp      5
;        jr      z,gnbend
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getnumerichc:

	set	textinverse,(iy+textflags)
	ld	b,2
	ld	hl,tempnum
getnumhloop2:
	push	bc
	push	hl
	bcall	_getcsc
	pop	hl
	pop	bc
	cp	2
	jr	nz,gnhnotback2
	bit	gethexnoback,(iy+gethexflags)
	jr	nz,gnhnotback2
	ld	a,b
	cp	2
	jr	z,gnhnotback2
	ld	a,' '
	bcall	_putmap
	ld	hl,curcol
	dec	(hl)
	jr	getnumerichc

gnhnotback2:
	sub	$12
	cp	3
	jr	c,gnhnum369
	sub	$1A-$12
	cp	3
	jr	c,gnhnum258
	sub	$21-($1A-$12)-$12
	cp	4
	jr	c,gnhnum0147
#define	subber	$21
		
	cp	$2F-subber
	jr	z,gnhleta
	cp	$27-subber
	jr	z,gnhletb
	cp	$1F-subber
	jr	z,gnhletc
	cp	$2e-subber
	jr	z,gnhletd
	cp	$26-subber
	jr	z,gnhlete
	cp	$1e-subber
	jr	z,gnhletf

	jr	getnumhloop2

gnhnum369:
	inc	a
	ld	e,a
	add	a,e
	add	a,e
gnhnummer
	ld	(hl),a
	inc	hl
	add	a,48
	call	putc
	djnz	getnumhloop2
	jr	gnhdone2
gnhletpressed2:
	add	a,10
	ld	(hl),a
	inc	hl
	add	a,55
	call	putc
	djnz	getnumhloop2
gnhdone2:
	dec	hl
	ld	b,(hl)
	dec	hl
	ld	a,(hl)
	rlca
	rlca
	rlca
	rlca
	or	b
	res	textinverse,(iy+textflags)
	res	gethexnoback,(iy+gethexflags)
	ret
gnhnum0147:
	or	a
	jr	z,gnhnummer
	ld	e,a
	add	a,e
	add	a,e
	dec	a
	dec	a
	jr	gnhnummer
gnhnum258:
	inc	a
	ld	e,a
	add	a,e
	add	a,e
	dec	a
	jr	gnhnummer
gnhleta:
	xor	a
	jr	gnhletpressed2
gnhletB:
	ld	a,1
	jr	gnhletpressed2
gnhletC:
	ld	a,2
	jr	gnhletpressed2
gnhletd:
	ld	a,3
	jr	gnhletpressed2
gnhlete:
	ld	a,4
	jr	gnhletpressed2
gnhletf:
	ld	a,5
	jr	gnhletpressed2



getnumerich:
		; lets user input an 8 bit number in hexadecimal
		; prompt is at currow,curcol
		; number is returned in a
	set	curable,(iy+curflags)
	ld	b,2
	ld	hl,tempnum
getnumhloop:
	push	bc
	push	hl
	call	getkey
	pop	hl
	pop	bc
	cp	2
	jr	nz,gnhnotback
	bit	gethexnoback,(iy+gethexflags)
	jr	nz,gnhnotback
	ld	a,b
	cp	2
	jr	z,gnhnotback
	ld	a,' '
	bcall	_putmap
	ld	hl,curcol
	dec	(hl)
	jr	getnumerich

gnhnotback:
	sub	142
	cp	10
	jr	c,gnhnumpressed
	sub	12
	cp	6
	jr	c,gnhletpressed
	jr	getnumhloop
gnhnumpressed:
	ld	(hl),a
	inc	hl
	add	a,48
	call	putc
	djnz	getnumhloop
	jr	gnhdone
gnhletpressed:
	add	a,10
	ld	(hl),a
	inc	hl
	add	a,55
	call	putc
	djnz	getnumhloop
gnhdone:
	dec	hl
	ld	b,(hl)
	dec	hl
	ld	a,(hl)
	rlca
	rlca
	rlca
	rlca
	or	b
	res	curable,(iy+curflags)
	res	gethexnoback,(iy+gethexflags)
	ret
	
;pregetnumeric:
;        ld      hl,(curback)
;        ld      (currow),hl
;        ld      hl,clearstr
;        call    disptext
;        ld      hl,(curback)
;        ld      (currow),hl
;getnumeric:
		; lets user input an 8 bit number
		; prompt is at currow,curcol
		; number is returned in a
;        set     curable,(iy+curflags)
;        ld      hl,(currow)
;        ld      (curback),hl
;        ld      hl,45*256+45
;	ld	(tempnum),hl
;	ld	(tempnum+1),hl
;        ld      b,3
;        ld      hl,tempnum
;getnumloop:
;        push    bc
;        push    hl              
;        call   getkey
;        pop     hl
;        pop     bc
;        cp      2
;        jr      nz,gnnotback
;        ld      a,b
;        cp      3
;        jr      z,gnnb1
;        inc     b
;        ld      a,$20
;        bcall   _putmap
;        ld      a,(curcol)
;        dec     a
;        ld      (curcol),a
;        ld      a,$20
;        bcall   _putmap
;gnnb1:
;        xor     a
;gnnotback:
;        cp      5
;        jr      z,getnendloop
;        sub     142
;        cp      10
;        jr      nc,getnumloop
;        ld      (hl),a
;        inc     hl
;        push    hl
;        push    bc
;        add     a,48
;        bcall   _putc
;        pop     bc
;        pop     hl
;        djnz    getnumloop
;getnendloop:
;        ld      a,(tempnum+2)
;        cp      45
;        jr      nz,getn3                     ; we used all 3 numbers
;        ld      hl,(tempnum)
;        ld      (tempnum+1),hl
;        xor     a
;        ld      (tempnum),a
;getn3:
;        ld      a,(tempnum+2)
;        cp      45
;        jr      nz,getn2                        ; we used 2 numbers
;        ld      a,(tempnum+1)
;        ld      (tempnum+2),a
;        xor     a
;        ld      (tempnum+1),a
;getn2:
;        ld      a,(tempnum)
;        cp      45
;        jr      z,getnumeric
;        ld      b,3
;        ld      hl,tempnum
;getnl2:                                 ; replace blank spaces with 0's
;        ld      a,(hl)
;        xor     45
;        jr      nz,gn2
;        ld      (hl),a
;gn2:
;        inc     hl
;        djnz    getnl2
;        ld      a,(tempnum)
;        cp      3
;        jp      nc,pregetnumeric
;        call    multaten
;        call    multaten
;        ld      b,a
;        ld      a,(tempnum+1)
;        call    multaten
;        add     a,b
;        jp      c,pregetnumeric
;        ld      b,a
;        ld      a,(tempnum+2)
;        add     a,b
;        jp      c,pregetnumeric
;        res     curable,(iy+curflags)
;        ret
;multaten:
;        ld      c,a
;        add     a,a
;        add     a,a
;        add     a,c
;        add     a,a
;        ret
prephexfind
	push	hl
	call	prepscreen
	ld	hl,searchscreen
	call	disptext
	ld	hl,7*256+1
	ld	(currow),hl
	call	getnumerich
	pop	hl
	ld	de,$ffff
	ret
hexfinddown:
	call	prephexfind
hexefld:
	push	af
	ld	a,(rompage)
	ld	b,a
	bcall	_loadaindpaged
	pop	af
	cp	c
	jr	z,hexeditloop
	dec	hl
	dec	bc
	ld	b,a
	ld	a,d
	or	e
	jr	z,hexeditloop
	ld	a,b
	jr	hexefld
hexeditfind:
	call	prephexfind
hexefl:
	push	af
	ld	a,(rompage)
	ld	b,a
	bcall	_loadaindpaged
	pop	af
	cp	c
	jr	z,hexeditloop
	inc	hl
	dec	bc
	ld	b,a
	ld	a,d
	or	e
	jr	z,hexeditloop
	ld	a,b
	jr	hexefl
hexeditgoto:
	push	hl
	call	prepscreen
	ld	hl,gotoscreen
	call	disptext
	ld	hl,6*256+1
	ld	(currow),hl
	set	gethexnoback,(iy+gethexflags)
	call	getnumerich
	ld	(port),a
	set	gethexnoback,(iy+gethexflags)
	call	getnumerich
	ld	l,a
	ld	a,(port)
	ld	h,a
	jr	hexeditloop
hexeditor:
        call    prepscreen
        ld      hl,(hexaddrs)
hexeditloop:
        push    hl
        call    disphexscreen
        call   getkey
        pop     hl
	cp	$9d
	jr	nz,hexnodis
	ld	(daddr),hl
	ld	(hexaddrs),hl
	ld	a,(rompage)
	ld	(rompaged),a
	jp	disasm
hexnodis:
	cp	$AB
	jp	z,hexeditrompagescreen
;	cp	186
;	jp	z,hexfinddown
	cp	160
	jr	z,hexeditgoto
	cp	159
	jp	z,hexeditfind
	cp	5
	jr	nz,hexeditnoinput
	push	hl
	ld	de,$8000
	or	a
	sbc	hl,de
	pop	hl
	jr	c,hexeditnoinput
	push	hl
	ld	hl,5*256+0
	ld	(currow),hl
	call	getnumerich
	pop	hl
	ld	(hl),a
	jr	hexeditloop
hexeditnoinput:
	ld	(hexaddrs),hl
        cp      9
        jp      z,mainmenu
	cp	130
	jr	nz,henotmult
	ld	de,4096
	add	hl,de
henotmult:
	cp	131
	jr	nz,henotdiv
	ld	de,4096
	sbc	hl,de
henotdiv:
        cp	128
	jr	nz,henotplus
	ld	de,256
	add	hl,de
henotplus:
	cp	129
	jr	nz,henotminus
	ld	de,256
	sbc	hl,de
henotminus:
	dec     a
        jr      nz,henotright
        inc     hl
henotright:
        dec     a
        jr      nz,henotleft
        dec     hl
henotleft:
        dec     a
        jr      nz,henotup
        dec     hl
        dec     hl
        dec     hl
        dec     hl
henotup:
        dec     a
        jr      nz,henotdown
        inc     hl
        inc     hl
        inc     hl
        inc     hl
henotdown:
        sub      11
        jr      nz,henot2right
        ld      de,16
        add     hl,de
henot2right:
        inc     a
        jr      nz,henot2left
        ld      de,15
        sbc     hl,de
henot2left:
        jp      hexeditloop
putblank:
        ld      a,' '
putc:
        push    hl
        push    bc
        bcall   _putc
        pop     bc
        pop     hl
        ret
dhsp1:			; display routine for first line
	push	hl
	ld	a,(rompage)
	ld	b,a
	bcall	_loadaindpaged
	ld	a,c
	pop	hl
	inc	hl
	call	disphex
	call	putblank
	ret
dhsp2:			; display routine for second line
	push	hl
	ld	a,(rompage)
	ld	b,a
	bcall	_loadaindpaged
	ld	a,c
	cp	$d6
	jr	nz,dhnoenter2
	ld	a,$3a
dhnoenter2:
	pop	hl
	inc	hl
	call	putc
	call	putblank
	call	putblank
	ret      
disphexscreen:
        call    prepscreen
        ld      b,4
dhsloop:
	push	bc
        ld      a,h
        call    disphex
        ld      a,l
        call    disphex
        ld      a,':'
        call   putc
	call	dhsp1
	call	dhsp1
	call	dhsp1
	push	hl
	ld	a,(rompage)
	ld	b,a
	bcall	_loadaindpaged
	ld	a,c
	pop	hl
	call	disphex
        dec     hl
        dec     hl
        dec     hl
        ld      b,4
        call    putblank
        call    putblank
        call    putblank
        call    putblank
        call    putblank

	call	dhsp2
	call	dhsp2
	call	dhsp2
	push	hl
	ld	a,(rompage)
	ld	b,a
	bcall	_loadaindpaged
	ld	a,c
	cp	$d6
	jr	nz,dhnoenter
	ld	a,$3a
dhnoenter:
	pop	hl
        call    putc
        call    putblank
        inc     hl
        pop     bc
        djnz    dhsloop
        ret
hexeditrompagescreen:
	ld	de,hexeditloop
	push	de

	push	hl
	call	prepscreen
	ld	hl,rompagescreen
	call	disptextm
	ld	hl,5*256+1
	ld	(currow),hl
	ld	a,(rompage)
	call	disphex
	ld	hl,5*256+2
	ld	(currow),hl
	call	getnumerich
	ld	(rompage),a
	pop	hl
	ret
rompagescreens:
	push	hl
	call	prepscreen
	ld	hl,rompagescreen
	call	disptextm
	ld	hl,5*256+1
	ld	(currow),hl
	ld	a,(rompaged)
	call	disphex
	ld	hl,5*256+2
	ld	(currow),hl
	call	getnumerich
	ld	(rompaged),a
	pop	hl
	ret
dispflagscreen:
	ld	a,(flagscreen)
	ld	de,14*256+1
	ld	b,5
dfscreennumloop:
	ld	(currow),de
	push	af
	push	de
	push	bc
;	bcall	_disphl
	call	disphex
	pop	bc
	pop	de
	pop	af
	inc	a
	inc	e
	djnz	dfscreennumloop
					; get offset for text
	ld	hl,flagscreentext
	ld	a,(flagscreen)
	or	a
	jr	z,realdfs		; dont cpir if a is 0
	ld	b,a
	xor	a
dfscreengettextloop:
	push	bc
	ld	bc,15000
	cpir
	pop	bc
	djnz	dfscreengettextloop
realdfs:
	ld	b,5
	ld	de,3*256+1
	xor	a
realdfsloop:
	ld	(currow),de
	push	hl
	push	de
	call	disptext
	pop	de
	pop	hl
	push	bc
	ld	bc,15000
	cpir
	pop	bc
	inc	e
	djnz	realdfsloop
	ret
changefscreen:
	ld	a,(flagscreen)
	add	a,5
	ld	(flagscreen),a
	cp	65
	jr	nz,newflagscreen
sysflags:
	xor	a
	ld	(flagscreen),a
newflagscreen
	call	prepscreen
	ld	hl,flagsmenu
	call	disptextm
flagsloop:
	call	dispflagscreen
	call	getkey
	cp	149
	jp	z,mainmenu
	cp	09
	jp	z,mainmenu
	sub	143
	cp	5
	jr	z,changefscreen
	jr	nc,flagsloop
loadflagscreen
	push	af
	call	prepscreen
	ld	hl,flagsscreen
	call	disptext
	pop	af
	ld	(tempflag),a
	ld	b,a
	ld	a,(flagscreen)
	add	a,b
	ld	(flagoffset),a
	ld	h,a
	ld	l,8
	or	a
	jr	nz,lfsgood
	ld	hl,bitstrings
lfsgood:
	jr	z,lfsdispstrings
	bcall	_htimesl
	ld	b,h
	ld	c,l
	xor	a
	ld	hl,bitstrings
lfsgetstart:
	push	bc
	ld	bc,15000
	xor	a
	cpir
	pop	bc
	dec	bc
	ld	a,b
	or	c
	jr	nz,lfsgetstart
; hl now contains the first string to display
lfsdispstrings:
	ld	de,3*256+0
	ld	b,8
	xor	a
lfsdsloop:
	ld	(currow),de
	push	bc
	push	de
	push	hl
;	ld	a,(hl)
;	cp	1
;	jr	nz,notques
;	ld	hl,quesstr
;notques:
	call	disptext
	pop	hl
	pop	de
	ld	bc,15000
	xor	a
	cpir
	pop	bc
	inc	e
	djnz	lfsdsloop

flagscreenloop:
	call	dispflags
	call	getkey
	cp	9
	jp	z,newflagscreen
	sub	142
	cp	8
	jr	nc,flagscreenloop
	call	xorflag
	ld	a,(tempflag)
	jr	loadflagscreen


xorflag:
	ld	b,a
	inc	b
	xor	a
	ccf
xorflagloop:
	rla
	djnz	xorflagloop
	ld	b,a
	ld	a,(flagoffset)
	ld	e,a
	ld	d,0
	push	iy
	pop	hl
	add	hl,de
	ld	a,b
	xor	(hl)
	ld	(hl),a
	ret



dispflags:
		; displays the 8 bits of iy+(flagoffset) in the last column
	ld	b,8
	ld	hl,15*256+0
	ld	(currow),hl
	ld	a,(flagoffset)
	ld	d,0
	ld	e,a
	push	iy
	pop	hl
	add	hl,de
	ld	a,(hl)
dispflagloop:
	rra
	call	c,dispa1
	call	nc,dispa0
	ld	hl,currow
	inc	(hl)
	djnz	dispflagloop
	ret
dispa1:
	push	af
	push	bc
	ld	a,'1'
	bcall	_putmap
	pop	bc
	pop	af
	ret
dispa0:
	push	af
	push	bc
	ld	a,'0'
	bcall	_putmap
	pop	bc
	pop	af
	ret

;lcddelay:
;	push	de
;	push	hl
;	push	ix
;	push	iy
;	pop	iy
;	pop	ix
;	pop	hl
;	pop	de
;	ret
;dhsgfx:
;	ld	a,5
;	out	($10),a
;	call	lcddelay
;	ld	a,$20
;	out	($10),a
;	call	lcddelay
;	ld	a,$89
;	out	($10),a
;	call	lcddelay
disasm:
	call	dispdasm
	call	getkey
	cp	$a1
	jr	nz,dnohex
	ld	hl,(daddr)
	ld	(hexaddrs),hl
	ld	a,(rompaged)
	ld	(rompage),a
	jp	hexeditor
dnohex:
	cp	4
	call	z,incdad
	cp	3
	call	z,decdad
	cp	9
	jp	z,mainmenu
	push	af
	cp	$a0
	call	z,gotodad
	pop	af
	cp	$ab
	call	z,rompagescreens
	jr	disasm
decdad:
	ld	hl,(daddr)
	dec	hl
	ld	(daddr),hl
	ret
gotodad:
	call	prepscreen
	ld	hl,gotoscreen
	call	disptext
	set	gethexnoback,(iy+gethexflags)
	call	getnumerich
	push	af
	set	gethexnoback,(iy+gethexflags)
	call	getnumerich
	ld	l,a
	pop	af
	ld	h,a
	ld	(daddr),hl
	ret
incdad:
	ld	hl,(backaddr)
	ld	(daddr),hl
	ret
dispdasm:
	call	prepscreen
	ld	hl,(daddr)
	push	hl
	ld	b,8
ddasmloop:
	push	bc
	ld	a,8
	sub	b
	ld	h,0
	ld	l,a
	ld	(currow),hl
	ld	hl,(daddr)
	dec	a
	jr	nz,dnot7
	ld	(backaddr),hl
dnot7:

	call	copyinstr
	ld	a,h
	push	hl
	call	disphex
	pop	hl
	ld	a,l
	call	disphex
	ld	a,':'
	bcall	_putc
	call	dasminstr
	pop	bc
	djnz	ddasmloop
	pop	hl
	ld	(daddr),hl
	ret
copyinstr:
	push	hl
	ld	b,4
	ld	de,instraddr
copyinstrl:
	push	bc
	ld	a,(rompaged)
	ld	b,a
	bcall	_loadaindpaged
	ld	a,c
	ld	(de),a
	inc	de
	inc	hl
	pop	bc
	djnz	copyinstrl
	pop	hl
	ret
dasmed:
	ld	a,(instraddr+1)
	ld	hl,dtabed
	ld	de,3
	ld	b,(dtabed-dtabedend)/3
	ld	c,b
dasmedfindinstrloop:
	cp	(hl)
	jr	z,dasmedgoodinstr
	add	hl,de
	djnz	dasmedfindinstrloop
	ld	a,$ed
	jp	contdasminstr
dasmedgoodinstr:
	push	hl
	ld	a,c
	sub	b
	inc	a
	ld	b,a
	xor	a
	ld	hl,dstred
dedfindnameloop:
	push	bc
	ld	bc,100
	cpir
	pop	bc
	djnz	dedfindnameloop
	call	disptext
	pop	hl
	inc	hl
	push	hl
	ld	a,(hl)
	ld	e,a
	ld	d,0
	ld	hl,(daddr)
	add	hl,de
	ld	(daddr),hl
	pop	hl
	inc	hl
	jp	dasmparse
dasmcb:
	ld	hl,(daddr)
	ld	de,2
	add	hl,de
	ld	(daddr),hl
	ld	a,(instraddr+1)
	and	%11000000
	jp	nz,dasmcbbit
	ld	a,(instraddr+1)
	ld	hl,cbregcmds
	ld	bc,numcbregcmds
	or	a
	cpir
	jr	nz,dasmcbregreg

	ld	a,numcbregcmds
	sub	c
	ld	b,a
	ld	hl,cbregstr
	call	find0tab
	jp	disptext
dasmcbregreg:
	push	af
	and	%00111000
	ld	hl,cbregregcmds
	ld	bc,numcbregregcmds
	or	a
	cpir
	ld	a,numcbregregcmds
	sub	c
	ld	b,a
	ld	hl,cbregregstr
	call	find0tab
	call	disptext
	pop	af
	and	%00000111
	ld	l,a
	ld	h,0
	ld	de,regbitstr
	add	hl,de
	ld	a,(hl)
	jp	putc
dasmcbbit:
	ld	bc,3
	ld	hl,cbbitcmds
	cpir
	ld	a,3
	sub	c
	ld	b,a
	ld	hl,cbbitstr
	call	find0tab
	call	disptext
	ld	a,(instraddr+1)
	push	af
	and	%00111000
	sra	a
	sra	a
	sra	a
	or	%00110000
	call	putc
	ld	a,','
	call	putc
	pop	af
	and	%00000111
	cp	6
	jp	z,dasmcbbithl
	ld	l,a
	ld	h,0
	ld	de,regbitstr
	add	hl,de
	ld	a,(hl)
	jp	putc
dasmcbbithl:
	ld	hl,cbhlstr
	jp	disptext
	
dasmfdreturn:
	ld	a,(instraddr)
	jp	contdasminstr
dasmdd:
	set	dasmix,(iy+iyflags)
	jr	dasmfdc
dasmfd:
	res	dasmix,(iy+iyflags)
dasmfdc:
#define	numindex	11
	ld	bc,numindex
	ld	a,(instraddr+1)
	ld	hl,indexcmds
	cpir
	jr	nz,fdoffset
	ld	a,numindex
	sub	c
	push	af
	ld	b,a
	ld	hl,indexstr
	call	find0tab
	call	disptext
	pop	af
	ld	hl,(daddr)
	inc	hl
	inc	hl
	ld	(daddr),hl
	cp	5
	jr	nc,fdnofixcurcol
	ld	a,9
	ld	(curcol),a
fdnofixcurcol
fnofixcurcol
	bit	dasmix,(iy+iyflags)
	jr	nz,fddispix
	ld	hl,fdiy
fdploop:
	jp	disptext	
fddispix:
	ld	hl,fdix
	jr	fdploop
fdoffset:
#define	numfdoffset	18
	ld	bc,numfdoffset
	ld	hl,indexoffsetcmds
	cpir
	jp	nz,fddasmirr
	ld	hl,(daddr)
	inc	hl
	inc	hl
	inc	hl
	ld	(daddr),hl
	ld	a,numfdoffset
	sub	c
	ld	b,a
	ld	hl,indexoffsetstr
	call	find0tab
	call 	disptext
	call	fdnofixcurcol
fdappendoffset
	ld	a,(instraddr+2)
	ld	b,a
	and	128
	jr	nz,fdoffneg
	ld	a,'+'
fdappendend
	call	putc
	ld	a,b
	jp	disphex
fdoffneg:
	ld	a,'-'
	jr	fdappendend
fddasmirr1:
	ld	hl,fdld
	call	disptext
	call	fnofixcurcol
	call	fdappendoffset
	ld	a,','
	call	putc
	ld	a,(instraddr+3)
	ld	hl,(daddr)
	ld	de,4
	add	hl,de
	ld	(daddr),hl
	jp	disphex
fddasmirr2:
	ld	d,0
	jr	fddasmirr3e
fddasmirr3:
	ld	d,1
fddasmirr3e:
	ld	hl,fdld
	call	disptext
	call	fnofixcurcol
	ld	a,','
	call	putc
	ld	a,'('
	dec	d
	call	z,putc
	ld	a,(instraddr+3)
	call	disphex
	ld	a,(instraddr+2)
	call	disphex
	ld	hl,(daddr)
	ld	de,4
	add	hl,de
	ld	(daddr),hl
	ret
fddasmirr4:
	ld	hl,fdld
	call	disptext
	call	fnofixcurcol
	call	fdappendoffset
	ld	a,','
	call	putc
	ld	a,(instraddr+1)
	and	7
	ld	l,a
	ld	h,0
	ld	de,regbitstr
	add	hl,de
	ld	a,(hl)
	ld	hl,(daddr)
	ld	de,3
	add	hl,de
	ld	(daddr),hl
	jp	putc
fddasmirr:
	cp	$36
	jp	z,fddasmirr1
	cp	$21
	jr	z,fddasmirr2
	cp	$2a
	jr	z,fddasmirr3
	and	$70
	cp	$70
	jr	z,fddasmirr4
	ld	a,(instraddr+1)
	cp	$CB
	jp	nz,returie
	ld	(instraddr),a
	ld	a,(instraddr+2)
	ld	a,(instraddr+3)
	ld	(instraddr+1),a
	call	dasminstr
	ld	hl,curcol
	dec	(hl)
	dec	(hl)
	dec	(hl)
	dec	(hl)
	ld	hl,(daddr)
	inc	hl
	inc	hl
	ld	(daddr),hl
	call	fnofixcurcol
	jp	fdappendoffset
returie:
	ld	a,(instraddr)
	jp	contdasminstr
	
dasminstr:
	ld	a,(instraddr)
	cp	$ed
	jp	z,dasmed
	cp	$cb
	jp	z,dasmcb
	cp	$dd
	jp	z,dasmdd
	cp	$fd
	jp	z,dasmfd
contdasminstr
	ld	b,a
	xor	a
	ld	hl,dstr
	inc	b
dfindnameloop:
	push	bc
	ld	bc,100
	cpir
	pop	bc
	djnz	dfindnameloop
	call	disptext
	

	ld	a,(instraddr)
	ld	l,a
	ld	h,0
	add	hl,hl
	ld	de,dtab1
	add	hl,de
	push	hl
	ld	a,(hl)
	ld	e,a
	ld	d,0
	ld	hl,(daddr)
	add	hl,de
	ld	(daddr),hl
	pop	hl
	inc	hl
dasmparse
	ld	a,(hl)
	or	a
	ret	z
	dec	a
	jp	z,donebtag
	dec	a
	jp	z,dtwobtag
	dec	a
	jp	z,donebreltag
	dec	a
	jp	z,dtwobembed
	dec	a
	jp	z,dtwobtagp
	dec	a
	jp	z,douta
	dec	a
	jp	z,dina
	ret
dtwobtagp:
	ld	a,(instraddr+2)
	call	disphex
	ld	a,(instraddr+1)
	call	disphex
	ld	a,')'
;	bcall	_putc
	ret
douta:
	ld	a,9
	ld	(curcol),a
	ld	a,(instraddr+1)
	call	disphex
	ret
dina:
	ld	a,(instraddr+1)
	call	disphex
	ld	a,')'
	bcall	_putc
	ret
donebtag:
	ld	a,(instraddr+1)
	call	disphex
	ret
dtwobtag:
	ld	a,(instraddr+2)
	call	disphex
	ld	a,(instraddr+1)
	call	disphex
	ret
donebreltag:
	ld	hl,(daddr)
	ld	a,(instraddr+1)
	cp	130
	jr	c,dreljumpf
	cpl
	ld	e,a
	ld	d,0

	or	a
	sbc	hl,de
	dec	hl
drelfinish

	push	hl
	ld	a,h
	call	disphex
	pop	hl
	ld	a,l
	call	disphex
	ret
dreljumpf:
	ld	e,a
	ld	d,0
	add	hl,de
	jr	drelfinish
dtwobembed:
	ld	a,(curcol)
	or	a
	jr	nz,dtwoemno
	ld	a,(currow)
	dec	a
	ld	(currow),a
dtwoemno:
	ld	a,8
	ld	(curcol),a
	ld	a,(instraddr+2)
	call	disphex
	ld	a,(instraddr+1)
	call	disphex
	ret

getkey:
	bcall	_getkey
	res	oninterrupt,(iy+onflags)
	cp	$40
	jp	z,quit
	ret
	
gettext:
		; gets input from user as text
		; input is at cursor
		; b = max length of string (must be <= 255)
	
	set	appautoscroll,(iy+appflags)
	set	curable,(iy+curflags)
	ld	hl,(currow)
	ld	(command),hl
	ld	hl,textshadow
	ld	de,args
	push	bc
	ld	bc,128
	ldir
	pop	bc
	ld	hl,textbuf
	ld	a,b
	ld	(port),a
gettextloop:
	push	hl
	push	bc
	call	getkey
	pop	bc
	pop	hl
	cp	$ca
	jr	z,gtques
	cp	9
	jr	z,gtclear
	cp	$8b
	jr	z,gtcomma
	cp	02
	jr	z,gtbackspace
	cp	05
	jp	z,gtfinished
	sub	$8e
	jr	c,gettextloop
	cp	10
	jr	c,gtnumber
	sub	$99-$8e
;	jr	c,gettext
	jr	c,gettextloop
	cp	27
	jr	c,gtletter
	cp	27
	jr	z,gtx
	jr	gettextloop
gtbackspace:
	ld	a,(port)
	cp	b
	jr	z,gettextloop
	inc	b
	dec	hl
	ld	a,' '
	bcall	_putmap
	ld	a,(curcol)
	or	a
	jr	z,gtbsneedline
	dec	a
	ld	(curcol),a
	ld	a,' '
	bcall	_putmap
	jp	gettextloop
gtbsneedline:
	ld	a,15
	ld	(curcol),a
	ld	a,(currow)
	dec	a
	ld	(currow),a
	ld	a,' '
	bcall	_putmap
	jp	gettextloop
gtnumber:
	add	a,48
	ld	(hl),a
	inc	hl
	bcall	_putc
gtndjnz:
	djnz	gettextloop
	jr	gtfinished
gtcomma:
	ld	a,','
	jr	gtlloadval
gtletter:
	or	a
	jr	z,gtspace
	add	a,64
gtlloadval
	ld	(hl),a
	inc	hl
	bcall	_putc
	jr	gtndjnz
gtques:
	ld	a,'?'
	jr	gtlloadval
gtx:
	ld	a,'X'
	jr	gtlloadval
gtspace:
	ld	a,32
	jr	gtlloadval
gtclear:
	ld	hl,0
	ld	(currow),hl
	ld	hl,args
	res	appautoscroll,(iy+appflags)
	call	disptext
	ld	hl,(command)
	ld	(currow),hl
	ld	b,25
	jp	gettext
gtfinished:
	ld	(hl),0
	ld	a,' '
	bcall	_putmap
	res	curable,(iy+curflags)
	res	appautoscroll,(iy+appflags)
	ret
;consoleerrorh:
;	bcall	_newline
;	ld	hl,cerrconsole
;	call	disptext
;	bcall	_newline
;	ld	hl,consoleerrorh
;	call	$59
;	jp	consoleloop
console:
;	ld	hl,consoleerrorh
;	call	$59
	call	prepscreen
consoleloop:
	ld	b,25
	call	gettext
	set appautoscroll,(iy+appflags)
	ld	hl,textbuf
	xor	a
	cp	(hl)
	jr	nz,connotblank
	bcall	_newline
	jr	consoleloop
connotblank
	bcall	_strlength
	ld	a,' '
	ld	hl,textbuf
	push	bc
	cpir
	pop	ix
	push	bc
	pop	de
	push	ix
	pop	bc
	jp	nz,parseaswhole
	ex	de,hl
	or	a
	sbc	hl,bc
	ex	de,hl			; hl -> byte after space
					; bc = length text before and including space
	dec	hl
	ld	(hl),0
	inc	hl			; make command 0 terminated

	push	bc
	ld	de,args
	ld	bc,255
	ldir				; load argument data
	pop	bc
	ld	hl,textbuf
	ld	de,command
	ldir				; load command data
	jp	parse
parseaswhole:
	xor	a
	ld	(args),a
	ld	hl,textbuf
	cp	(hl)
	jp	nz,entryexists
	bcall	_newline
	jp	consoleloop
entryexists
	ld	bc,255
	ld	de,command
	ldir
parse:
					; parse command in (command)
					; with arguments in (args)
					; handle errors
					; preform any neccisary screen output
					; advnace cursor

	ld	hl,parseconcomptab
	call	concomper
	bcall	_newline
	ld	hl,cerrcmd
	jp	disptextnewlineconsole

conset:
	ld	hl,ca
	call	concomps
	jp	z,conseta
	ld	hl,cb
	call	concomps
	jp	z,consetb
	ld	hl,cc
	call	concomps
	jp	z,consetc
	ld	hl,cd
	call	concomps
	jp	z,consetd
	ld	hl,ce
	call	concomps
	jp	z,consete
	ld	hl,cf
	call	concomps
	jp	z,consetf
	ld	hl,ch
	call	concomps
	jp	z,conseth
	ld	hl,cl
	call	concomps
	jp	z,consetl
consetnot1:
	ld	hl,caf
	call	concompss
	jp	z,consetaf
	ld	hl,cbc
	call	concompss
	jp	z,consetbc
	ld	hl,cde
	call	concompss
	jp	z,consetde
	ld	hl,chl
	call	concompss
	jp	z,consethl
	ld	hl,cix
	call	concompss
	jp	z,consetix
consetnot2:
	ld	hl,args
	call	isvalid2bytea
	ld	(op5),de
	jr	nz,consetnot3
	ex	de,hl
	ld	de,$8000
	or	a
	sbc	hl,de
	jp	c,carcerror
	ld	a,(args+4)
	cp	','
	jr	nz,consetnot3
	ld	hl,args+5
	ld	de,args+256
	call	isvalidbytestring
	jr	nz,consetnot3
	ld	b,0
	push	bc
	ld	de,(op5)
	push	de
	ld	hl,args+256
	ldir
	bcall	_newline
	pop	de
	push	de
	ld	a,d
	call	disphex
	pop	de
	ld	a,e
	call	disphex
	ld	hl,colonspace
	call	disptext
	ld	a,(args+256)
	call	disphex
	pop	bc
	ld	a,c
	dec	a
	ld	hl,dotstr
	call	nz,disptext
	bcall	_newline
	jp	consoleloop
	

consetnot3:
	jp	cargerror

consetaf:
	ld	a,(args+7)
	or	a
	jp	nz,consetnot2
	ld	hl,arg+3
	call	isvalid2byter
	jp	nz,consetnot2
	ld	(conaf),de
	push	de
	bcall	_newline
	ld	hl,caf
	jp	consetss
consetbc:
	ld	a,(args+7)
	or	a
	jp	nz,consetnot2
	ld	hl,arg+3
	call	isvalid2byter
	jp	nz,consetnot2
	ld	(conbc),de
	push	de
	bcall	_newline
	ld	hl,cbc
	jp	consetss
consetde:
	ld	a,(args+7)
	or	a
	jp	nz,consetnot2
	ld	hl,arg+3
	call	isvalid2byter
	jp	nz,consetnot2
	ld	(conde),de
	push	de
	bcall	_newline
	ld	hl,cde
	jp	consetss
consethl:
	ld	a,(args+7)
	or	a
	jp	nz,consetnot2
	ld	hl,arg+3
	call	isvalid2byter
	jp	nz,consetnot2
	ld	(conhl),de
	push	de
	bcall	_newline
	ld	hl,chl
	jp	consetss
consetix:
	ld	a,(args+7)
	or	a
	jp	nz,consetnot2
	ld	hl,arg+3
	call	isvalid2byter
	jp	nz,consetnot2
	ld	(conix),de
	push	de
	bcall	_newline
	ld	hl,cix
	jp	consetss
conseta:
	ld	a,(args+4)
	or	a
	jp	nz,consetnot1
	ld	hl,arg+2
	call	isvalid1byte
	jp	nz,consetnot1
	ld	(conaf),a
	push	af
	bcall	_newline

	ld	hl,ca
	jp	consets
consetb:
	ld	a,(args+4)
	or	a
	jp	nz,consetnot1
	ld	hl,arg+2
	call	isvalid1byte
	jp	nz,consetnot1
	ld	(conbc),a
	push	af
	bcall	_newline

	ld	hl,cb
	jp	consets
consetc:
	ld	a,(args+4)
	or	a
	jp	nz,consetnot1
	ld	hl,arg+2
	call	isvalid1byte
	jp	nz,consetnot1
	ld	(conbc+1),a
	push	af
	bcall	_newline

	ld	hl,cb
	jp	consets
consetd:
	ld	a,(args+4)
	or	a
	jp	nz,consetnot1
	ld	hl,arg+2
	call	isvalid1byte
	jp	nz,consetnot1
	ld	(conde),a
	push	af
	bcall	_newline

	ld	hl,cd
	jp	consets
consete:
	ld	a,(args+4)
	or	a
	jp	nz,consetnot1
	ld	hl,arg+2
	call	isvalid1byte
	jp	nz,consetnot1
	ld	(conde+1),a
	push	af
	bcall	_newline

	ld	hl,ce
	jp	consets
consetf:
	ld	a,(args+4)
	or	a
	jp	nz,consetnot1
	ld	hl,arg+2
	call	isvalid1byte
	jp	nz,consetnot1
	ld	(conaf+1),a
	push	af
	bcall	_newline

	ld	hl,cf
	jp	consets
conseth:
	ld	a,(args+4)
	or	a
	jp	nz,consetnot1
	ld	hl,arg+2
	call	isvalid1byte
	jp	nz,consetnot1
	ld	(conhl),a
	push	af
	bcall	_newline

	ld	hl,ch
	jr	consets
consetl:
	ld	a,(args+4)
	or	a
	jp	nz,consetnot1
	ld	hl,arg+2
	call	isvalid1byte
	jp	nz,consetnot1
	ld	(conhl+1),a
	push	af
	bcall	_newline

	ld	hl,cl
	jr	consets
consetss:
	call	disptext
	ld	hl,colonspace
	call	disptext
	pop	de
	push	de
	ld	a,e
	call	disphex
	pop	de
	ld	a,d
	call	disphex
	bcall	_newline
	jp	consoleloop
consets

	call	disptext
	ld	hl,colonspace
	call	disptext
	pop	af
	call	disphex
	bcall	_newline
	jp	consoleloop
	
conquit:
	res	curable,(iy+curflags)
	res	appautoscroll,(iy+appflags)
;	call	$5c
	jp	mainmenu
cargerror:
	bcall	_newline
	ld	hl,cerrarg
	jp	disptextnewlineconsole

isvalid2byter:
	call	isvalid2byte
	ld	a,d
	ld	d,e
	ld	e,a
	ret	
isvalid1byte:
	call	isvalid2entry
	ld	a,e
	ret
isvalid2bytea:
	ld	de,op4
	ld	bc,4
	ldir
	xor	a
	ld	(de),a
	ld	hl,op4
isvalid2byte:
			; input = hl = location of 4 bytes
			; output z = valid
			; output de = number
	push	hl
	bcall	_strlength
	pop	hl
	ld	a,c
	cp	4
	jp	nz,isval2no
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	call	ishexnum
	jp	nz,isval2no
	ld	(port),a
isvalid2entry:
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	call	ishexnum
	jp	nz,isval2no
	ld	e,a
	ld	a,(port)
	ld	d,a
	xor	a
	or	a
	ret
isval2no:
	xor	a
	inc	a
	ret
conjump:
	ld	a,$FE
	ld	(command),a
	jr	concall
conbcall:
	ld	a,$FF
	ld	(command),a
concall:
	ld	hl,argument
	call	isvalid2byte
	jp	nz,cargerror
	ld	(argument+1),de
	ld	hl,argument
	ld	(hl),$CD
	ld	hl,argument+3
	ld	(hl),$C9
	ld	(argument+1),de
	ld	a,(command)
	cp	$FE
	jr	nz,ccallnoj
	ld	a,$C3
	ld	(argument),a
ccallnoj:
	ld	a,(command)
	cp	$FF
	jr	nz,ccallnob
	ld	a,$EF
	ld	(argument),a
ccallnob
	call	loadvirregs
	call	argument
	call	savevirregs
	ld	hl,command
	ld	(hl),0
	bcall	_newline
	jp	consoleloop
ishexnum:
	ld	a,e
	sub	48
	cp	10
	jr	c,ishok1
	sub	65-48
	cp	6
	jr	nc,ishnogood
	add	a,$a
ishok1:
	push	af	
	ld	a,d
	sub	48
	cp	10
	jr	c,ishok2
	sub	65-48
	cp	6
	jr	nc,ishnogood
	add	a,$a
ishok2:
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	pop	de
	or	d
	ld	d,1
	dec	d
	ret
ishnogood:
	xor	a
	inc	a
	ret
	
	
conshow:

	ld	hl,ca
	call	concompa
	jp	z,conshowa
	ld	hl,cb
	call	concompa
	jp	z,conshowb
	ld	hl,cc
	call	concompa
	jp	z,conshowc
	ld	hl,cd
	call	concompa
	jp	z,conshowd
	ld	hl,ce
	call	concompa
	jp	z,conshowe
	ld	hl,cf
	call	concompa
	jp	z,conshowf
	ld	hl,ch
	call	concompa
	jp	z,conshowh
	ld	hl,cl
	call	concompa
	jp	z,conshowl
	ld	hl,caf
	call	concompa
	jp	z,conshowaf
	ld	hl,cbc
	call	concompa
	jp	z,conshowbc
	ld	hl,cde
	call	concompa
	jp	z,conshowde
	ld	hl,chl
	call	concompa
	jp	z,conshowhl
	ld	hl,cix
	call	concompa
	jp	z,conshowix	
	ld	hl,argument
	call	isvalid2byte
	jr	nz,conshowelse
	ld	a,(argument+4)
	or	a
	jr	z,conshowmem

conshowelse:
	bcall	_newline
	ld	hl,cshowscreen
	call	disptext
	ld	hl,(currow)
	push	hl
	push	hl
	ld	a,(conix)
	call	disphex
	ld	a,(conix+1)
	call	disphex
	ld	hl,(currow)
	inc	h
	inc	h
	inc	h
	inc	h
	dec	l
	ld	(currow),hl
	push	hl
	ld	a,(conhl)
	call	disphex
	ld	a,(conhl+1)
	call	disphex
	pop	hl
	dec	l
	ld	(currow),hl
	ld	a,(conbc)
	call	disphex
	ld	a,(conbc+1)
	call	disphex
	pop	hl
	dec	l
	push	hl
	ld	(currow),hl
	ld	a,(conde)
	call	disphex
	ld	a,(conde+1)
	call	disphex
	pop	hl
	dec	l
	ld	(currow),hl
	ld	a,(conaf)
	call	disphex
	ld	a,(conaf+1)
	call	disphex
	pop	hl
	ld	(currow),hl
	bcall	_newline
	jp	consoleloop
conshowmem:
	push	de
	bcall	_newline
	pop	de
	push	de
	push	de
	ld	a,d
	call	disphex
	pop	de
	ld	a,e
	call	disphex
	ld	hl,colonspace
	call	disptext
	pop	de
	ld	a,(de)
	call	disphex
	bcall	_newline
	jp	consoleloop
conshowa:
	ld	a,(conaf)
	ld	hl,ca
	jr	cshows
conshowb
	ld	a,(conbc)
	ld	hl,cb
	jr	cshows
conshowc:
	ld	a,(conbc+1)
	ld	hl,cc
	jr	cshows
conshowd:
	ld	a,(conde)
	ld	hl,cd
	jr	cshows
conshowe:
	ld	a,(conde+1)
	ld	hl,ce
	jr	cshows
conshowf:
	ld	a,(conaf+1)
	ld	hl,cf
	jr	cshows
conshowh:
	ld	a,(conhl)
	ld	hl,ch
	jr	cshows
conshowl:
	ld	a,(conhl+1)
	ld	hl,cl
cshows:
	push	af
	push	hl
	bcall	_newline
	pop	hl
	pop	af
	call	disptext
	ld	hl,colonspace
	call	disptext
	call	disphex
	bcall	_newline
	jp	consoleloop
conshowaf:
	ld	a,(conaf)
	ld	d,a
	ld	a,(conaf+1)
	ld	e,a
	ld	hl,caf
	jr	cshowss
conshowbc:
	ld	a,(conbc)
	ld	d,a
	ld	a,(conbc+1)
	ld	e,a
	ld	hl,cbc
	jr	cshowss
conshowde:
	ld	a,(conde)
	ld	d,a
	ld	a,(conde+1)
	ld	e,a
	ld	hl,cde
	jr	cshowss
conshowhl:
	ld	a,(conhl)
	ld	d,a
	ld	a,(conhl+1)
	ld	e,a
	ld	hl,chl
	jr	cshowss
conshowix:
	ld	a,(conix)
	ld	d,a
	ld	a,(conix+1)
	ld	e,a
	ld	hl,cix
cshowss:
	push	de
	push	af
	push	hl
	bcall	_newline
	pop	hl
	pop	af
	pop	de
	call	disptext
	ld	hl,colonspace
	call	disptext
	push	de
	ld	a,d
	call	disphex
	pop	de
	ld	a,e
	call	disphex
	bcall	_newline
	jp	consoleloop

concompss:
	ld	de,(args)
	ld	(tempnum),de
	ld	a,(args+2)
	ld	(tempnum+2),a
	xor	a
	ld	(tempnum+3),a
	ld	a,(hl)
	ld	(tempnum+4),a
	inc	hl
	ld	a,(hl)
	ld	(tempnum+5),a
	ld	a,','
	ld	(tempnum+6),a
	xor	a
	ld	(tempnum+7),a
	ld	de,tempnum
	ld	hl,tempnum+4
	jr	concomploop
	

concomps:
	ld	de,(args)
	ld	(tempnum),de
	xor	a
	ld	(tempnum+2),a
	ld	a,(hl)
	ld	(tempnum+3),a
	ld	a,','
	ld	(tempnum+4),a
	xor	a
	ld	(tempnum+5),a
	ld	hl,tempnum+3
	ld	de,tempnum
	jr	concomploop
concompa:
	ld	de,args
	jr	concomploop	
concomper:
					; executes concomps and jumps for con comp table
					; pointed to by hl
					; returns if no equal found
	pop	bc
concomperloop:
	push	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	call	concomp
	pop	hl
	jr	z,concompergood
	ld	de,4
	add	hl,de
	ld	a,(hl)
	push	bc
	or	a
	jr	z,concomperbad
	pop	bc
	jr	concomperloop
concompergood:
	inc	hl
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)
concomperbad:
	inc	hl
	ld	a,(hl)
	or	a
	ret	z
	dec	hl
	pop	bc
	jr	concomperloop
	
concomp:
	ld	de,textbuf
concomploop:
	ld	a,(de)
	cp	(hl)
	ret	nz
	inc	de
	inc	hl
	or	a
	ret	z
	jp	concomploop
loadvirregs:
	ld	hl,conaf
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	push	de
	pop	af
	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	push	de
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	push	de
	pop	ix
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	push	de
	pop	hl
	pop	de
	ret
savevirregs:
	ld	(conaf),a
	push	hl
	push	af
	pop	hl
	ld	a,l
	ld	(conaf+1),a
	push	ix
	pop	hl
	ld	a,h
	ld	(conix),a
	ld	a,l
	ld	(conix+1),a
	ld	a,d
	ld	(conde),a
	ld	a,e
	ld	(conde+1),a
	ld	a,b
	ld	(conbc),a
	ld	a,c
	ld	(conbc+1),a
	pop	hl
	ld	a,h
	ld	(conhl),a
	ld	a,l
	ld	(conhl+1),a
	ret
conhelp:
	ld	hl,cbcall
	call	concompa
	jp	z,conhelpbcall
	ld	hl,ccall
	call	concompa
	jp	z,conhelpcall
	ld	hl,cclearscreen
	call	concompa
	jp	z,conhelpclr
	ld	hl,cexec
	call	concompa
	jp	z,conhelpexec
	ld	hl,cjump
	call	concompa
	jp	z,conhelpjump
	ld	hl,crun
	call	concompa
	jp	z,conhelprun
	ld	hl,cset
	call	concompa
	jp	z,conhelpset
	ld	hl,cshow
	call	concompa
	jp	z,conhelpshow
	ld	hl,cquit
	call	concompa
	jp	z,conhelpquit
	bcall	_newline
	ld	hl,chelphelp
	jp	disptextnewlineconsole
conhelpbcall:
	ld	hl,chelpbcall
	jr	conhelps
conhelpcall:
	ld	hl,chelpcall
	jr	conhelps
conhelpclr:
	ld	hl,chelpclr
	jr	conhelps
conhelpexec:
	ld	hl,chelpexec
	jr	conhelps
conhelpjump:
	ld	hl,chelpjump
	jr	conhelps
conhelprun:
	ld	hl,chelprun
	jr	conhelps
conhelpset:
	ld	hl,chelpset
	jr	conhelps
conhelpshow:
	ld	hl,chelpshow
	jr	conhelps
conhelpquit:
	ld	hl,chelpquit
conhelps:
	push	hl
	bcall	_newline
	pop	hl
	jp	disptextnewlineconsole
conrun:
	ld	hl,args
	bcall	_strlength
	ld	a,c
	cp	9
	jp	nc,cargerror
	or	a
	jp	z,cargerror
	ld	(temp16),a
	ld	hl,args
	ld	de,op1+1
	ld	bc,9
	ldir
	ld	hl,op1
	push	hl
	ld	(hl),5
	bcall	_chkfindsym
	pop	hl
	jr	nc,conrunrun
	ld	(hl),6
	bcall	_chkfindsym
	jp	c,cargerror
conrunrun:
	ld	a,b
	or	a
	jp	z,conrunrunrun
carcerror:
	bcall	_newline
	ld	hl,cerrarc
	jp	disptextnewlineconsole
conrunrunrun:
	inc	de
	inc	de
	ld	a,(de)
	cp	$BB
	jr	nz,conrunie
	inc	de
	ld	a,(de)
	sub	$6D
	jp	z,runasm
	inc	a
	jp	z,runasm
conrunie
	bcall	_newline
	ld	hl,cerrbasic
	jp	disptextnewlineconsole

;	set	1,(iy+8)
;	ld	hl,progerrorh
;	call	$59
;	ld	hl,($89ec)
;	push	hl
;	bcall	_parseinp
;	call	$5c
;	pop	hl
;	ld	($89EC),hl
;	bcall	_newline
;	jp	consoleloop
;progerrorh:
;	call	$5c
;        bcall   _newline
;        ld      hl,cerrprog
;        call    disptext
;        bcall   _newline
;        jp      consoleloop
conexec:
	ld	hl,args
	bcall	_strlength
	ld	a,c
	or	a
	jp	z,cargerror
	and	1
	jp	nz,cargerror
	ld	de,args+256
	ld	hl,args
	call	isvalidbytestring
	jp	nz,cargerror
	call	loadvirregs
	call	args+256
	call	savevirregs
	bcall	_newline
	jp	consoleloop
isvalidbytestring:
				; input hl -> orginal string
				; de -> new string
				; output z = valid
				; c = length
	ld	c,0
isvalbsloop:
	push	de
	push	hl
	push	bc
	call	isvalid1byte
	pop	bc
	pop	hl
	pop	de
	jp	nz,isvalbsno
	ld	(de),a
	inc	de
	inc	hl
	inc	hl
	inc	c
	xor	a
	cp	(hl)
	jp	z,isvalbsyes
	jr	isvalbsloop
runasm:
	bcall	_op1toop5
	ld	hl,progname
	rst	20h
	ld	a,05
	ld	(op1),a
	ld	a,(temp16)
	ld	d,0
	ld	e,a
	ld	hl,3
	add	hl,de
	bcall	_createprog
;	ld	(hl),$16
	inc	de
	inc	de
	ld	a,$BB
	ld	(de),a
	inc	de
	ld	a,$6a
	ld	(de),a
	inc	de
	ld	a,$5f
	ld	(de),a
	inc	de
	ld	hl,op5+1
	ld	bc,8
	bcall	_strcopy
	bcall	_op4toop1
;	ld	hl,asmprogerrorh
;	call	$59
	bcall	_parseinp
;	call	$5c
	ld	hl,progname
	rst	20h
	bcall	_chkfindsym
	jr	c,yuck2
	bcall	_delvar
yuck2:
	bcall	_newline
	jp	consoleloop
;asmprogerrorh:
;	call	$5c
;        ld      hl,progname
;        rst     20h
;        bcall   _chkfindsym
;        jr      c,yuck1
;        bcall   _delvar
;yuck1:
;        bcall   _newline
;        ld      hl,cerrasmprog
;        call    disptext
;        bcall   _newline
;        jp      consoleloop
isvalbsno:
	xor	a
	inc	a
	ret
isvalbsyes:
	xor	a
	ret
quit:
 ; call	$5c
	bcall	_grbufclr
  call	$50   ;Exit the applicatio
 .dw	_JForceCmdNoChar

find0tab:
							; hl -> pointer to data table
							; b = which entry
	push	bc
	ld	b,3
	xor	a
	cpir
	pop	bc
	djnz	find0tab
	ret
about:
	call	prepscreen
	ld	hl,aboutscreen1
	call	disptextm
	call	getkey
	call	prepscreen
	ld	hl,aboutscreen2
	call	disptextm
	call	getkey
	call	prepscreen
	ld	hl,aboutscreen3
	call	disptextm
	call	getkey
	call	prepscreen
	ld	hl,aboutscreen4
	call	disptextm
	call	getkey
	jp	calcinfo
;	jp	mainmenu2
conhonk:
	bcall	_newline
	ld	hl,mkay
	jr	disptextnewlineconsole

conbubbob:
	bcall	_newline
	ld	hl,bbtxt
	jr	disptextnewlineconsole
congame:
	bcall	_newline
	ld	b,100
	call	ionrandom
	ld	(apdram),a
	ld	hl,gametxt1
	call	disptext
	ld	b,6
congameloop:
	push	bc
	bcall	_newline
	ld	hl,gametxt2
	call	disptext
	call	getnumerich
	ld	b,a
	ld	a,(apdram)
	cp	b
	jr	z,congamewin
	jr	c,congamehigh
	jr	congamelow
congameend:
	pop	bc
	djnz	congameloop
	bcall	_newline
	ld	hl,gametxt3
disptextnewlineconsole:
	call	disptext
	bcall	_newline
	jp	consoleloop
congamehigh:
	bcall	_newline
	ld	hl,gametxt4
	call	disptext
	jr	congameend
congamelow:
	bcall	_newline
	ld	hl,gametxt5
	call	disptext
	jr	congameend
congamewin
	bcall	_newline
	pop	bc
	ld	hl,gametxt6
	jr	disptextnewlineconsole
conrandom:
	bcall	_newline
	call	getnumerich
	ld	(temp16),a
	ld	b,5
conrandomloop:
	push	bc
	ld	a,(temp16)
	ld	b,a
	call	ionrandom
	ld	h,a
	ld	a,(temp16)
	ld	b,a
	call	ionrandom
	ld	l,a
	pop	bc
	push	hl
	djnz	conrandomloop
	pop	hl
	pop	ix
	pop	bc
	pop	de
	pop	af
	call	savevirregs
	bcall	_newline
	jp	consoleloop

conlangant:
	call	loadvirregs
      ld      (8267h-$8265+apdram),de
      ld      (826Bh-$8265+apdram),hl
	inc	a
	call	nz,prepscreen
	ld	de,3

      ld      (8265h-$8265+apdram),de
      ld      (8269h-$8265+apdram),de
	



mainloop:
	ld	a,0feh
	out	(1),a
	in	a,(1)
	cp	255
	jp	nz,consoleloop
        ld      de,(8265h-$8265+apdram)
	push	de
	pop	bc
        ld      de,(8267h-$8265+apdram)
	call	dotheant
        ld      (8267h-$8265+apdram),de
	push	bc
	pop	de
        ld      (8265h-$8265+apdram),de
        ld      de,(8269h-$8265+apdram)
	push	de
	pop	bc
        ld      de,(826Bh-$8265+apdram)
	call	dotheant
        ld      (826Bh-$8265+apdram),de
	push	bc
	pop	de
        ld      (8269h-$8265+apdram),de
	jr	mainloop



dotheant:
	ld	a,c
	or	a
	jp	nz,check2
	dec	d
check2:
	dec	a
	jp	nz,check3
	dec	e
check3:
	dec	a
	jp	nz,check4
	inc	d
check4:
	dec	a
	jp	nz,check5
	inc	e
check5:
	ld	a,d
	cp	255
	jp	nz,check55
	ld	d,95
	ld	a,d
check55:
	cp	96
	jp	c,check6
	ld	d,0
check6:
	ld	a,e
	cp	255
	jp	nz,check65
	ld	e,63
	ld	a,e
check65:
	cp	64
	jp	c,realcont
	ld	e,0
realcont
	

	push	de
	push	bc
	ld	a,d
        call    vectorc
	push	af
	push	hl
	xor	(hl)
	ld	(hl),a
        ld      a,(826Dh-$8265+apdram)
	inc	a
        ld      (826dh-$8265+apdram),a
	cp	35
	jr	nz,overhere
        bcall	_grbufcpy
	xor	a
        ld      (826dh-$8265+apdram),a
overhere:
	pop	hl
	pop	af
	pop	bc
	pop	de
	and	(hl)
	or	a
	jp	z,secondadd
	dec	c
	ld	a,c
	cp	255
	ret	nz
	ld	c,3
	ret
secondadd:
	inc	c
	ld	a,c
	cp	4
	ret	nz
	ld	c,0
	ret



getrands:
	ld	b,96
        call    vector1
	ld	d,a
	ld	b,64
        call    vector1                 
	ld	e,a
	ret
ionrandom:	push	hl
	push	de
	ld	hl,(data)
	ld	a,r
	ld	d,a
	ld	e,(hl)
	add	hl,de
	add	a,l
	xor	h
	ld	(data),hl
	ld	hl,0
	ld	e,a
	ld	d,h
randl:	add	hl,de
	djnz	randl
	ld	a,h
	pop	de
	pop	hl
nomore:	ret
iongetpixel:


	ld	d,$00
	ld	h,d
	ld	l,e
	add	hl,de
	add	hl,de
	add	hl,hl
	add	hl,hl
	ld	de,gbuf
	add	hl,de

;---------= Get the bit for a pixel =---------
; input:	a - x coordinate
;		hl - start location	; includes gbuf
; returns:	a - holds bit
;	hl - location + x coordinate/8
;	b=0
;	c=a/8
getbit:	ld	b,$00
	ld	c,a
	and	%00000111
	srl	c
	srl	c
	srl	c
	add	hl,bc
	ld	b,a
	inc	b
	ld	a,%00000001
gblp:	rrca
	djnz	gblp
	ret
conhex:
	bcall	_newline
	call	getnumerich
	push	af
	call	getnumerich
	ld	l,a
	pop	af
	ld	h,a
	bcall	_disphl
	bcall	_newline
	jp	consoleloop


consierpin:
	ld	hl,plotsscreen
	ld	bc,768
sierinit:
	ld	(hl),$FF
	inc	hl
	dec	bc
	ld	a,b
	or	c
	jr	nz,sierinit
	ld	de,30*256+30
mloop:	ld	b,3
	call	vector2
	dec	a
	jr	z,dispp
	ld	l,60
	dec	a
	jr	nz,mc3

mc2:	ld	a,e
	add	a,l		; (e+60)/2
	ld	e,a		; (d+30)/2
	ld	l,30

mc3:	ld	a,d		; (d+60)/2
	add	a,l		; e/2
	ld	d,a
	
dispp:	sra	d
	sra	e
	push	de
	push	hl
	ld	a,e
	sub	62
	cpl
	ld	e,a
	ld	a,d
	add	a,17
	call	vectorc
	cpl
	and	(hl)
	ld	(hl),a
	pop	hl
	dec	h
	jr	nz,overherer
	bcall	_grbufcpy
overherer:
	pop	de
	ld	a,0fdh
	out	(1),a
	in	a,(1)
	cp	191
	jr	nz,mloop
	bcall	_newline
	jp	consoleloop
vectorc = iongetpixel
vector1 = ionrandom
vector2	= ionrandom
#include	"text.txt"
#include	"dtabstr.txt"
#include	"dtabdata.txt"
.end
