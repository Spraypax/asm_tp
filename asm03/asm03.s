;; fichier asm03.s

; asm03.s — Vérifier argv[1] == "42", afficher 1337 si égal

section .data
msg:    db "1337", 10
mlen:   equ $ - msg

section .text
global _start

_start:
    ; RSP -> argc (qword), argv[0] pointer, argv[1] pointer ...
    mov     rax, [rsp]        ; argc
    cmp     rax, 2
    jl      not_equal         ; si argc < 2 -> exit 1

    mov     rbx, [rsp + 16]   ; argv[1] pointer

    ; comparer argv[1][0] == '4'
    mov     al, [rbx]
    cmp     al, '4'
    jne     not_equal

    ; comparer argv[1][1] == '2'
    mov     al, [rbx + 1]
    cmp     al, '2'
    jne     not_equal

    ; argv[1][2] == 0 (fin de chaîne)
    mov     al, [rbx + 2]
    cmp     al, 0
    jne     not_equal

    ; égal -> write(1, msg, mlen)
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg
    mov     rdx, mlen
    syscall

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall

not_equal:
    ; exit(1)
    mov     rax, 60
    mov     rdi, 1
    syscall
