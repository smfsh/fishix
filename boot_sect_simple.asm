[org 0x7c00] ; tell compiler where this program lives in memory

mov bx, HELLO
call print

call print_nl

mov bx, GOODBYE
call print

jmp $ ; jump to current execution pointer, effectively an infinite loop

; include print functions
%include "boot_sect_print.asm"

HELLO:
    db 'Hello, World', 0
GOODBYE:
    db 'Goodbye', 0

; Fill with 510 zeros minus the size of the previous code
times 510-($-$$) db 0
; Boot sector tag
dw 0xaa55