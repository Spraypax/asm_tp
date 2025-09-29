;; fichier asm02.s

; asm02.s — Lire stdin, comparer avec "42", afficher "1337" si égal

section .data
expect: db "42", 10       ; ce qu'on attend: "42\n"
elen:   equ $ - expect

msg:    db "1337", 10
mlen:   equ $ - msg

section .bss
buf:    resb 8            ; buffer pour stdin

section .text
global _start

_start:
    ; read(0, buf, 8)
    mov     rax, 0        ; syscall read
    mov     rdi, 0        ; fd = stdin
    mov     rsi, buf      ; buffer
    mov     rdx, 8        ; taille max
    syscall

    ; comparer avec "42\n"
    mov     rcx, elen     ; longueur attendue
    mov     rsi, buf
    mov     rdi, expect
compare_loop:
    mov     al, [rsi]
    mov     bl, [rdi]
    cmp     al, bl
    jne     not_equal
    inc     rsi
    inc     rdi
    loop    compare_loop

    ; si égal → write(1, msg, mlen)
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
