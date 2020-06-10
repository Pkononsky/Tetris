.model tiny
.code
org 	100h
locals @@
start:
	jmp     begin	

figures dw offset figure_1, offset figure_1_color, offset figure_2, offset figure_2_color, offset figure_3, offset figure_3_color, offset figure_4, offset figure_4_color, offset figure_5, offset figure_5_color, offset figure_6, offset figure_6_color, offset figure_7, offset figure_7_color, offset figure_8, offset figure_8_color, offset figure_9, offset figure_9_color, offset figure_10, offset figure_10_color
figureoffset dw 0	

figure_1 db 0, 0, 0, 0, 1, 0, 0, 0, 0
figure_1_color db 01h

figure_2 db 0, 0, 0, 0, 1, 1, 0, 0, 0
figure_2_color db 01h

figure_3 db 0, 0, 0, 1, 1, 1, 0, 0, 0
figure_3_color db 01h

figure_4 db 0, 0, 0, 0, 1, 1, 0, 1, 0
figure_4_color db 07h

figure_5 db 0, 1, 1, 0, 1, 0, 0, 1, 0
figure_5_color db 05h

figure_6 db 1, 1, 0, 0, 1, 0, 0, 1, 0
figure_6_color db 05h

figure_7 db 0, 1, 1, 0, 1, 1, 0, 0, 0
figure_7_color db 02h

figure_8 db 0, 1, 0, 1, 1, 0, 0, 1, 0
figure_8_color db 04h

figure_9 db 0, 1, 1, 1, 1, 0, 0, 0, 0
figure_9_color db 06h

figure_10 db 1, 1, 0, 0, 1, 1, 0, 0, 0
figure_10_color db 03h

current_figure db 9 dup(0)
current_figure_color db 0

next_figure db 9 dup(0)
next_figure_color db 0

movespeed: db 12
timemov: db 0	

gameovertext db 'G A M E  O V E R !!!'

scores_text db 'ОЧКИ:'
scores1 dw 0
scores2 dw 0

stop db 0

tail dw	buffer
head dw	buffer	
bufflen = 10	
buffer db 10 dup (0)
	
checkventmove proc near	
	cmp stop, 1
	je moveret
	inc	byte ptr cs:timemov	
	mov ah, byte ptr cs:movespeed
	cmp	byte ptr cs:timemov, ah
	jne	moveret
setmove:
	mov	byte ptr cs:timemov, 0
	mov al, 11h
	call write
moveret:	
	ret	
checkventmove endp

int08:
	push ax
	call checkventmove
	pop ax
trueint8:	
	db	0eah
old8 dw	0, 0

write proc near
	push	es
	push 	di
	push	cx
	push	ax
	mov 	cx,	tail
	push	cs
	pop	es
	mov	di,	tail
	mov	bl,	al
	cli
	stosb
	sti
	inc	tail
	cmp	tail, offset buffer + bufflen
	jnz	_5
	mov	tail,	offset	buffer
_5:
	xor	ax,	ax
	xor	bx,	bx
	mov	ax,	cs:tail
	mov	bx,	cs:head
	cmp	ax, bx
	jnz	_6
	mov	tail,	cx
_6:
	pop	ax
	pop cx
	pop	di
	pop	es
	ret
write endp

read proc near
	push	ds
	push	di
	push 	si
	push	ax
	push	cs
	pop	ds
	mov	si,	head
	cli
	lodsb
	sti
	mov	bl,	al
	inc	head
	cmp	head,	offset	buffer + bufflen
	jnz	_7
	mov	head,	offset	buffer
_7:
	pop	ax
	pop	si
	pop	di
	pop	ds
	ret
read endp

int09:
	push ax
	push di
	push es		
	in al, 60h
	
	cmp al, 48h	; стрелки
	je callw
	cmp al, 50h
	je callw
	cmp al, 4bh
	je callw
	cmp al, 4dh
	je callw
	cmp al, 39h	; space - стоп
	je callw
	cmp al, 1	; esc
	je callw
	cmp al, 13h ; r - поворот
	je callw
	cmp al, 16h ; u - уронить
	je callw
	cmp al, 19h ; p - пауза
	je callw
	cmp al, 0dh ; + скорость
	je callw
	cmp al, 0ch ; - скорость
	je callw
	cmp al, 31h ; n - новая игра
	je callw
	
	cmp al, 02h ; 1 скорость
	je callw	
	cmp al, 03h ; 2 скорость
	je callw
	cmp al, 04h ; 3 скорость
	je callw
	cmp al, 05h ; 4 скорость
	je callw
	cmp al, 06h ; 4 скорость
	je callw
	cmp al, 07h ; 6 скорость
	je callw
	cmp al, 08h ; 7 скорость
	je callw
	cmp al, 09h ; 8 скорость
	je callw
	cmp al, 0ah ; 9 скорость
	je callw
	
	cmp al, 57h ; f11 - редактор деталей
	je callw
	
