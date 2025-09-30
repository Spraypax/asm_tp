; asm05.s — print argv[1] + newline, exit(0)

section .data
nl:     db 10
nllen:  equ $-nl

section .text
global _start

_start:
    ; argc = [rsp]
    mov     rax, [rsp]
    cmp     rax, 2
    jl      exit0              ; pas d'argument -> rien à afficher, exit 0

    ; argv[1] = [rsp+16]
    mov     rsi, [rsp+16]      ; rsi -> string

    ; strlen(argv[1]) -> rcx
    xor     rcx, rcx
.len:
    mov     al, [rsi+rcx]
    test    al, al
    je      .got_len
    inc     rcx
    jmp     .len

.got_len:
    ; write(1, argv[1], rcx)
    mov     rax, 1             ; SYS_write
    mov     rdi, 1             ; stdout
    mov     rdx, rcx           ; len
    syscall

    ; write(1, "\n", 1)
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, nl
    mov     rdx, nllen
    syscall

exit0:
    mov     rax, 60            ; SYS_exit
    xor     rdi, rdi           ; code 0
    syscall
