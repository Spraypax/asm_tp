; asm15.s — ELF x64 binary detection
; Exit 0 if file is ELF x86-64, else exit 1

section .bss
buf:    resb 64

section .text
global _start

_start:
    ; need argv[1]
    mov     rax, [rsp]        ; argc
    cmp     rax, 2
    jl      exit1

    ; fd = openat(AT_FDCWD, argv[1], O_RDONLY)
    mov     rax, 257          ; SYS_openat
    mov     rdi, -100         ; AT_FDCWD
    mov     rsi, [rsp+16]     ; pathname
    xor     rdx, rdx          ; O_RDONLY = 0
    xor     r10, r10          ; mode ignored for RDONLY
    syscall
    test    rax, rax
    js      exit1
    mov     r12, rax          ; save fd

    ; n = read(fd, buf, 64)
    mov     rax, 0            ; SYS_read
    mov     rdi, r12
    mov     rsi, buf
    mov     rdx, 64
    syscall
    cmp     rax, 20           ; need at least 20 bytes for e_machine
    jl      close_and_exit1

    ; ---- Checks ----
    ; Magic 0..3 = 0x7F,'E','L','F'
    mov     eax, dword [buf]
    cmp     eax, 0x464C457F    ; little-endian: 'F''L''E'\x7F -> 0x7F454C46? Wait:
                               ; Better check byte-by-byte:
                               ; we'll do it explicitly below
    ; (we won't rely on the dword compare; do bytes)
    ; b0
    mov     al,  [buf+0]
    cmp     al, 0x7F
    jne     close_and_exit1
    ; b1
    mov     al,  [buf+1]
    cmp     al, 'E'
    jne     close_and_exit1
    ; b2
    mov     al,  [buf+2]
    cmp     al, 'L'
    jne     close_and_exit1
    ; b3
    mov     al,  [buf+3]
    cmp     al, 'F'
    jne     close_and_exit1

    ; EI_CLASS == 2 (ELFCLASS64)
    mov     al, [buf+4]
    cmp     al, 2
    jne     close_and_exit1

    ; e_machine (uint16 little-endian) at offset 18 == 0x003E (EM_X86_64)
    movzx   eax, word [buf+18]
    cmp     ax, 0x003E
    jne     close_and_exit1

    ; All checks passed → exit 0
    ; close(fd)
    mov     rax, 3            ; SYS_close
    mov     rdi, r12
    syscall
    mov     rax, 60
    xor     rdi, rdi
    syscall

close_and_exit1:
    mov     rax, 3
    mov     rdi, r12
    syscall
exit1:
    mov     rax, 60
    mov     rdi, 1
    syscall
