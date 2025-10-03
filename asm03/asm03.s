;; asm03.s — print 1337 if and only if there is exactly ONE arg and it's "42"

section .data
msg:    db "1337", 10
mlen:   equ $ - msg

section .text
global _start

_start:
    ; argc must be exactly 2 (program + 1 arg)
    mov     rax, [rsp]        ; argc
    cmp     rax, 2
    jne     not_equal         ; != 2 -> exit 1

    mov     rbx, [rsp + 16]   ; argv[1]

    ; argv[1] must be exactly "42"
    mov     al, [rbx]
    cmp     al, '4'
    jne     not_equal

    mov     al, [rbx + 1]
    cmp     al, '2'
    jne     not_equal

    mov     al, [rbx + 2]
    cmp     al, 0
    jne     not_equal

    ; match -> print 1337\n
    mov     rax, 1            ; write
    mov     rdi, 1
    mov     rsi, msg
    mov     rdx, mlen
    syscall

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall

not_equal:
    mov     rax, 60           ; exit(1)
    mov     rdi, 1
    syscall
