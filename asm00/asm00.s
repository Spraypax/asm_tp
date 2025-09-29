;; fichier asm00.s

section .text
global _start

_start:
    ; syscall: exit(0)
    mov rax, 60        ; numéro du syscall exit (Linux x86_64)
    xor rdi, rdi       ; code de retour = 0 (rdi = 0)
    syscall            ; appel système