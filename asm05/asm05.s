; asm05.s — print argv[1] + newline, exit(0)

section .data
nl:     db 10
nllen:  equ $-nl

section .text
global _start

_start:
    mov     rax, [rsp]
    cmp     rax, 2
    jl      exit0

    mov     rsi, [rsp+16]

    xor     rcx, rcx
.len:
    mov     al, [rsi+rcx]
    test    al, al
    je      .got_len
    inc     rcx
    jmp     .len

.got_len:
    mov     rax, 1
    mov     rdi, 1
    mov     rdx, rcx
    syscall

    mov     rax, 1
    mov     rdi, 1
    mov     rsi, nl
    mov     rdx, nllen
    syscall

exit0:
    mov     rax, 60
    xor     rdi, rdi
    syscall