callw:
	call write 
	
skipw:  
	in al, 61h    
	mov ah,	al
	or al, 80h    
	out 61h, al	
	nop
	nop
	nop
	xchg ah, al     
	out 61h, al
	mov al,	20h    
	out 20h, al    
	pop es
	pop di
	pop ax
	iret
old9 dw	0, 0

printfigure proc near
	push 0b800h
	pop es
	
	mov	bp,	sp
	mov di, [bp + 2]
	
	push cs
	pop ds
	mov si, offset current_figure
	
	mov cx, 9
	xor dx, dx
floop1:
	lodsb ; в al лежит 1 из 9 битов рисунка
	inc dx
	
	cmp dx, 4
	jne floop1c
	add di, 148
	mov dx, 1
floop1c:
	cmp	al, 1
	je floop1p
	add di, 4
	jmp floop1l
floop1p:
	mov al, 0dbh
	mov ah, current_figure_color
	stosw
	stosw
floop1l:
	loop floop1
	ret
printfigure endp

printnextfigure proc near
	push 0b800h
	pop es
	
	mov ax, 07dbh
	mov cx, 14
	mov di, 0
	rep stosw
	sub di, 4
	
	mov cx, 7
@@p1:
	stosw
	stosw
	add di, 156
	loop @@p1
	
	mov di, 0
	mov cx, 7
@@p2:
	stosw
	stosw
	add di, 156
	loop @@p2
	sub di, 160
	
	mov cx, 14
	rep stosw
	
	mov	bp,	sp
	mov di, [bp + 2]
	
	push cs
	pop ds
	mov si, offset next_figure
	
	mov cx, 9
	xor dx, dx
nfloop1:
	lodsb ; в al лежит 1 из 9 битов рисунка
	inc dx
	
	cmp dx, 4
	jne nfloop1c
	add di, 148
	mov dx, 1
nfloop1c:
	cmp	al, 1
	je nfloop1p
	add di, 4
	jmp nfloop1l
nfloop1p:
	mov al, 0dbh
	mov ah, next_figure_color
	stosw
	stosw
nfloop1l:
	loop nfloop1
	ret
printnextfigure endp

printspaces proc near
	push 0b800h
	pop es
	
	mov	bp,	sp
	mov di, [bp + 2]
	
	push cs
	pop ds
	mov si, offset current_figure	;адрес фигуры
	
	mov cx, 9
	xor dx, dx
sloop1:
	lodsb ; в al лежит 1 из 9 битов рисунка
	inc dx
	
	cmp dx, 4
	jne sloop1c
	add di, 148
	mov dx, 1
sloop1c:
	cmp	al, 1
	je sloop1p
	add di, 4
	jmp sloop1l
sloop1p:
	mov al, 39h
	mov ah, 0
	stosw
	stosw
sloop1l:
	loop sloop1
	ret
printspaces endp

checktouchleft proc near
	push 0b800h
	pop es
	
	mov	bp,	sp
	mov di, [bp + 2]
	
	push cs
	pop ds
	mov si, offset current_figure	;адрес фигуры
	
	mov cx, 9
	xor dx, dx
clloop1:
	lodsb ; в al лежит 1 из 9 битов рисунка
	inc dx
	
	cmp dx, 4
	jne clloop1c
	add di, 148
	mov dx, 1
clloop1c:
	cmp	al, 1
	je clloop1ch
	jmp clloop1l
clloop1ch:
	cmp dx, 1
	je clloop1chc
	sub si, 2
	lodsb
	inc si
	cmp al, 1
	je clloop1l
clloop1chc:
	push si
	push ds
	push 0b800h
	pop ds
	
	mov si, di
	sub si, 4
	lodsw
	pop ds
	pop si
	cmp ax, 0039h
	jne clloop1l2
