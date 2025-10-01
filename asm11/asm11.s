; asm11.s — Count vowels in string from stdin
; Usage: echo "assemblage" | ./asm11
; Output: 4

section .bss
buf:    resb 256          ; buffer input
outbuf: resb 32           ; pour itoa

section .data
nl:     db 10

section .text
global _start

; itoa unsigned
; IN:  rax = int
; OUT: rsi = ptr, rcx = len
itoa:
    mov     rbx, 10
    mov     rcx, 0
    mov     rdi, outbuf+31
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
    ; read(0, buf, 256)
    mov     rax, 0
    mov     rdi, 0
    mov     rsi, buf
    mov     rdx, 256
    syscall
    cmp     rax, 0
    jle     exit1             ; pas d’entrée

    mov     rcx, rax          ; nombre d’octets lus
    mov     rsi, buf
    xor     rbx, rbx          ; compteur voyelles

.nextchar:
    cmp     rcx, 0
    je      .done
    mov     al, [rsi]

    cmp     al, 10            ; ignorer '\n'
    je      .skip

    ; check voyelles min
    cmp     al, 'a'
    je      .inc
    cmp     al, 'e'
    je      .inc
    cmp     al, 'i'
    je      .inc
    cmp     al, 'o'
    je      .inc
    cmp     al, 'u'
    je      .inc

    ; check voyelles maj
    cmp     al, 'A'
    je      .inc
    cmp     al, 'E'
    je      .inc
    cmp     al, 'I'
    je      .inc
    cmp     al, 'O'
    je      .inc
    cmp     al, 'U'
    je      .inc

    jmp     .skip

.inc:
    inc     rbx

.skip:
    inc     rsi
    dec     rcx
    jmp     .nextchar

.done:
    mov     rax, rbx
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
