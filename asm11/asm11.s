; asm11.s — Count vowels from stdin
; - ASCII vowels: aeiouyAEIOUY
; - UTF-8 latin-1 vowels (C3 xx) such as é, à, ö, Ä, Ü, … are also counted
; Prints the count + '\n', exit 0

section .bss
inbuf:   resb 1024
outbuf:  resb 32

section .data
ascii_vowels: db "aeiouyAEIOUY", 0
; list of second byte for UTF-8 sequences starting with 0xC3 that are vowels
u8_vow2: db 0x80,0x81,0x82,0x83,0x84,0x85,0x86, \
             0x88,0x89,0x8A,0x8B, \
             0x8C,0x8D,0x8E,0x8F, \
             0x92,0x93,0x94,0x95,0x96,0x98, \
             0x99,0x9A,0x9B,0x9C, \
             0x9D,0x9F, \
             0xA0,0xA1,0xA2,0xA3,0xA4,0xA5,0xA6, \
             0xA8,0xA9,0xAA,0xAB, \
             0xAC,0xAD,0xAE,0xAF, \
             0xB2,0xB3,0xB4,0xB5,0xB6,0xB8, \
             0xB9,0xBA,0xBB,0xBC, \
             0xBD,0xBF, 0
nl:      db 10

section .text
global _start

; ------------- itoa unsigned -------------
; IN : rax >= 0
; OUT: rsi -> string, rcx = len
itoa:
    mov     rbx, 10
    mov     rcx, 0
    mov     rdi, outbuf+31
    mov     byte [rdi], 0
    test    rax, rax
    jnz     .loop
    dec     rdi
    mov     byte [rdi], '0'
    mov     rcx, 1
    mov     rsi, rdi
    ret
.loop:
    xor     rdx, rdx
    div     rbx
    add     dl, '0'
    dec     rdi
    mov     [rdi], dl
    inc     rcx
    test    rax, rax
    jnz     .loop
    mov     rsi, rdi
    ret

; ------------- main -------------
_start:
    xor     r15, r15           ; r15 = compteur total de voyelles

.read_more:
    ; read(0, inbuf, 1024)
    mov     rax, 0
    mov     rdi, 0
    mov     rsi, inbuf
    mov     rdx, 1024
    syscall
    cmp     rax, 0
    jle     .finish_output     ; rax==0 -> EOF, rax<0 -> ignorer/finir

    mov     rcx, rax           ; bytes à traiter
    mov     rsi, inbuf

.next_char:
    cmp     rcx, 0
    je      .read_more
    mov     al, [rsi]

    ; ignorer LF (facile pour les tests avec echo)
    cmp     al, 10
    je      .adv1

    ; --- ASCII vowels?
    mov     rdi, ascii_vowels
.ascii_chk:
    mov     dl, [rdi]
    test    dl, dl
    je      .check_utf8
    cmp     al, dl
    je      .count1
    inc     rdi
    jmp     .ascii_chk

.check_utf8:
    ; UTF-8 latin-1 vowels: 0xC3 followed by a code in table
    cmp     al, 0xC3
    jne     .adv1
    cmp     rcx, 1              ; besoin d'au moins 2 octets
    jbe     .adv1
    mov     bl, [rsi+1]         ; second byte
    mov     rdi, u8_vow2
.utf8_chk:
    mov     dl, [rdi]
    test    dl, dl
    je      .adv1               ; pas une voyelle unicode -> avancer d'1
    cmp     bl, dl
    je      .count2
    inc     rdi
    jmp     .utf8_chk

.count2:                        ; voyelle unicode (2 octets)
    inc     r15
    add     rsi, 2
    sub     rcx, 2
    jmp     .next_char

.count1:                        ; voyelle ASCII (1 octet)
    inc     r15
.adv1:
    inc     rsi
    dec     rcx
    jmp     .next_char

.finish_output:
    mov     rax, r15
    call    itoa               ; rsi, rcx = string

    ; write(1, string, len)
    mov     rax, 1
    mov     rdi, 1
    mov     rdx, rcx
    syscall

    ; newline
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, nl
    mov     rdx, 1
    syscall

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall
