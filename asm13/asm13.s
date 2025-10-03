; asm13.s — Palindrome detection from stdin
section .bss
    buffer  resb 256

section .data
    msg_pal db '1', 10
    len_pal equ $-msg_pal
    msg_non db '0', 10
    len_non equ $-msg_non

section .text
    global _start

_start:
    ; read(0, buffer, 255)
    mov     rax, 0            ; sys_read
    mov     rdi, 0            ; stdin
    mov     rsi, buffer
    mov     rdx, 255
    syscall                   ; rax = bytes read
    cmp     rax, 0
    jle     is_palindrome     ; rien lu -> considérer palindrome

    ; déterminer longueur utile L (arrêt sur '\n' si présent)
    xor     rbx, rbx          ; rbx = L
    mov     rcx, rax          ; bytes disponibles
    mov     rdi, buffer
.len_scan:
    cmp     rcx, 0
    je      .have_len
    mov     al, [rdi]
    cmp     al, 10            ; '\n' ?
    je      .have_len
    inc     rbx               ; L++
    inc     rdi
    dec     rcx
    jmp     .len_scan
.have_len:

    ; si L <= 1 -> palindrome
    cmp     rbx, 1
    jbe     is_palindrome

    ; deux pointeurs: début (rsi) / fin (rdi)
    mov     rsi, buffer               ; start
    lea     rdi, [buffer + rbx - 1]   ; end

check_loop:
    cmp     rsi, rdi
    jae     is_palindrome             ; croisés -> OK
    mov     al, [rsi]
    mov     dl, [rdi]
    cmp     al, dl
    jne     not_palindrome
    inc     rsi
    dec     rdi
    jmp     check_loop

is_palindrome:
    ; print "1\n"
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_pal
    mov     rdx, len_pal
    syscall
    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall

not_palindrome:
    ; print "0\n"
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_non
    mov     rdx, len_non
    syscall
    ; exit(1)
    mov     rax, 60
    mov     rdi, 1
    syscall

