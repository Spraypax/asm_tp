; asm04.s — lire un entier sur stdin
; exit 0 si pair, 1 si impair, 2 si entrée invalide
; bornage: magnitude <= INT_MAX (2147483647)

section .bss
buf:    resb 64

section .text
global _start

INT_MAX        equ 2147483647
INT_MAX_DIV10  equ 214748364     ; INT_MAX / 10
INT_MAX_LAST   equ 7             ; INT_MAX % 10

_start:
    ; read(0, buf, 64)
    mov     rax, 0
    mov     rdi, 0
    mov     rsi, buf
    mov     rdx, 64
    syscall
    cmp     rax, 0
    jle     bad_input                 ; rien lu

    mov     rcx, rax                  ; nb octets lus
    mov     rsi, buf                  ; pointeur de lecture
    xor     rbx, rbx                  ; rbx = valeur absolue accumulée
    xor     r8,  r8                   ; r8 = nb de chiffres
    xor     r9,  r9                   ; r9 = flag signe (1 si '-')

    ; signe optionnel
    mov     al, [rsi]
    cmp     al, '-'
    jne     .check_plus
    mov     r9, 1                     ; négatif
    inc     rsi
    dec     rcx
    jmp     .parse
.check_plus:
    cmp     al, '+'
    jne     .parse
    inc     rsi
    dec     rcx

.parse:
    cmp     rcx, 0
    je      .end                      ; fin de tampon

    mov     al, [rsi]
    ; fin propre sur LF/CR
    cmp     al, 10
    je      .end
    cmp     al, 13
    je      .end

    ; chiffre ?
    cmp     al, '0'
    jb      bad_input
    cmp     al, '9'
    ja      bad_input

    ; overflow check avant rbx = rbx*10 + d
    mov     rdx, rbx
    ; if rbx > INT_MAX_DIV10 -> overflow
    cmp     rbx, INT_MAX_DIV10
    ja      bad_input
    ; if rbx == INT_MAX_DIV10 and d > INT_MAX_LAST -> overflow
    jne     .mul_add
    movzx   r10, al
    sub     r10, '0'
    cmp     r10, INT_MAX_LAST
    ja      bad_input

.mul_add:
    ; rbx = rbx*10 + (al-'0')
    shl     rbx, 3                    ; *8
    lea     rbx, [rbx + rdx*2]        ; +*2 -> *10
    sub     al, '0'
    movzx   rdx, al
    add     rbx, rdx

    inc     r8
    inc     rsi
    dec     rcx
    jmp     .parse

.end:
    ; aucun chiffre lu -> invalide
    cmp     r8, 0
    je      bad_input

    ; parité sur la valeur absolue accumulée
    test    rbx, 1
    jz      is_even

    ; impair -> exit(1)
    mov     rax, 60
    mov     rdi, 1
    syscall

is_even:
    ; pair -> exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall

bad_input:
    mov     rax, 60
    mov     rdi, 2
    syscall
