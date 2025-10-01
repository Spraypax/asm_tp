; asm14.s — write "Hello Universe!\n" to file given as argv[1]
; Usage:
;   ./asm14 output.txt
;   cat output.txt  -> Hello Universe!

section .data
msg:    db "Hello Universe!", 10
msglen: equ $ - msg

section .text
global _start

_start:
    ; argc >= 2 ?
    mov     rax, [rsp]
    cmp     rax, 2
    jl      exit1

    ; filename = argv[1]
    mov     rsi, [rsp + 16]

    ; fd = openat(AT_FDCWD, filename, O_WRONLY|O_CREAT|O_TRUNC, 0644)
    ; sys_openat = 257, AT_FDCWD = -100
    mov     rax, 257                ; SYS_openat
    mov     rdi, -100               ; AT_FDCWD
    mov     rdx, 1 + 64 + 512       ; O_WRONLY | O_CREAT | O_TRUNC
    mov     r10, 0644               ; mode
    syscall
    ; rax = fd (>=0) or -errno (<0)
    test    rax, rax
    js      exit1
    mov     r12, rax                ; sauver fd

    ; write(fd, msg, msglen)
    mov     rax, 1                  ; SYS_write
    mov     rdi, r12
    mov     rsi, msg
    mov     rdx, msglen
    syscall
    test    rax, rax
    js      close_and_exit1

    ; close(fd)
    mov     rax, 3                  ; SYS_close
    mov     rdi, r12
    syscall
    test    rax, rax
    js      exit1

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall

close_and_exit1:
    ; tenter de fermer fd avant de quitter en erreur
    mov     rax, 3
    mov     rdi, r12
    syscall
exit1:
    mov     rax, 60
    mov     rdi, 1
    syscall
