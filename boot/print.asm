; Code for executing print functions using
; BIOS interrupts while in 16-bit mode
bits 16
print:
    pusha ; Save all the registers before we start

; the comparison for string end (null byte)
start:
    mov al, [bx] ; We set bx before we get here and
                 ; we set al to the value itself.
    cmp al, 0 ; Compare to see whether we've hit our
              ; end-of-string character, 0.
    je done ; If we have, skip to done

    mov ah, 0x0e ; Set ah to 0x0e, the instruction for
                 ; interrupt 0x10 to print the char
                 ; set in register al.
    int 0x10 ; Interrupt and write value of al to the screen

    add bx, 1 ; Increment bx to the next address
    jmp start ; Run the loop again

done:
    popa ; Return all the values to the registers
    ret

print_nl:
    pusha ; Save all the registers before we start

    mov ah, 0x0e ; Set print mode for interrupt
    mov al, 0x0a ; Raw line feed (new line) character
    int 0x10 ; Interrupt and print value of al
    mov al, 0x0d ; Carriage return character
    int 0x10 ; Interrupt and print value of al

    popa ; Return all the values to the registers
    ret

print_hex:
    pusha ; Save all the registers before we start

    mov cx, 0 ; Use a register to store our loop index

; Strategy: get the last char of 'dx', then convert to ASCII
; Numeric ASCII values: '0' (ASCII 0x30) to '9' (0x39), so just add 0x30 to byte N.
; For alphabetic characters A-F: 'A' (ASCII 0x41) to 'F' (0x46) we'll add 0x40
; Then, move the ASCII byte to the correct position on the resulting string
hex_loop:
    cmp cx, 4 ; Check if we're at the end of our loop, max of 4
    je end_hex ; If we are, prepare to print
    
    mov ax, dx ; We will use 'ax' as our working register
    and ax, 0x000f ; We use a bitmask to mask the first three
                   ; digits to zeros.
    add al, 0x30 ; Add 0x30 to N to convert it to ASCII "N"
    cmp al, 0x39 ; Check to see if the value is more than
                 ; 0x39 which would signify we're A-F and not
                 ; hex 0-9.
    jle step2 ; If we're not A-F, continue to step2
    add al, 7 ; We're a letter so add the needed bits. ASCII
              ; letters are 17 characters after decimal numbers.

step2:
    ; Get the correct position of the string to place our ASCII char
    ; bx <- base address + string length - index of char
    mov bx, HEX_OUT + 5 ; Base address + length
    sub bx, cx  ; Subtract our index
    mov [bx], al ; Copy the char on al to the location at bx
    ror dx, 4 ; 0x1234 -> 0x4123 -> 0x3412 -> 0x2341 -> 0x1234

    ; increment index and loop
    add cx, 1 ; Increment the index
    jmp hex_loop ; Start again till we get the whole value

end_hex:
    ; prepare the parameter and call the function
    ; remember that print receives parameters in 'bx'
    mov bx, HEX_OUT
    call print

    popa
    ret

HEX_OUT:
    db '0x0000',0 ; reserve memory for our new string



; Code for executing print functions using
; direct memory manipulation in 32-bit mode
bits 32
; Set some values to utilize later
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f ; Color value byte, 16 choices

print_string_pm:
    pusha
    mov edx, VIDEO_MEMORY ; Set register edx to the video memory
                          ; location defined above, 0xb8000. This
                          ; value is the upper-left most character
                          ; in a text-mode VGA display.

print_string_pm_loop:
    mov al, [ebx] ; We set the register ebx earlier, take the value
                  ; from the address and put it in register al.
    mov ah, WHITE_ON_BLACK ; Set ah to our byte defining style

    cmp al, 0 ; Check if we've hit our end of line character
    je print_string_pm_done ; If we have, we're done with this string

    mov [edx], ax ; Put entire ax register (2 bytes) into the address at edx
    add ebx, 1 ; Increment the ebx pointer so we find the next char in our string
    add edx, 2 ; Increment the edx pointer so we move to the next cursor position

    jmp print_string_pm_loop ; Loop till we're done

print_string_pm_done:
    popa
    ret