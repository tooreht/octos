global start

section .text
bits 32
start:
    ; Write "Hello, World!" to screen
    ;
    ;   size place      thing
    ;   |    |          |
    ;   V    V          V
    mov word [0xb8000], 0x0248 ; H
    ;            |           |
    ;            V           |
    ; memory mapped screen,  |
    ; starting at upper left |
    ; corner                /
    ;                      /
    ;                     V
    ;
    ;   __ background color
    ; /  __foreground color
    ; | /
    ; V V
    ; 0 2 48 <- letter, in ASCII
    mov word [0xb8002], 0x0265 ; e
    mov word [0xb8004], 0x026c ; l
    mov word [0xb8006], 0x026c ; l
    mov word [0xb8008], 0x026f ; o
    mov word [0xb800a], 0x022c ; ,
    mov word [0xb800c], 0x0220 ;
    mov word [0xb800e], 0x0277 ; W
    mov word [0xb8010], 0x026f ; o
    mov word [0xb8012], 0x0272 ; r
    mov word [0xb8014], 0x026c ; l
    mov word [0xb8016], 0x0264 ; d
    mov word [0xb8018], 0x0221 ; !
    mov word [0xb801a], 0x0220 ;

    hlt
