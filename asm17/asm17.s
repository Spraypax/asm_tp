section .bss
inbuf:  resb 1024
outbuf: resb 1024

section .data
nl: db 10

section .text
global _start

; ---- atoi signé ----
atoi_signed32:
    xor     eax, eax
    mov     edi, +1
    mov     dl, [rsi]
    cmp     dl, '-'
    jne     .chk_plus
    mov     edi, -1
    inc     rsi
    jmp     .parse
.chk_plus:
    cmp     dl, '+'
    jne     .parse
    inc     rsi
.parse:
    mov     dl, [rsi]
    cmp     dl, '0'
    jb      .done
    cmp     dl, '9'
    ja      .done
    imul    eax, eax, 10
    movzx   edx, byte [rsi]
    sub     edx, '0'
    add     eax, edx
    inc     rsi
    jmp     .parse
.done:
    cmp     edi, -1
    jne     .ret
    neg     eax
.ret:
    ret

_start:
    ; argc check
    mov     rax, [rsp]
    cmp     rax, 2
    jl      .exit1

    ; argv[1] = shift
    mov     rsi, [rsp+16]
    call    atoi_signed32   ; eax = shift

    ; normalize shift = (shift % 26 + 26) % 26
    mov     ecx, 26
    cdq
    idiv    ecx             ; eax/26
    mov     eax, edx        ; remainder
    add     eax, 26
    cdq
    idiv    ecx
    mov     ecx, edx        ; ecx = final shift (0..25)

    ; read stdin
    mov     rax, 0
    mov     rdi, 0
    mov     rsi, inbuf
    mov     rdx, 1024
    syscall
    mov     r8, rax         ; len

    mov     rsi, inbuf
    mov     rdi, outbuf
    mov     rcx, r8
.loop:
    cmp     rcx, 0
    je      .done_enc
    movzx   eax, byte [rsi]

    ; 'a'..'z'
    cmp     al, 'a'
    jb      .chk_upper
    cmp     al, 'z'
    ja      .chk_upper
    sub     al, 'a'
    add     eax, ecx
    cdq
    idiv    dword [rel const26]
    mov     eax, edx
    add     al, 'a'
    jmp     .store

.chk_upper:
    cmp     al, 'A'
    jb      .other
    cmp     al, 'Z'
    ja      .other
    sub     al, 'A'
    add     eax, ecx
    cdq
    idiv    dword [rel const26]
    mov     eax, edx
    add     al, 'A'
    jmp     .store

.other:
    ; keep char
.store:
    mov     [rdi], al
    inc     rsi
    inc     rdi
    dec     rcx
    jmp     .loop

.done_enc:
    ; write outbuf
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, outbuf
    mov     rdx, r8
    syscall

    ; newline
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, nl
    mov     rdx, 1
    syscall

    ; exit 0
    mov     rax, 60
    xor     rdi, rdi
    syscall

.exit1:
    mov     rax, 60
    mov     rdi, 1
    syscall

section .data
const26: dd 26
