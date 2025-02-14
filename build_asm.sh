nasm -f macho64 calc_fib.asm  -o calc_fib.o
clang -target x86_64-apple-macos -o calc_fib calc_fib.o -Wl,-macos_version_min,10.13 -Wl,-no_pie 
