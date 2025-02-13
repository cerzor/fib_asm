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

    mov r8, rax             ; Store number of bytes read (in r8)
    mov rsi, buffer
    xor rbx, rbx            ; Initialize rbx to 0 (accumulator for the result)
    xor rcx, rcx            ; Clear rcx, starting index   

convert_loop:
    cmp rcx, r8             ; Check if we've read all bytes
    jge convert_done        ; If we've read all bytes, stop
    mov al, byte [rsi + rcx]
    cmp al, 10              ; Check if it’s the newline character (0xA)
    je convert_done         ; If newline, stop
    sub al, '0'
    imul rbx, rbx, 10
    add rbx, rax            ; Add the current digit to the accumulated result
    inc rcx                 ; Move to the next character in the buffer
    jmp convert_loop        ; Repeat the loop

convert_done:
    mov rdi, fib_count      ; Move the address of fib_count into rdi
    mov [rdi], rbx          ; Store the result in fib_count

    mov rax, 0x2000004
    mov rdi, 1
    mov rsi, rbx
    mov rdx, prompt_len
    syscall   

  ; Exit program
    mov rax, 0x2000001         ; sys_exit
    xor rdi, rdi
    syscall
