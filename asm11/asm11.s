; asm11.s — Count vowels in stdin (a,e,i,o,u,y + A,E,I,O,U,Y)
; Prints the count + '\n' and exits 0

section .bss
inbuf:   resb 512
outbuf:  resb 32

section .data
vowels:  db "aeiouyAEIOUY", 0
nl:      db 10

section .text
global _start

; itoa unsigned
; IN : rax = non-negative integer
; OUT: rsi -> string, rcx = length
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
    ; read(0, inbuf, 512)
    mov     rax, 0
    mov     rdi, 0
    mov     rsi, inbuf
    mov     rdx, 512
    syscall
    ; rax = bytes read (peut être 0 si EOF)
    mov     rcx, rax           ; compteur de bytes restants à traiter
    mov     rsi, inbuf
    xor     rbx, rbx           ; rbx = compteur de voyelles

.next_char:
    cmp     rcx, 0
    je      .done
    mov     al, [rsi]

    ; ignorer le LF (echo ajoute un '\n')
    cmp     al, 10
    je      .advance

    ; tester l'appartenance à "aeiouyAEIOUY"
    mov     rdi, vowels
.chk_loop:
    mov     dl, [rdi]
    test    dl, dl
    je      .advance           ; fin de la table -> pas voyelle
    cmp     al, dl
    je      .is_vowel
    inc     rdi
    jmp     .chk_loop

.is_vowel:
    inc     rbx

.advance:
    inc     rsi
    dec     rcx
    jmp     .next_char

.done:
    mov     rax, rbx
    call    itoa               ; rsi, rcx = string du nombre

    ; write(1, result, len)
    mov     rax, 1
    mov     rdi, 1
    mov     rdx, rcx
    syscall

    ; write(1, "\n", 1)
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, nl
    mov     rdx, 1
    syscall

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall
