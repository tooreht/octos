global start

section .text
bits 32
start:

    ; Point the first entry of the level 4 page table
    ; to the first entry in the p3 table.
    mov eax, p3_table
    or eax, 0b11
    mov dword [p4_table + 0], eax
    ; Point the first entry of the level 3 page table
    ; to the first entry in the p2 table.
    mov eax, p2_table
    or eax, 0b11
    mov dword [p3_table + 0], eax
    ; Point each page table level two entry to a page.
    mov ecx, 0  ; counter variable
.map_p2_table:
    mov eax, 0x200000   ; 2MiB
    mul ecx
    or eax, 0b10000011
    mov [p2_table + ecx * 8], eax

    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ; Move page table address to cr3
    mov eax, p4_table
    mov cr3, eax

    ; Enable PAE (Physical Address Extension)
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Set the long mode bit
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Enable paging
    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax

    ; Tell the hardware about our GDT
    lgdt [gdt64.pointer] ; load global descriptor table

    ; update selectors
    mov ax, gdt64.data
    mov ss, ax
    mov ds, ax
    mov es, ax

    ; Jump to long mode!
    jmp gdt64.code:long_mode_start

section .bss ; block started by symbol
    ; Entries in the bss section are automatically set to zero
    ; by the linker.

    align 4096

    p4_table:
        resb 4096 ; reserve bytes
    p3_table:
        resb 4096
    p2_table:
        resb 4096

section .rodata
gdt64:
    dq 0    ; define quad-word
.code: equ $ - gdt64
    ; 44: ‘descriptor type’: This has to be 1 for code and data segments
    ; 47: ‘present’: This is set to 1 if the entry is valid
    ; 41: ‘read/write’: If this is a code segment, 1 means that it’s readable
    ; 43: ‘executable’: Set to `1 for code segments
    ; 53: ‘64-bit’: if this is a 64-bit GDT, this should be set
    dq (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53)
.data: equ $ - gdt64
    ; 44: ‘descriptor type’: This has to be 1 for code and data segments
    ; 47: ‘present’: This is set to 1 if the entry is valid
    ; 41: ‘read/write’: If this is a data segment, 1 means that it’s writable
    dq (1<<44) | (1<<47) | (1<<41)
.pointer:
    dw .pointer - gdt64 - 1
    dq gdt64

section .text
bits 64
long_mode_start:

    mov rax, 0x2f592f412f4b2f4f
    mov qword [0xb80a0], rax

    mov word [0xb80a8], 0x022c ; ,
    mov word [0xb80aa], 0x0220 ;

    ; Write "Hello, World!" to screen
    ;
    ;   size place      thing
    ;   |    |          |
    ;   V    V          V
    mov word [0xb80ac], 0x0248 ; H
    ;            |           |
    ;            V           |
    ; memory mapped screen,  |
    ; starting at upper left |
    ; corner with 0xb8000   /
    ;                      /
    ;                     V
    ;
    ;   __ background color
    ; /  __foreground color
    ; | /
    ; V V
    ; 0 2 48 <- letter, in ASCII
    mov word [0xb80ae], 0x0265 ; e
    mov word [0xb80b0], 0x026c ; l
    mov word [0xb80b2], 0x026c ; l
    mov word [0xb80b4], 0x026f ; o
    mov word [0xb80b6], 0x022c ; ,
    mov word [0xb80b8], 0x0220 ;
    mov word [0xb80ba], 0x0277 ; W
    mov word [0xb80bc], 0x026f ; o
    mov word [0xb80be], 0x0272 ; r
    mov word [0xb80c0], 0x026c ; l
    mov word [0xb80c2], 0x0264 ; d
    mov word [0xb80c4], 0x0221 ; !
    mov word [0xb80c6], 0x0220 ;

    hlt
