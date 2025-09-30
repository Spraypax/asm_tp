; asm06.s — additionner deux nombres passés en argument et afficher le résultat

section .bss
buf:    resb 32          ; buffer pour la conversion du résultat

section .text
global _start

; Convertir argv[i] (chaine ascii) -> entier (rax)
; Entrée: rsi = pointeur vers chaine
; Sortie: rax = entier

atoi:
    xor     rax, rax        ; résultat
.parse:
    mov     bl, [rsi]
    cmp     bl, 0
    je      .done
    cmp     bl, 10          ; '\n'
    je      .done
    cmp     bl, '0'
    jl      .done
    cmp     bl, '9'
    jg      .done
    imul    rax, rax, 10
    sub     bl, '0'
    add     rax, rbx
    inc     rsi
    jmp     .parse
.done:
    ret

; Convertir entier rax -> ascii (buf)
; Entrée: rax = entier
; Sortie: rsi = pointeur vers buf, rcx = longueur

itoa:
    mov     rbx, 10
    mov     rcx, 0
    mov     rdi, buf+31     ; fin du buffer
    mov     byte [rdi], 0
.conv:
    xor     rdx, rdx
    div     rbx             ; rax / 10, reste -> rdx
    add     dl, '0'
    dec     rdi
    mov     [rdi], dl
    inc     rcx
    test    rax, rax
    jnz     .conv
    mov     rsi, rdi
    ret

; Programme principal

_start:
    mov     rax, [rsp]
    cmp     rax, 3
    jl      exit0           ; besoin de 2 args

    ; argv[1]
    mov     rsi, [rsp+16]
    call    atoi
    mov     r8, rax         ; sauver premier entier

    ; argv[2]
    mov     rsi, [rsp+24]
    call    atoi

    add     rax, r8         ; addition

    ; convertir en string
    call    itoa

    ; write(1, rsi, rcx)
    mov     rax, 1
    mov     rdi, 1
    mov     rdx, rcx
    syscall

    ; écrire un '\n'
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, nl
    mov     rdx, 1
    syscall

exit0:
    mov     rax, 60
    xor     rdi, rdi
    syscall

section .data
nl: db 10