clloop1l:
	add di, 4
	loop clloop1
	xor ax, ax
	ret
clloop1l2:
	mov ax, 1
	ret
checktouchleft endp

checktouchright proc near
	push 0b800h
	pop es
	
	mov	bp,	sp
	mov di, [bp + 2]
	
	push cs
	pop ds
	mov si, offset current_figure	;адрес фигуры
	
	mov cx, 9
	xor dx, dx
crloop1:
	lodsb ; в al лежит 1 из 9 битов рисунка
	inc dx
	
	cmp dx, 4
	jne crloop1c
	add di, 148
	mov dx, 1
crloop1c:
	cmp	al, 1
	je crloop1ch
	jmp crloop1l
crloop1ch:
	cmp dx, 3
	je crloop1chc
	lodsb
	dec si
	cmp al, 1
	je crloop1l
crloop1chc:
	push si
	push ds
	push 0b800h
	pop ds
	
	mov si, di
	add si, 4
	lodsw
	pop ds
	pop si
	cmp ax, 0039h
	jne crloop1l2
crloop1l:
	add di, 4
	loop crloop1
	xor ax, ax
	ret
crloop1l2:
	mov ax, 1
	ret
checktouchright endp

checktouchdown proc near
	push 0b800h
	pop es
	
	mov	bp,	sp
	mov di, [bp + 2]
	
	push cs
	pop ds
	mov si, offset current_figure	;адрес фигуры
	
	mov cx, 9
	xor dx, dx
cdloop1:
	lodsb ; в al лежит 1 из 9 битов рисунка
	inc dx
	
	cmp dx, 4
	jne cdloop1c
	add di, 148
	mov dx, 1
cdloop1c:
	cmp	al, 1
	je cdloop1ch
	jmp cdloop1l
cdloop1ch:
	cmp cx, 3
	jle cdloop1chc
	add si, 2
	lodsb
	sub si, 3
	cmp al, 1
	je cdloop1l
cdloop1chc:
	push si
	push ds
	push 0b800h
	pop ds
	
	mov si, di
	add si, 160
	lodsw
	pop ds
	pop si
	cmp ax, 0039h
	jne cdloop1l2
cdloop1l:
	add di, 4
	loop cdloop1
	xor ax, ax
	ret
cdloop1l2:
	mov ax, 1
	ret
checktouchdown endp

checktouchup proc near
	push 0b800h
	pop es
	
	mov	bp,	sp
	mov di, [bp + 2]
	
	push cs
	pop ds
	mov si, offset current_figure	;адрес фигуры
	
	mov cx, 9
	xor dx, dx
culoop1:
	lodsb ; в al лежит 1 из 9 битов рисунка
	inc dx
	
	cmp dx, 4
	jne culoop1c
	add di, 148
	mov dx, 1
culoop1c:
	cmp	al, 1
	je culoop1ch
	jmp culoop1l
culoop1ch:
	cmp cx, 7
	jge culoop1chc
	sub si, 4
	lodsb
	add si, 3
	cmp al, 1
	je culoop1l
culoop1chc:
	push si
	push ds
	push 0b800h
	pop ds
	
	mov si, di
	sub si, 160
	lodsw
	pop ds
	pop si
	cmp ax, 0039h
	jne culoop1l2
culoop1l:
	add di, 4
	loop culoop1
	xor ax, ax
	ret
culoop1l2:
	mov ax, 1
	ret
checktouchup endp

checkrotate proc near
	push 0b800h
	pop es
	
	mov	bp,	sp
	mov di, [bp + 2]
	
	push cs
	pop ds
	mov si, offset current_figure	;адрес фигуры
	
	mov cx, 9
	xor dx, dx
croloop1:
	lodsb ; в al лежит 1 из 9 битов рисунка
	inc dx
	
	cmp dx, 4
	jne croloop1c
	add di, 148
	mov dx, 1
croloop1c:
	cmp	al, 0
	je croloop1ch
	jmp croloop1l
croloop1ch:
	push si
	push ds
	
	push 0b800h
	pop ds	
	mov si, di
	lodsw
	
	pop ds
	pop si
	cmp ax, 0039h
	jne croloop1l2
croloop1l:
	add di, 4
	loop croloop1
	xor ax, ax
	ret
