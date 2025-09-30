; asm10.s — Maximum of three numbers
; Usage: ./asm10 A B C  -> print max(A,B,C) and exit 0
; If not enough args -> exit 1

section .bss
buf:    resb 32

section .data
nl:     db 10

section .text
global _start

; atoi signé
; IN:  rsi -> string
; OUT: rax = int64
atoi:
    xor     rax, rax
    mov     r9d, +1            ; signe
    mov     bl, [rsi]
    cmp     bl, '-'
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
    cmp     r9d, -1
    jne     .ret
    neg     rax
.ret:
    ret

; itoa signé
; IN:  rax = int64
; OUT: rsi -> string, rcx = len
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
    div     rbx
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

; main
_start:
    mov     rax, [rsp]          ; argc
    cmp     rax, 4              ; prog + 3 args
    jl      exit1

    ; argv[1] -> r8
    mov     rsi, [rsp+16]
    call    atoi
    mov     r8, rax

    ; argv[2] -> r9
    mov     rsi, [rsp+24]
    call    atoi
    mov     r9, rax

    ; argv[3] -> r10
    mov     rsi, [rsp+32]
    call    atoi
    mov     r10, rax

    ; max(r8, r9, r10) -> rax
    mov     rax, r8
    cmp     r9, rax
    jle     .skip1
    mov     rax, r9
.skip1:
    cmp     r10, rax
    jle     .have_max
    mov     rax, r10
.have_max:

    ; print max with newline
    call    itoa                ; rsi, rcx
    mov     rdx, rcx
    mov     rax, 1              ; write(1, buf, len)
    mov     rdi, 1
    syscall

    mov     rax, 1              ; write(1, "\n", 1)
    mov     rdi, 1
    mov     rsi, nl
    mov     rdx, 1
    syscall

exit0:
    mov     rax, 60             ; exit(0)
    xor     rdi, rdi
    syscall

exit1:
    mov     rax, 60             ; exit(1) if not enough args
    mov     rdi, 1
    syscall
