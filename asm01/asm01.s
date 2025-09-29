;; fichier asm01.s

; asm01.s — Afficher "1337" puis exit(0) en x86_64 Linux

section .data
msg:    db "1337", 10        ; "1337\n"
len:    equ $ - msg

section .text
global _start

_start:
    ; write(1, msg, len)
    mov     rax, 1           ; syscall write
    mov     rdi, 1           ; fd = 1 (stdout)
    mov     rsi, msg         ; buffer
    mov     rdx, len         ; taille
    syscall

    ; exit(0)
    mov     rax, 60          ; syscall exit
    xor     rdi, rdi         ; code = 0
    syscall
