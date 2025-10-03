; asm10.s — Maximum of three numbers (signed)
; Usage: ./asm10 A B C  -> prints max(A,B,C) and exits 0
; Not enough args -> exit 1

section .bss
buf:    resb 32

section .data
nl:     db 10

section .text
global _start

; ---------- signed atoi ----------
; IN : rsi -> C-string (optional leading '+' or '-')
; OUT: rax = int64 value
; Clobbers: rax, rbx, rcx, rdx, rsi
; Preserves: rbx (callee-saved)
atoi:
    push    rbx
    xor     rax, rax
    mov     ecx, +1              ; sign = +1

    mov     bl, [rsi]
    cmp     bl, '-'
    jne     .check_plus
    mov     ecx, -1
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
    cmp     ecx, -1
    jne     .ret
    neg     rax
.ret:
    pop     rbx
    ret

; ---------- signed itoa ----------
; IN : rax = int64 value
; OUT: rsi -> string, rcx = length
; Clobbers: rax, rbx, rcx, rdx, rdi
; Preserves: rbx (callee-saved)
itoa:
    push    rbx
    mov     rbx, 10
    mov     rcx, 0
    mov     rdi, buf+31
    mov     byte [rdi], 0

    ; zero ?
    test    rax, rax
    jnz     .check_neg
    dec     rdi
    mov     byte [rdi], '0'
    mov     rcx, 1
    mov     rsi, rdi
    pop     rbx
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
    pop     rbx
    ret

; ---------- main ----------
_start:
    mov     rax, [rsp]            ; argc
    cmp     rax, 4                ; need program + 3 args
    jne      exit1

    ; argv[1] -> r12
    mov     rsi, [rsp+16]
    call    atoi
    mov     r12, rax

    ; argv[2] -> r13
    mov     rsi, [rsp+24]
    call    atoi
    mov     r13, rax

    ; argv[3] -> r14
    mov     rsi, [rsp+32]
    call    atoi
    mov     r14, rax

    ; max signed: rax = max(r12, r13, r14)
    mov     rax, r12
    mov     rdx, r13
    cmp     rdx, rax
    cmovg   rax, rdx              ; if r13 > rax -> rax = r13

    mov     rdx, r14
    cmp     rdx, rax
    cmovg   rax, rdx              ; if r14 > rax -> rax = r14

    ; print result + newline
    call    itoa                  ; rsi, rcx set
    mov     rax, 1                ; write(1, buf, len)
    mov     rdi, 1
    mov     rdx, rcx
    syscall

    mov     rax, 1                ; write(1, "\n", 1)
    mov     rdi, 1
    mov     rsi, nl
    mov     rdx, 1
    syscall

exit0:
    mov     rax, 60               ; exit(0)
    xor     rdi, rdi
    syscall

exit1:
    mov     rax, 60               ; exit(1)
    mov     rdi, 1
    syscall
