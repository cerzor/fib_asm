section .data
    prompt db "Enter number of fibonacci numbers to calculate: ", 0
    prompt_len equ $ - prompt

section .bss
    buffer resb 20
    fib_count resq 1

section .text
global _main             ; Required for macOS entry point

_main:

    ; Print prompt
    mov rax, 0x2000004
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Read user input
    mov rax, 0x2000003
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 20
    syscall
    
    ; Exit program using exit syscall
    mov rax, 0x2000001  ; syscall number for exit (x86_64)
    xor rdi, rdi        ; exit code 0
    syscall