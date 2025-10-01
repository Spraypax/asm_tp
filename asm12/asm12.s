; asm12.s — Reverse string from stdin
; Example: echo "Bonjour" | ./asm12  -> ruojnoB

section .bss
inbuf:   resb 1024
outbuf:  resb 1024

section .data
nl:      db 10

section .text
global _start

_start:
    ; rax = read(0, inbuf, 1024)
    mov     rax, 0              ; SYS_read
    mov     rdi, 0              ; stdin
    mov     rsi, inbuf
    mov     rdx, 1024
    syscall                     ; rax = bytes read
    cmp     rax, 0
    jle     .print_nl_exit      ; nothing -> just newline and exit

    ; Determine effective length L (stop at '\n' if present)
    mov     r10, 0              ; r10 = L
    mov     rcx, rax            ; rcx = bytes available
    mov     rsi, inbuf
.len_scan:
    cmp     rcx, 0
    je      .have_len
    mov     al, [rsi]
    cmp     al, 10              ; '\n'?
    je      .have_len
    inc     r10                 ; L++
    inc     rsi
    dec     rcx
    jmp     .len_scan
.have_len:

    ; If L == 0 -> just newline
    test    r10, r10
    jz      .print_nl_exit

    ; Reverse into outbuf
    lea     r8,  [inbuf + r10 - 1]  ; src (last char)
    mov     r9,  outbuf             ; dst
    mov     rcx, r10                 ; count
.rev_loop:
    mov     al, [r8]
    mov     [r9], al
    dec     r8
    inc     r9
    dec     rcx
    jnz     .rev_loop

    ; write(1, outbuf, L)
    mov     rax, 1              ; SYS_write
    mov     rdi, 1              ; stdout
    mov     rsi, outbuf
    mov     rdx, r10            ; length L
    syscall

.print_nl_exit:
    ; newline
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, nl
    mov     rdx, 1
    syscall

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall
