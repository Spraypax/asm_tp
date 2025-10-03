; asm05.s — print argv[1] + newline
; exit(0) if printed
; exit(1) if no argument

section .data
nl:     db 10
nllen:  equ $-nl

section .text
global _start

_start:
    mov     rax, [rsp]          ; argc
    cmp     rax, 2
    jl      exit1               ; pas d'argument -> exit(1)

    mov     rsi, [rsp+16]       ; argv[1] pointer

    ; calcul de la longueur (jusqu'au '\0')
    xor     rcx, rcx
.len:
    mov     al, [rsi+rcx]
    test    al, al
    je      .got_len
    inc     rcx
    jmp     .len

.got_len:
    ; write(1, argv[1], len)
    mov     rax, 1              ; SYS_write
    mov     rdi, 1
    mov     rdx, rcx
    syscall

    ; write(1, "\n", 1)
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, nl
    mov     rdx, nllen
    syscall

exit0:
    mov     rax, 60             ; SYS_exit
    xor     rdi, rdi            ; 0
    syscall

exit1:
    mov     rax, 60             ; SYS_exit
    mov     rdi, 1              ; 1
    syscall
