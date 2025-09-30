; asm04.s - lire un entier depuis stdin
; exit 0 si pair, 1 si impair, 2 si entrée invalide

section .bss
buf:    resb 32

section .text
global _start

_start:
    ; read(0, buf, 32)
    mov     rax, 0
    mov     rdi, 0
    mov     rsi, buf
    mov     rdx, 32
    syscall
    cmp     rax, 0
    jle     bad_input            ; rien lu -> invalide

    mov     rcx, rax             ; nombre d'octets lus
    xor     rbx, rbx             ; accumulateur numérique
    mov     rsi, buf             ; pointeur de lecture
    xor     r8,  r8              ; r8 = nb de chiffres vus (0 = aucun)

parse_loop:
    cmp     rcx, 0
    je      end_input

    mov     al, [rsi]

    ; Fin d'entrée propre (LF/CR) -> sortir
    cmp     al, 10               ; '\n'
    je      end_input
    cmp     al, 13               ; '\r'
    je      end_input

    ; Si pas un chiffre -> entrée invalide
    cmp     al, '0'
    jl      bad_input
    cmp     al, '9'
    jg      bad_input

    ; Accumuler: rbx = rbx*10 + (al - '0')
    mov     rdx, rbx
    shl     rbx, 3
    lea     rbx, [rbx + rdx*2]
    sub     al, '0'
    movzx   rdx, al
    add     rbx, rdx

    inc     r8                   ; au moins un chiffre lu
    inc     rsi
    dec     rcx
    jmp     parse_loop

end_input:
    ; Aucun chiffre vu -> invalide
    cmp     r8, 0
    je      bad_input

    ; Pair/impair ?
    test    rbx, 1
    jz      is_even

    ; odd -> exit(1)
    mov     rax, 60
    mov     rdi, 1
    syscall

is_even:
    ; even -> exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall

bad_input:
    ; invalide -> exit(2)
    mov     rax, 60
    mov     rdi, 2
    syscall
