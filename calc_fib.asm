section .data
    ten dq 10
    prompt db "Enter number of fibonacci numbers to calculate:", 0
    prompt_len equ $ - prompt

section .bss
    buffer resb 20
    fib_count resq 1
    results resq 100

section .text
global _main

_main:
    ; Print prompt
    mov rax, 0x2000004
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Read input
    mov rax, 0x2000003
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 20
    syscall

    ; Convert input to integer
    mov r8, rax
    mov rsi, buffer
    xor rbx, rbx
    xor rcx, rcx

convert_loop:
    cmp rcx, r8
    jge convert_done
    mov al, byte [rsi + rcx]
    cmp al, 10
    je convert_done
    sub al, '0'
    movzx rax, al
    imul rbx, rbx, 10
    add rbx, rax
    inc rcx
    jmp convert_loop

convert_done:
    mov [rel fib_count], rbx

    ; Initialize results array
    mov rdi, results
    mov qword [rdi], 0       ; results[0] = 0
    mov qword [rdi + 8], 1   ; results[1] = 1

    ; Fibonacci loop
    mov rbx, [rel fib_count] ; Load N
    mov rcx, 2               ; Start at index 2

fibonacci_loop:
    cmp rcx, rbx
    jge end_fibonacci

    mov rdi, results
    mov r8, [rdi + (rcx-2)*8] ; results[i-2]
    mov r9, [rdi + (rcx-1)*8] ; results[i-1]
    add r8, r9
    mov [rdi + rcx*8], r8     ; results[i]

    inc rcx
    jmp fibonacci_loop

end_fibonacci:
    ; Print last Fibonacci number
    mov rdi, results
    mov rsi, [rdi + (rbx - 1) * 8]
    call print_number

    ; Exit
    mov rax, 0x2000001
    xor rdi, rdi
    syscall

print_number:
    lea rdi, [rel buffer + 19]
    mov byte [rdi], 0x0A
    mov rbx, rsi
    mov rcx, 1

unconvert_loop:
    mov rax, rbx
    xor rdx, rdx
    div qword [rel ten]
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc rcx
    mov rbx, rax
    test rbx, rbx
    jnz unconvert_loop

    ; Print
    mov rsi, rdi
    mov rax, 0x2000004
    mov rdi, 1
    mov rdx, rcx
    syscall
    ret