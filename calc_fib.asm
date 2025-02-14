%define PROT_READ_WRITE 0x3
%define MAP_PRIVATE 0x2
%define MAP_ANON 0x1000

section .data
    prompt db "Enter number of fibonacci numbers to calculate: ", 0
    prompt_len equ $ - prompt
    ten db 10

section .bss
    buffer resb 20
    fib_count resq 1
    results resq 1       ; for storing results to look at to compute

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

   ; mmap block
   ; allocate enough memory
    lea rdi, [rel fib_count]   ; Load address of fib_count
    mov rbx, [rdi]         ; Load the actual value into rbx
  
    add rbx, 1
    shl rbx, 3

   ; setting mmap params
    mov rax, 0x20000C5    				; mmap number
    mov rdi, 0            				; operating system will choose mapping destination
    mov rsi, rbx		  				; page size
    mov rdx, PROT_READ_WRITE    		; new memory region will be marked read only
    mov r10, MAP_PRIVATE | MAP_ANON		; pages will not be shared
    mov r8, -1            				; rax holds opened file descriptor
    mov r9, 0             				; anonymous mapping
    syscall               				; now rax will point to mapped location
  ; end mmap block

  ; Check if mmap failed (rax is negative)
    cmp rax, -1
    je exit_with_error

  ; After mmap syscall
    lea rdi, [rel results]   ; Get address of results
    mov [rdi], rax       ; Store mmap result into results

  ; Accessing results array
    mov rdi, [rel results]       ; Load mmap pointer (heap memory) into rdi
    mov qword [rdi], 0   ; Set results[0] = 0
    mov qword [rdi + 8], 1 ; Set results[1] = 1
  
  ; Exit program
    mov rax, 0x2000001         ; sys_exit
    xor rdi, rdi
    syscall

; process loop
    mov rdi, fib_count        ; Load address of fib_count into rdi
    mov rbx, [rdi]            ; Load the value of fib_count (N) into rbx
    lea rdi, [rel results]    ; Load address of results into rdi
  	xor rcx, rcx              ; rcx = 0, this is the Fibonacci index
  	add rcx, 2			  ; set rcx = 2, because we manually loaded the first two elements
    mov r8, 0                 ; r8 = previous Fibonacci number (results[i-2])
    mov r9, 1                 ; r9 = current Fibonacci number (results[i-1])

loop_calc:
 	 cmp rcx, rbx              ; Compare current index (rcx) with fib_count (rbx)
    jge end_loop              ; If rcx >= fib_count, exit the loop

    mov r10, r8               ; r10 = results[i-2] (previous Fibonacci)
    add r10, r9               ; r10 = results[i-2] + results[i-1] (next Fibonacci)

    mov rdi, results          ; Load the base address of the results array
    shl rcx, 3                ; Multiply index by 8 (since each result is a qword)
    mov [rdi + rcx], r10      ; Store the new Fibonacci number
    mov r8, r9                ; r8 = results[i-1]
    mov r9, r10               ; r9 = results[i]
    inc rcx
    jmp loop_calc

end_loop:

    mov rdi, fib_count
    mov rbx, [rdi]
    dec rbx
    shl rbx, 3
    mov rdi, results
    mov r8, [rdi + rbx]

    call print_last_number
    
    ; Exit program (or handle the end of Fibonacci calculation)
    mov rax, 0x2000001         ; sys_exit
    xor rdi, rdi
    syscall

print_last_number:
    ; Get last Fibonacci number
    mov rdi, [rel fib_count]
    dec rdi                 ; Convert count to index
    shl rdi, 3              ; Multiply by 8 (size of qword)
    mov r8, [rel results]
    mov r8, [r8 + rdi]      ; Load last Fibonacci number

    call print_number
    ; Exit program
    mov rax, 0x2000001
    xor rdi, rdi
    syscall

print_number:
    lea rdi, [rel buffer + 19] ; Start at end of buffer
    mov byte [rdi], 0x0A    ; Store newline at end
    dec rdi                 ; Move to position before newline
    mov rbx, r8             ; Copy number to convert
    mov rcx, 1              ; Character counter (including newline)

unconvert_loop:
    mov rax, rbx
    xor rdx, rdx            ; Clear upper 64 bits of dividend
    div qword [rel ten]     ; Divide RDX:RAX by 10
    add dl, '0'             ; Convert remainder to ASCII
    dec rdi                 ; Move buffer pointer backward
    mov [rdi], dl           ; Store ASCII character
    inc rcx                 ; Increment character count
    mov rbx, rax            ; Update quotient
    test rax, rax           ; Check if quotient is zero
    jnz unconvert_loop

    ; Write system call
    mov rax, 0x2000004      ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, rdi            ; buffer position
    mov rdx, rcx            ; number of characters
    syscall
    ret

exit_with_error:
    ; Handle error (e.g., exit with code 1)
    mov rax, 0x2000001
    mov rdi, 1
    syscall
