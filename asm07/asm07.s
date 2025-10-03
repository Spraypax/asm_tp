; asm07.s — Prime test from stdin
; exit 0 = prime
; exit 1 = non-prime (inclut nombres négatifs)
; exit 2 = bad input

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
    jle     bad_input          ; rien lu -> invalide

    mov     rcx, rax           ; bytes lus
    mov     rsi, buf
    xor     rbx, rbx           ; rbx = n (magnitude)
    xor     r8,  r8            ; r8 = nb de chiffres vus
    xor     r9,  r9            ; r9 = 1 si signe négatif

    ; ---- signe optionnel ----
    mov     al, [rsi]
    cmp     al, '-'
    jne     .check_plus
    mov     r9, 1              ; négatif
    inc     rsi
    dec     rcx
    jmp     .parse
.check_plus:
    cmp     al, '+'
    jne     .parse
    inc     rsi
    dec     rcx

    ; ---- parse des chiffres jusqu'à \n/\r ----
.parse:
    cmp     rcx, 0
    je      parsed
    mov     al, [rsi]

    cmp     al, 10             ; '\n'
    je      parsed
    cmp     al, 13             ; '\r'
    je      parsed

    cmp     al, '0'
    jb      bad_input
    cmp     al, '9'
    ja      bad_input

    ; rbx = rbx*10 + (al - '0')
    mov     rdx, rbx
    shl     rbx, 3
    lea     rbx, [rbx + rdx*2]
    sub     al, '0'
    movzx   rdx, al
    add     rbx, rdx

    inc     r8                 ; au moins un chiffre
    inc     rsi
    dec     rcx
    jmp     .parse

parsed:
    cmp     r8, 0
    je      bad_input          ; pas de chiffres -> invalide

    ; négatif -> non premier (exit 1)
    cmp     r9, 0
    jne     not_prime

    ; n < 2 ? -> non premier
    cmp     rbx, 2
    jb      not_prime

    ; n == 2 ? -> premier
    je      is_prime

    ; pair ? -> non premier
    test    rbx, 1
    jz      not_prime

    ; tester i = 3,5,7,... tant que i <= n/i
    mov     rdi, 3

.loop:
    mov     rax, rbx
    xor     rdx, rdx
    div     rdi                ; rax = n/i, rdx = n%i
    test    rdx, rdx
    jz      not_prime          ; divisible

    cmp     rdi, rax           ; i > n/i ? -> i*i > n
    ja      is_prime

    add     rdi, 2
    jmp     .loop

is_prime:
    mov     rax, 60            ; exit(0)
    xor     rdi, rdi
    syscall

not_prime:
    mov     rax, 60            ; exit(1)
    mov     rdi, 1
    syscall

bad_input:
    mov     rax, 60            ; exit(2)
    mov     rdi, 2
    syscall