croloop1l2:
	mov ax, 1
	ret
checkrotate endp

printbariers proc near
	push 0b800h
	pop es
	
	mov di, 46
	mov cx, 25
	mov ax, 7739h
bloop1:	
	stosw
	stosw
	add di, 156
	loop bloop1
	
	mov di, 110
	mov cx, 25
	mov ax, 7739h
bloop2:	
	stosw
	stosw
	add di, 156
	loop bloop2
	
	mov di, 3890
	mov cx, 30
	mov ax, 7739h
	rep stosw
	
	ret
printbariers endp

addscores proc near
	push bx
	push ds
	push cs
	pop ds

	cmp scores1, 9
	jne nee
	cmp scores2, 60176
	je addscoresr	
nee:
	add scores2, 100
	jnb addscoresr
	add scores1, 1
	sub scores2, 65535
	dec scores2
addscoresr:
	pop ds
	pop bx
	ret
addscores endp

checkline proc near
	push ds
	push es

	push 0b800h
	push 0b800h
	pop ds
	pop es

	mov si, 50
	mov cx, 24
lineloop1:
	push cx
	mov cx, 30
lineloop2:
	lodsw
	cmp ax, 0039h
	je lineloop1c	
	loop lineloop2	
	
	call addscores
	
movelinesdown:
	std
	pop ax
	push ax
	mov cx, 25
	sub cx, ax
	push cx
	sub si, 2
	mov di, si
	sub si, 160
movelineloop:	
	push cx
	mov cx, 30
	rep movsw
	
	add si, 60
	add di, 60
	sub si, 160
	sub di, 160
	pop cx
	loop movelineloop
	cld
	pop cx
	inc cx
@@1:
	add si, 160
	loop @@1
	add si, 4
	
	mov di, 50
	mov cx, 30
	mov ax, 0039h
	rep stosw
	
lineloop1c:
	mov ax, 30
	sub ax, cx
	mov bh, 2
	mul bh
	sub si, ax
	sub si, 2
	add si, 160
	pop cx
	inc bx
	loop lineloop1
	
	pop es
	pop ds
	
	ret

checkline endp

newints proc near
	push 0
	pop es
	mov	ax,	word ptr es:[32]
	mov	bx,	word ptr es:[34]
	mov	old8, ax
	mov	old8+2, bx
	mov	ax,	offset int08
	mov	bx,	cs
	cli
	mov	es:[32], ax
	mov es:[34], bx
	sti
	
	mov	ax,	word ptr es:[36]
	mov	bx,	word ptr es:[38]
	mov	old9, ax
	mov	old9+2, bx
	mov	ax,	offset int09
	mov	bx,	cs
	cli
	mov	es:[36], ax
	mov es:[38], bx
	sti
	ret
newints endp

oldints proc near
	push 0
	pop	es
	mov	ax, old8
	mov	bx, old8+2
	cli
	mov	word ptr es:[32], ax
	mov	word ptr es:[34], bx
	sti

	push 0
	pop	es
	mov	ax, old9
	mov	bx, old9+2
	cli
	mov	word ptr es:[36], ax
	mov	word ptr es:[38], bx
	sti
	ret
oldints endp

printfield proc near
	push 0b800h
	pop es		
	xor di, di
	mov cx, 4000
	mov ax, 0039h
	rep stosw	
	ret
printfield endp

printfi proc near
	push bx
	push si
	push di
	push 0b800h
	pop es
	
	push cs
	pop ds
	
	mov cx, 9
	xor dx, dx
floop:
	lodsb ; в al лежит 1 из 9 битов рисунка
	inc dx
	
	cmp dx, 4
	jne floopc
	add di, 148
	mov dx, 1
floopc:
	cmp	al, 1
	je floopp
	add di, 4
	jmp floopl
floopp:
	mov al, 0dbh
	mov ah, bl
	stosw
	stosw
floopl:
	loop floop
	pop di
	pop si
	pop bx
	ret	
printfi endp

printbigfi proc near
	push 0b800h
	pop es
	
	mov	bp,	sp
	mov di, [bp + 2]
	
	push cs
	pop ds
	mov si, [bp + 4]
	
	mov cx, 9
	xor dx, dx
bfloop:
	lodsb ; в al лежит 1 из 9 битов рисунка
	inc dx
	
	cmp dx, 4
	jne bfloopc
	add di, 296
	mov dx, 1
bfloopc:
	cmp	al, 1
	je bfloopp
	add di, 8
	jmp bfloopl
bfloopp:
	mov bx, [bp + 6]
	mov al, 0dbh
	mov ah, bl
	stosw
	stosw
	stosw
	stosw
	add di, 152
	stosw
	push bx
	xor bx, bx
	mov bl, 9
	sub bx, cx
	mov al, 31h
	add al, bl
	shl ah, 4
	pop bx	
	stosw
	shr ah, 4
	mov al, 0dbh
	stosw
	stosw
	sub di, 160
bfloopl:
	loop bfloop	
	ret
printbigfi endp

printnum proc near
	push 0b800h
	pop es	
	mov	bp,	sp
	mov di, [bp + 2]
	add di, 644
	
	mov ax, [bp + 4]
	stosw
	
	sub di, 646
	ret	
printnum endp

dremuchiforest proc near
	mov si, offset figure_1
	xor bx, bx
	mov bl, figure_1_color
	mov di, 328
	
	call printfi
	
	push 0a31h
	push di
	call printnum
	pop di
	pop ax
	
	mov si, offset figure_2
	xor bx, bx
	mov bl, figure_2_color
	add di, 32
	
	call printfi
	
	push 0a32h
	push di
	call printnum
	pop di
	pop ax
	
	mov si, offset figure_3
	xor bx, bx
	mov bl, figure_3_color
	add di, 32
	
	call printfi
	
	push 0a33h
	push di
	call printnum
	pop di
	pop ax
	
	mov si, offset figure_4
	xor bx, bx
	mov bl, figure_4_color
	add di, 32
	
	call printfi
	
	push 0a34h
	push di
	call printnum
	pop di
	pop ax
	
	mov si, offset figure_5
	xor bx, bx
	mov bl, figure_5_color
	add di, 32
	
	call printfi
	
	push 0a35h
	push di
	call printnum
	pop di
	pop ax
	
	mov si, offset figure_6
	xor bx, bx
	mov bl, figure_6_color
	mov di, 1768
	
	call printfi
	
	push 0a36h
	push di
	call printnum
	pop di
	pop ax
	
	mov si, offset figure_7
	xor bx, bx
	mov bl, figure_7_color
	add di, 32
	
	call printfi
	
	push 0a37h
	push di
	call printnum
	pop di
	pop ax
	
	mov si, offset figure_8
	xor bx, bx
	mov bl, figure_8_color
	add di, 32
	
	call printfi
	
	push 0a38h
	push di
	call printnum
	pop di
	pop ax
	
	mov si, offset figure_9
	xor bx, bx
	mov bl, figure_9_color
	add di, 32
	
	call printfi
	
	push 0a39h
	push di
	call printnum
	pop di
	pop ax
	
	mov si, offset figure_10
	xor bx, bx
	mov bl, figure_10_color
	add di, 32
	
	call printfi
	
	push 0a41h
	push di
	call printnum
	pop di
	pop ax	
	ret
dremuchiforest endp

printsquarenums proc near
	push 0b800h
	pop es
	mov	bp,	sp
	mov di, [bp + 2]
	
	mov ax, 0a31h
	stosw
	
	add di, 6
	mov ax, 0a32h
	stosw
	
	add di, 6
	mov ax, 0a33h
	stosw
	
	add di, 302
	mov ax, 0a34h
	stosw
	
	add di, 6
	mov ax, 0a35h
	stosw
	
	add di, 6
	mov ax, 0a36h
	stosw
	
	add di, 302
	mov ax, 0a37h
	stosw
	
	add di, 6
	mov ax, 0a38h
	stosw
	
	add di, 6
	mov ax, 0a39h
	stosw
	ret
printsquarenums endp

field dw 2000 dup(0)
redactor proc near
	call oldints
	push es
	push ds
	push si
	push di
	
	push cs
	pop es
	push 0b800h
	pop ds
	xor si, si
	mov di, offset field
	mov cx, 2000
	rep movsw
	
	call printfield
;дремучий лес	
	call dremuchiforest
	call dremuchiforest
;дремучий лес

;дремучий лес2
redacloop:	
	xor ax, ax
	int 16h
	cmp ah, 1
	jne _r1
	jmp vixod
