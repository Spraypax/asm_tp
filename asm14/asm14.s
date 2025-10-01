; asm14.s — write "Hello Universe!\n" to file given as argv[1]
; Usage:
;   ./asm14 output.txt
;   cat output.txt  -> Hello Universe!

section .data
msg     db "Hello Universe!", 0xA
msglen  equ $ - msg

section .text
global _start

_start:
    ; vérifier argc
    mov     rax, [rsp]         ; argc
    cmp     rax, 2
    jl      .no_arg            ; si < 2 → erreur

    ; récupérer argv[1]
    mov     rbx, [rsp + 16]    ; nom du fichier

    ; open(argv[1], O_WRONLY | O_CREAT | O_TRUNC, 0644)
    mov     rax, 2
    mov     rdi, rbx
    mov     rsi, 577           ; O_WRONLY | O_CREAT | O_TRUNC
    mov     rdx, 0o644
    syscall

    ; rax = fd
    mov     rdi, rax
    mov     rax, 1
    mov     rsi, msg
    mov     rdx, msglen
    syscall

    ; close(fd)
    mov     rax, 3
    syscall

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall

.no_arg:
    ; exit(1)
    mov     rax, 60
    mov     rdi, 1
    syscall
