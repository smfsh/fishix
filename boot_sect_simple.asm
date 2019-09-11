mov ah, 0x0e ; teletype mode
mov al, 'H' ; send ASCII Hex "H" into al register
int 0x10 ; call screen print interrupt

mov al, 'E' ; send ASCII Hex "H" into al register
int 0x10 ; call screen print interrupt

mov al, 'L' ; send ASCII Hex "H" into al register
int 0x10 ; call screen print interrupt

mov al, 'L' ; send ASCII Hex "H" into al register
int 0x10 ; call screen print interrupt

mov al, 'O' ; send ASCII Hex "H" into al register
int 0x10 ; call screen print interrupt

jmp $ ; jump to current execution pointer, effectively an infinite loop

; Fill with 510 zeros minus the size of the previous code
times 510-($-$$) db 0
; Boot sector tag
dw 0xaa55