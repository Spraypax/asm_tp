; asm08.s — Sum of integers below N
; Usage: ./asm08 N
; Exemple: ./asm08 5 -> affiche 10 (1+2+3+4)

section .bss
buf:    resb 32          ; buffer pour itoa

section .data
nl:     db 10

section .text
global _start

; atoi simple (argv string -> rax int)

atoi:
    xor     rax, rax
.parse:
    mov     bl, [rsi]
    cmp     bl, 0
    je      .done
    cmp     bl, 10       ; '\n'
    je      .done
    cmp     bl, '0'
    jb      .done
    cmp     bl, '9'
    ja      .done
    imul    rax, rax, 10
    sub     bl, '0'
    add     rax, rbx
    inc     rsi
    jmp     .parse
.done:
    ret


; itoa (rax -> ascii dans buf)
; OUT: rsi=ptr, rcx=len

itoa:
    mov     rbx, 10
    mov     rcx, 0
    mov     rdi, buf+31
    mov     byte [rdi], 0
    test    rax, rax
    jnz     .loop
    dec     rdi
    mov     byte [rdi], '0'
    mov     rcx, 1
    mov     rsi, rdi
    ret
.loop:
    xor     rdx, rdx
    div     rbx
    add     dl, '0'
    dec     rdi
    mov     [rdi], dl
    inc     rcx
    test    rax, rax
    jnz     .loop
    mov     rsi, rdi
    ret


; main

_start:
    mov     rax, [rsp]       ; argc
    cmp     rax, 2
    jl      exit1            ; pas d’arg -> exit(1)

    mov     rsi, [rsp+16]    ; argv[1]
    call    atoi             ; rax = N

    cmp     rax, 1
    jle     zero_sum

    mov     rcx, rax
    dec     rcx              ; on fait 1..N-1
    xor     rbx, rbx         ; somme = 0
.sumloop:
    add     rbx, rcx
    loop    .sumloop

    mov     rax, rbx         ; résultat -> rax
    jmp     print_result

zero_sum:
    xor     rax, rax

print_result:
    call    itoa
    ; write(1, rsi, rcx)
    mov     rax, 1
    mov     rdi, 1
    mov     rdx, rcx
    syscall

    ; newline
    mov     rax, 1
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
