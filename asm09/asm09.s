; asm09.s — Convert decimal to hex or binary
; Usage:
;   ./asm09 N        -> affiche en HEX
;   ./asm09 -b N     -> affiche en BINAIRE

section .bss
buf:    resb 128          ; buffer pour itoa

section .data
nl:     db 10

section .text
global _start


; atoi (argv string -> int dans rax)

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

; itoa_hex (rax -> hex string dans buf)
; OUT: rsi, rcx = len

itoa_hex:
    mov     rbx, 16
    mov     rcx, 0
    mov     rdi, buf+127
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
    cmp     dl, 9
    jbe     .digit
    add     dl, 'A'-10
    jmp     .store
.digit:
    add     dl, '0'
.store:
    dec     rdi
    mov     [rdi], dl
    inc     rcx
    test    rax, rax
    jnz     .loop
    mov     rsi, rdi
    ret

; itoa_bin (rax -> binary string dans buf)
; OUT: rsi, rcx = len

itoa_bin:
    mov     rcx, 0
    mov     rdi, buf+127
    mov     byte [rdi], 0
    test    rax, rax
    jnz     .loop
    dec     rdi
    mov     byte [rdi], '0'
    mov     rcx, 1
    mov     rsi, rdi
    ret
.loop:
    test    rax, rax
    jz      .done
    mov     rdx, rax
    and     rdx, 1
    shr     rax, 1
    add     dl, '0'
    dec     rdi
    mov     [rdi], dl
    inc     rcx
    jmp     .loop
.done:
    mov     rsi, rdi
    ret


; main

_start:
    mov     rax, [rsp]       ; argc
    cmp     rax, 2
    jl      exit1

    ; argv[1]
    mov     rsi, [rsp+16]
    mov     r8, rsi          ; sauvegarde pour check -b
    mov     al, [rsi]
    cmp     al, '-'
    jne     normal_hex

    ; si "-b"
    mov     al, [rsi+1]
    cmp     al, 'b'
    jne     exit1
    cmp     rax, 3
    jl      exit1
    mov     rsi, [rsp+24]
    call    atoi
    call    itoa_bin
    jmp     print

normal_hex:
    call    atoi
    call    itoa_hex

print:
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
