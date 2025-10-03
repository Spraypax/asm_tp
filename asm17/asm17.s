; asm17.s — Caesar cipher (x86_64 Linux, NASM)
; Usage:
;   echo "hello"        | ./asm17 3    -> khoor
;   echo 'Hello, World!'| ./asm17 5    -> Mjqqt, Btwqi!
;   echo "abcXYZ"       | ./asm17 -2   -> yzaVWX

section .bss
inbuf:  resb 1024
outbuf: resb 1024

section .data
nl:     db 10

section .text
global _start

; -------- atoi signé (32-bit) --------
; IN : rsi -> c-string
; OUT: eax = int32 (signed)
atoi_signed32:
    xor     eax, eax           ; result
    mov     edi, +1            ; sign
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
    ; ----- vérifier argc -----
    mov     rax, [rsp]         ; argc
    cmp     rax, 2
    jl      .exit1             ; besoin d'un décalage en argument

    ; ----- lire le décalage -----
    mov     rsi, [rsp+16]      ; argv[1]
    call    atoi_signed32      ; EAX = shift (signé)

    ; normaliser: (shift % 26 + 26) % 26  -> BL (0..25)
    mov     ecx, 26
    cdq                         ; EDX:EAX pour idiv signé
    idiv    ecx                 ; EDX = reste signé
    mov     eax, edx            ; EAX = reste
    add     eax, 26
    cdq
    idiv    ecx
    mov     ebx, edx            ; EBX = shift final (0..25)
    mov     bl, bl              ; on utilisera BL

    ; ----- lire stdin -----
    mov     rax, 0              ; SYS_read
    mov     rdi, 0
    mov     rsi, inbuf
    mov     rdx, 1024
    syscall
    cmp     rax, 0
    jle     .print_nl_exit
    mov     r8, rax             ; r8 = octets lus

    ; déterminer la longueur utile L (arrêt sur '\n' s'il existe)
    xor     r9, r9              ; r9 = L
    mov     rcx, r8
    mov     rsi, inbuf
.len_scan:
    cmp     rcx, 0
    je      .have_len
    mov     al, [rsi]
    cmp     al, 10              ; '\n'
    je      .have_len
    inc     r9
    inc     rsi
    dec     rcx
    jmp     .len_scan
.have_len:
    test    r9, r9
    jz      .print_nl_exit

    ; ----- chiffrer -----
    mov     rsi, inbuf
    mov     rdi, outbuf
    mov     rcx, r9             ; compteur de caractères
.enc_loop:
    mov     al, [rsi]

    ; minuscules 'a'..'z'
    cmp     al, 'a'
    jb      .check_upper
    cmp     al, 'z'
    ja      .check_upper
    sub     al, 'a'             ; 0..25
    add     al, bl              ; + shift
    cmp     al, 26
    jb      .lower_ok
    sub     al, 26
.lower_ok:
    add     al, 'a'
    mov     [rdi], al
    jmp     .advance

.check_upper:
    ; majuscules 'A'..'Z'
    cmp     al, 'A'
    jb      .store_other
    cmp     al, 'Z'
    ja      .store_other
    sub     al, 'A'
    add     al, bl
    cmp     al, 26
    jb      .upper_ok
    sub     al, 26
.upper_ok:
    add     al, 'A'
    mov     [rdi], al
    jmp     .advance

.store_other:
    mov     [rdi], al           ; ponctuation/espace inchangé

.advance:
    inc     rsi
    inc     rdi
    dec     rcx
    jnz     .enc_loop

    ; write(outbuf, L)
    mov     rax, 1              ; SYS_write
    mov     rdi, 1
    mov     rsi, outbuf
    mov     rdx, r9
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

.exit1:
    mov     rax, 60
    mov     rdi, 1
    syscall