_r1:
	cmp ah, 02h
	jne _r2
	jmp redact1
_r2:
	cmp ah, 03h
	jne _r3
	jmp redact2
_r3:
	cmp ah, 04h
	jne _r4
	jmp redact3
_r4:
	cmp ah, 05h
	jne _r5
	jmp redact4
_r5:
	cmp ah, 06h
	jne _r6
	jmp redact5
_r6:
	cmp ah, 07h
	jne _r7
	jmp redact6
_r7:
	cmp ah, 08h
	jne _r8
	jmp redact7
_r8:
	cmp ah, 09h
	jne _r9
	jmp redact8
_r9:
	cmp ah, 0ah
	jne _r10
	jmp redact9
_r10:
	cmp ah, 1eh
	jne _r11
	jmp redact10
_r11:
	jmp redacloop
;дремучий лес2
redact1:
	mov si, offset figure_1
	xor bx, bx
	mov bl, figure_1_color
	jmp redacproc
redact2:
	mov si, offset figure_2
	xor bx, bx
	mov bl, figure_2_color
	jmp redacproc
redact3:
	mov si, offset figure_3
	xor bx, bx
	mov bl, figure_3_color
	jmp redacproc
redact4:
	mov si, offset figure_4
	xor bx, bx
	mov bl, figure_4_color
	jmp redacproc
redact5:
	mov si, offset figure_5
	xor bx, bx
	mov bl, figure_5_color
	jmp redacproc
redact6:
	mov si, offset figure_6
	xor bx, bx
	mov bl, figure_6_color
	jmp redacproc
redact7:
	mov si, offset figure_7
	xor bx, bx
	mov bl, figure_7_color
	jmp redacproc
redact8:
	mov si, offset figure_8
	xor bx, bx
	mov bl, figure_8_color
	jmp redacproc
redact9:
	mov si, offset figure_9
	xor bx, bx
	mov bl, figure_9_color
	jmp redacproc
redact10:
	mov si, offset figure_10
	xor bx, bx
	mov bl, figure_10_color
	jmp redacproc

	
redacproc:
	call printfield
	mov di, 1670
	push di
	call printsquarenums
	pop di
	sub di, 162
	push bx
	push si
	push di
	call printbigfi
	pop di
	pop si
	pop bx
	
	push cs
	pop ds
	push cs
	pop es
kek:
	xor ax, ax
	int 16h	

	cmp ah, 1
	je bf1
	cmp ah, 02h
	mov dx, 0
	je add1
	cmp ah, 03h
	mov dx, 1
	je add1
	cmp ah, 04h
	mov dx, 2
	je add1
	cmp ah, 05h
	mov dx, 3
	je add1
	cmp ah, 06h
	mov dx, 4
	je add1
	cmp ah, 07h
	mov dx, 5
	je add1
	cmp ah, 08h
	mov dx, 6
	je add1
	cmp ah, 09h
	mov dx, 7
	je add1
	cmp ah, 0ah
	mov dx, 8
	je add1
	jmp kek
bf1:
	push cs
	pop ds
	mov cx, 9
	xor dx, dx
bf1loop:
	lodsb
	cmp al, 1
	je bf1cont
	inc dx
bf1cont:
	loop bf1loop
	
	sub si, 9
	cmp dx, 9
	je kek
	
	call printfield
	call dremuchiforest
	jmp redacloop
add1:
	push si
	push di
	
	add si, dx
	lodsb
	dec si
	cmp al, 0
	je a1
	mov al, 0
	mov di, si
	stosb
	
	pop di
	pop si
	jmp redacproc
a1:
	mov al, 1
	mov di, si
	stosb
	
	pop di
	pop si
	jmp redacproc
	
vixod:
	push cs
	pop ds
	push 0b800h
	pop es
	mov si, offset field
	xor di, di
	mov cx, 2000
	rep movsw	
	
	pop di
	pop si
	pop ds
	pop es
	call newints
	ret
redactor endp

printscores proc near
	push 0b800h
	pop es
	
	mov di, 1442
	mov cx, 5	
scores_l:
	mov si, offset scores_text
	mov bx, 5
	sub bx, cx	
	add si, bx
	lodsb
	mov ah, 0eh
	stosw
	loop scores_l
	
	mov dx, scores1
	mov ax, scores2
	mov bx, 10
	mov cx, 6
scores_2:
	div bx
	push dx
	xor dx, dx
	loop scores_2
	
	mov cx, 6
scores3:
	pop ax
	add al, 30h
	mov ah, 0eh
	stosw
	loop scores3	
	ret	
printscores endp

begin:
	mov	ax,	3
	int	10h
	
	call newints
newgame:	
	call printfield
	mov scores1, 0
	mov scores2, 0
	call printscores
	call printbariers
	
;доп1
	xor ax, ax
	int 1ah
	mov al, dl
	mov bh, 10
	div bh
	
	mov al, ah
	xor ah, ah
	mov bh, 4
	mul bh
	mov figureoffset, ax
	
	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset figures
	add si, figureoffset
	lodsw
	mov si, ax ;адрес фигуры
	mov di, offset next_figure
	mov cx, 9
	rep movsb
	
	mov si, offset figures + 2
	add si, figureoffset
	lodsw
	mov si, ax
	lodsb
	mov next_figure_color, al ;цвет

;доп1
	
	jmp newfigure
_loop:		
	hlt
	mov	ax,	tail
	mov	bx,	head
	cmp	ax,	bx
	je	_loop
	call read	
	cmp	bl,	1
	jne	_cont
	jmp _exit
	
_cont:		
	cmp bl, 11h
	jne _c1
	jmp movedown
_c1:
	cmp bl, 48h
	jne _c2
	jmp moveup
_c2:	
	cmp bl, 50h
	jne _c3
	jmp movedown
_c3:	
	cmp bl, 4bh
	jne _c4
	jmp moveleft
_c4:	
	cmp bl, 4dh
	jne _c5
	jmp moveright
_c5:	
	cmp bl, 13h
	jne _c6
	jmp rotate
_c6:	
	cmp bl, 19h
	jne _c7
	jmp set_paus
_c7:	
	cmp bl, 39h
	jne _c8
	jmp resolve_stop
_c8:
	cmp bl, 16h
	jne _c9
	jmp drop
_c9:
	cmp bl, 0dh
	jne _c10
	jmp speedinc
_c10:
	cmp bl, 0ch
	jne _c11
	jmp speeddec
_c11:

	cmp bl, 02h
	jne _c12
	mov al, 4
	jmp setspeed
_c12:
	cmp bl, 03h
	jne _c13
	mov al, 6
	jmp setspeed
_c13:
	cmp bl, 04h
	jne _c14
	mov al, 8
	jmp setspeed
_c14:
	cmp bl, 05h
	jne _c15
	mov al, 10
	jmp setspeed
_c15:
	cmp bl, 06h
	jne _c16
	mov al, 12
	jmp setspeed
_c16:
	cmp bl, 07h
	jne _c17
	mov al, 14
	jmp setspeed
_c17:
	cmp bl, 08h
	jne _c18
	mov al, 16
	jmp setspeed
_c18:
	cmp bl, 09h
	jne _c19
	mov al, 18
	jmp setspeed
_c19:
	cmp bl, 0ah
	jne _c20
	mov al, 20
	jmp setspeed
_c20:
	cmp bl, 31h
	jne _c21
	jmp newgame
_c21:
	cmp bl, 57h
	jne _c22
	call redactor
	jmp _loop
_c22:
	jmp _loop
	
setspeed:
	mov byte ptr cs:movespeed, al
	mov	al, byte ptr cs:timemov
	cmp al, byte ptr cs:movespeed
	jl setspeedс
	mov byte ptr cs:timemov, 0
setspeedс:
	jmp _loop
	
speedinc:
	mov	al, byte ptr cs:timemov
	cmp al, byte ptr cs:movespeed
	jl speedincс
	mov byte ptr cs:timemov, 0
speedincс:
	cmp byte ptr cs:movespeed, 4
	je speedincb
	sub byte ptr cs:movespeed, 2
speedincb:
	jmp _loop
	
speeddec:
	cmp byte ptr cs:movespeed, 20
	je speeddecb
	add byte ptr cs:movespeed, 2
speeddecb:
	jmp _loop
	
drop:
	push di
	call printspaces
	pop di
	
	push di
	call checktouchdown
	pop di
	
	add di, 160
	
	cmp al, 1
	jne drop
	
	sub di, 160
	push di
	call printfigure
	pop di
	jmp newfigure
	
resolve_stop:
	cmp stop, 0
	je set_stop
	mov stop, 0
	jmp _loop	
set_stop:
	mov stop, 1
	jmp _loop
	
set_paus:
	call oldints
	
	xor ax, ax
	int 16h
	
	call newints
	jmp _loop
	
moveleft:
	push di
	call checktouchleft
	pop di
	
	cmp ax, 1
	jne moveleftc
	jmp _loop
moveleftc:
	
	push di
	call printspaces
	pop di
	
	sub di, 4
	
	push di
	call printfigure
	pop di
	
	jmp _loop
	
moveright:
	push di
	call checktouchright
	pop di
	
	cmp ax, 1
	jne moverightc
	jmp _loop
moverightc:
	
	push di
	call printspaces
	pop di
	
	add di, 4
	
	push di
	call printfigure
	pop di
	
	jmp _loop	
	
movedown:	
	push di
	call checktouchdown
	pop di
	
	cmp ax, 1
	jne movedowntc
	jmp newfigure
movedowntc:
	
	push di
	call printspaces
	pop di
	
	add di, 160
	
	push di
	call printfigure
	pop di
	
	jmp _loop

moveup:
	push di
	call checktouchup
	pop di
	
	cmp ax, 1
	jne moveupc
	jmp _loop
moveupc:
	push di
	call printspaces
	pop di
	
	sub di, 160
	
	push di
	call printfigure
	pop di
	
	jmp _loop
	
rotate:
	push di
	call checkrotate
	pop di
	
	cmp ax, 1
	jne rotatec
	jmp _loop
rotatec:

	push di
	call printspaces
	pop di

	push di
	push cs
	pop ds
	mov si, offset current_figure
	mov cx, 9
rloop:
	lodsb
	push ax	
	loop rloop
	
	push cs
	pop es

	mov dx, 6
	mov cx, 3
rloop1:
	pop ax
	mov di, offset current_figure
	add di, dx
	stosb
	sub dx, 3
	loop rloop1
	mov dx, 7
	mov cx, 3
rloop2:
	pop ax
	mov di, offset current_figure
	add di, dx
	stosb
	sub dx, 3
	loop rloop2
	mov dx, 8
	mov cx, 3
rloop3:
	pop ax
	mov di, offset current_figure
	add di, dx
	stosb
	sub dx, 3
	loop rloop3	
	pop di
	
	push di
	call printfigure
	pop di
	
	jmp _loop

newfigure:
	call checkline
	call printscores	
	
	push cs
	push cs
	pop es
	pop ds
	
	mov di, offset current_figure
	mov si, offset next_figure
	mov cx, 9
	rep movsw
	mov al, next_figure_color
	mov current_figure_color, al
	
	xor ax, ax
	int 1ah
	mov al, dl
	inc al
	inc al
	mov bh, 10
	div bh
	
	mov al, ah
	xor ah, ah
	mov bh, 4
	mul bh
	mov figureoffset, ax

	push cs
	push cs
	pop es
	pop ds
	
	mov si, offset figures
	add si, figureoffset
	lodsw
	mov si, ax ;адрес фигуры
	mov di, offset next_figure
	mov cx, 9
	rep movsb
	
	mov si, offset figures + 2
	add si, figureoffset
	lodsw
	mov si, ax
	lodsb
	mov next_figure_color, al ;цвет
	
	mov di, 328
	push di
	call printspaces
	pop di
	push di
	call printnextfigure
	pop di
	
	mov di, 74	
	push di
	call printfigure
	pop di
	
	push di
	call checktouchdown
	pop di
	
	cmp ax, 1
	jne nfc
	jmp gameover
nfc:
	jmp _loop
	
gameover:
	call oldints
	
printgameover:
	push 0b800h
	pop es
	
	mov di, 1982
	mov cx, 20	
gameoverl:
	mov si, offset gameovertext
	mov bx, 20
	sub bx, cx	
	add si, bx
	lodsb
	mov ah, 8eh
	stosw
	loop gameoverl
	
	xor ax, ax
	int 16h
	
	cmp ah, 1
	je _exit
	cmp ah, 31h
	jne	gameover
	call newints
	jmp newgame
	
_exit:
	call oldints
	
	db 0eah
	dw 7c00h, 0
dw	0aa55h
end start