;; fichier asm04.s

; asm04.s - lire un entier depuis stdin, exit 0 si pair, exit 1 si impair

section .bss
buf:    resb 32        ; buffer pour l'entrée

section .text
global _start

_start:
    ; read(0, buf, 32)
    mov     rax, 0      ; syscall: read
    mov     rdi, 0      ; fd = stdin
    mov     rsi, buf
    mov     rdx, 32
    syscall
    ; rax = nombre d'octets lus
    cmp     rax, 0
    jle     no_digits   ; si rien lu -> considérer comme erreur -> exit 1

    mov     rcx, rax    ; rcx = length
    xor     rbx, rbx    ; rbx = accumulator (valeur numérique)
    mov     rsi, buf    ; rsi pointe sur buffer

parse_loop:
    cmp     rcx, 0
    je      parsed
    mov     al, [rsi]   ; lire un caractère
    ; si caractère entre '0' et '9' -> accumuler
    cmp     al, '0'
    jl      finish_parsing
    cmp     al, '9'
    jg      finish_parsing
    ; rbx = rbx * 10 + (al - '0')
    mov     rdx, rbx
    shl     rbx, 3      ; rbx * 8
    lea     rbx, [rbx + rdx*2] ; rbx = rbx*8 + rdx*2 = rbx*10
    sub     al, '0'
    movzx   rdx, al
    add     rbx, rdx
    inc     rsi
    dec     rcx
    jmp     parse_loop

finish_parsing:
    ; non-digit encountered -> stop parsing
    jmp     parsed

parsed:
    ; test bit0 : if rbx & 1 == 0 -> even
    test    rbx, 1
    jz      is_even

no_digits:
    ; exit(1)
    mov     rax, 60
    mov     rdi, 1
    syscall

is_even:
    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall
