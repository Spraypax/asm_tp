; asm07.s — Prime test from stdin
; exit 0 = prime
; exit 1 = non-prime
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

    ; parse unsigned integer (digits until '\n'/'\r')
    mov     rcx, rax           ; bytes lus
    mov     rsi, buf
    xor     rbx, rbx           ; rbx = n
    xor     r8,  r8            ; r8 = nb de chiffres vus

.parse_loop:
    cmp     rcx, 0
    je      parsed
    mov     al, [rsi]

    cmp     al, 10             ; '\n'
    je      parsed
    cmp     al, 13             ; '\r'
    je      parsed

    cmp     al, '0'
    jb      bad_input          ; tout autre char ≠ digit/fin -> invalide
    cmp     al, '9'
    ja      bad_input

    ; rbx = rbx*10 + (al - '0')
    mov     rdx, rbx
    shl     rbx, 3
    lea     rbx, [rbx + rdx*2]
    sub     al, '0'
    movzx   rdx, al
    add     rbx, rdx

    inc     r8                 ; on a vu au moins un chiffre
    inc     rsi
    dec     rcx
    jmp     .parse_loop

parsed:
    cmp     r8, 0
    je      bad_input          ; pas de chiffres -> invalide

    ; n < 2 ? -> non premier
    cmp     rbx, 2
    jb      not_prime

    ; n == 2 ? -> premier
    je      is_prime

    ; pair ? -> non premier
    test    rbx, 1
    jz      not_prime

    ; tester les diviseurs impairs i = 3,5,7,... tant que i <= n/i
    mov     rdi, 3             ; i

.loop:
    mov     rax, rbx
    xor     rdx, rdx
    div     rdi                ; rax = q = n/i, rdx = r = n%i
    test    rdx, rdx
    jz      not_prime          ; divisible -> composite

    ; si i > q  (i*i > n) -> premier
    cmp     rdi, rax
    ja      is_prime

    add     rdi, 2             ; i += 2
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
