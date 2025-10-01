; asm11.s — Count vowels in string from stdin (a,e,i,o,u,y + A,E,I,O,U,Y)
; Output: number + '\n', exit 0

section .bss
buf:    resb 256          ; input buffer
outbuf: resb 32           ; for itoa

section .data
nl:     db 10

section .text
global _start

; itoa unsigned
; IN:  rax = non-negative integer
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
    ; rax = bytes read (peut être 0 si EOF)

    mov     rcx, rax          ; length
    mov     rsi, buf
    xor     rbx, rbx          ; vowel counter

.nextchar:
    cmp     rcx, 0
    je      .done
    mov     al, [rsi]

    cmp     al, 10            ; ignore '\n'
    je      .skip

    ; vowels lowercase
    cmp     al, 'a'  ; a
    je      .inc
    cmp     al, 'e'  ; e
    je      .inc
    cmp     al, 'i'  ; i
    je      .inc
    cmp     al, 'o'  ; o
    je      .inc
    cmp     al, 'u'  ; u
    je      .inc
    cmp     al, 'y'  ; y
    je      .inc

    ; vowels uppercase
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
    cmp     al, 'Y'
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

    ; write(1, result, len)
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

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall
