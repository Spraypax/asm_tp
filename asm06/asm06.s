; asm06.s — additionner deux nombres signés (argv[1] + argv[2])
; Affiche le résultat + '\n', exit(0)
; Erreurs :
;   - pas exactement 2 paramètres -> exit(1)
;   - paramètre non numérique (entier non strict) -> exit(1)

section .bss
buf:    resb 32

section .data
nl:     db 10

section .text
global _start

; ---------------- atoi signé strict ----------------
; IN : rsi -> string
; OUT: rax = int64
;      r11 = 1 si valide, 0 sinon (au moins un chiffre, fin strict '\0')
atoi:
    xor     rax, rax
    mov     r11, 1               ; valid = 1 par défaut
    mov     r9d, +1              ; sign = +1

    mov     bl, [rsi]
    cmp     bl, '-'
    jne     .check_plus
    mov     r9d, -1
    inc     rsi
    jmp     .check_first_digit
.check_plus:
    cmp     bl, '+'
    jne     .check_first_digit
    inc     rsi

.check_first_digit:
    ; doit commencer par un chiffre
    mov     bl, [rsi]
    cmp     bl, '0'
    jb      .invalid
    cmp     bl, '9'
    ja      .invalid

    ; au moins un chiffre -> boucle
.parse:
    mov     bl, [rsi]
    cmp     bl, 0
    je      .end_strict
    cmp     bl, '0'
    jb      .invalid
    cmp     bl, '9'
    ja      .invalid
    imul    rax, rax, 10
    sub     bl, '0'
    add     rax, rbx
    inc     rsi
    jmp     .parse

.end_strict:
    ; appliquer signe
    cmp     r9d, -1
    jne     .ret
    neg     rax
.ret:
    ret

.invalid:
    xor     r11, r11             ; valid = 0
    ; rax (valeur) est ignorée par l'appelant en cas d'invalidité
    ret

; ---------------- itoa signé ----------------
; IN : rax = int64
; OUT: rsi -> buffer, rcx = len
itoa:
    mov     rbx, 10
    mov     rcx, 0
    mov     rdi, buf+31
    mov     byte [rdi], 0

    test    rax, rax
    jnz     .check_neg
    dec     rdi
    mov     byte [rdi], '0'
    mov     rcx, 1
    mov     rsi, rdi
    ret

.check_neg:
    mov     r8b, 0
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
    cmp     r8b, 1
    jne     .done
    dec     rdi
    mov     byte [rdi], '-'
    inc     rcx
.done:
    mov     rsi, rdi
    ret

; ---------------- main ----------------
_start:
    mov     rax, [rsp]          ; argc
    cmp     rax, 3
    jne     exit1               ; besoin EXACTEMENT 2 params

    ; argv[1]
    mov     rsi, [rsp+16]
    call    atoi
    mov     r13, rax            ; a
    test    r11, r11
    jz      exit1               ; non numérique -> exit(1)

    ; argv[2]
    mov     rsi, [rsp+24]
    call    atoi
    test    r11, r11
    jz      exit1

    add     rax, r13            ; a+b

    ; print
    call    itoa                ; rsi, rcx
    mov     rax, 1              ; write(1, buf, len)
    mov     rdi, 1
    mov     rdx, rcx
    syscall

    mov     rax, 1              ; newline
    mov     rdi, 1
    mov     rsi, nl
    mov     rdx, 1
    syscall

exit0:
    mov     rax, 60
    xor     rdi, rdi
    syscall

exit1:
    mov     rax, 60
    mov     rdi, 1
    syscall
