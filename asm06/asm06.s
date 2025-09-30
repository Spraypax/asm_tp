; asm06.s — additionner deux nombres (signés) en arguments et afficher le résultat
; OK pour: positifs, négatifs, zéro, et "no params" -> exit 1

section .bss
buf:    resb 32              ; buffer pour itoa

section .data
nl:     db 10

section .text
global _start


; atoi signé
; IN : rsi -> string (argv[i])
; OUT: rax = int64

atoi:
    xor     rax, rax            ; résultat
    mov     r9d, +1             ; signe = +1
    mov     bl, [rsi]
    cmp     bl, '-'             ; signe négatif ?
    jne     .check_plus
    mov     r9d, -1
    inc     rsi
    jmp     .parse
.check_plus:
    cmp     bl, '+'
    jne     .parse
    inc     rsi

.parse:
    mov     bl, [rsi]
    cmp     bl, 0
    je      .end
    cmp     bl, '0'
    jb      .end
    cmp     bl, '9'
    ja      .end
    imul    rax, rax, 10
    sub     bl, '0'
    add     rax, rbx
    inc     rsi
    jmp     .parse

.end:
    ; appliquer le signe
    cmp     r9d, -1
    jne     .ret
    neg     rax
.ret:
    ret

; itoa signé
; IN : rax = int64
; OUT: rsi -> début chaîne, rcx = longueur

itoa:
    mov     r10, rax            ; conserver valeur originale
    mov     rbx, 10
    mov     rcx, 0
    mov     rdi, buf+31
    mov     byte [rdi], 0

    ; si 0 -> écrire '0'
    test    rax, rax
    jnz     .check_neg
    dec     rdi
    mov     byte [rdi], '0'
    mov     rcx, 1
    mov     rsi, rdi
    ret

.check_neg:
    mov     r8b, 0              ; flag négatif ?
    test    rax, rax
    jge     .conv
    neg     rax
    mov     r8b, 1

.conv:
    xor     rdx, rdx
    div     rbx                 ; rax/=10, rdx=reste
    add     dl, '0'
    dec     rdi
    mov     [rdi], dl
    inc     rcx
    test    rax, rax
    jnz     .conv

    ; préfixer '-' si négatif
    cmp     r8b, 1
    jne     .finish
    dec     rdi
    mov     byte [rdi], '-'
    inc     rcx

.finish:
    mov     rsi, rdi
    ret

; main

_start:
    mov     rax, [rsp]          ; argc
    cmp     rax, 3              ; besoin de 2 args
    jl      exit1               ; -> exit 1 si pas assez d'args

    ; argv[1]
    mov     rsi, [rsp+16]
    call    atoi
    mov     r8, rax             ; sauver a

    ; argv[2]
    mov     rsi, [rsp+24]
    call    atoi

    add     rax, r8             ; a+b

    ; convertir et écrire
    call    itoa                ; rsi=buf, rcx=len
    mov     rax, 1              ; write(1, buf, len)
    mov     rdi, 1
    mov     rdx, rcx
    syscall

    ; '\n'
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, nl
    mov     rdx, 1
    syscall

exit0:
    mov     rax, 60             ; exit(0)
    xor     rdi, rdi
    syscall

exit1:
    mov     rax, 60             ; exit(1) si pas assez d'arguments
    mov     rdi, 1
    syscall
