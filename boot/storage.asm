; We're utilizing the BIOS interrupt INT 0x13 to read information
; from a disk into memory. This file contains helpers for this
; process. This is mostly used to load our kernel from the disk
; and, in the future, switch execution to it.
disk_load:
    pusha ; reading from disk requires setting specific values in all registers
          ; so we will overwrite our input parameters from 'dx'. Let's save it
          ; to the stack for later use.
    push dx ; specifically pushing this one again because we want
            ; to reference it before popping the rest of the register
            ; values back to their places.

    ; INT 0x13 specific items, see https://en.wikipedia.org/wiki/INT_13H
    ; AH	    Operation to Execute    (ex: 0x2, 3)
    ; AL	    Sectors To Read Count   (ex: 0x1, 0x11, 32)
    ; CH	    Cylinder                (ex: 0x0, 0x3FF, 12)
    ; CL    	Sector                  (ex: 0x1, 42)
    ; DH    	Head                    (ex: 0x0, 6)
    ; DL    	Drive                   (ex: 0x0, 0x80, 1)
    ; ES:BX 	Buffer Address Pointer
    mov ah, 0x2 ; Set ah register to 0x02, the read operation
    mov al, dh  ; Set al register to the quantity of sectors to
                ; read. We previously set this to dh so copy that.
    mov ch, 0x0 ; Set ch register to the cylinder we start reading
                ; from. This is a 10 bit number (0 - 1023). Two of the
                ; bits are the upper two from the cl register:
                ; CX       =    ---CH---  ---CL---
                ; Cylinder :    76543210  98
                ; Sector   :                543210
    mov cl, 0x2 ; Set cl to the sector we want to read from. Sectors
                ; start their counting at one, not zero. The MBR is the
                ; entire first sector of the drive, 512 bytes, so we
                ; want to start on sector two.
    mov dh, 0x0 ; Set dh to the drive head we use to read. This is
                ; essentially the platter side to read from.
    mov dl, dl  ; We set this to what the BIOS set for us earlier. We're
                ; setting it here for completion sake, but it's not
                ; strictly necesary and the compiler just strips this out.

    ; We set the bx register earlier, which, when multiplied against
    ; the extra segment (es) we get our destination in memory.
    int 0x13 ; Call the BIOS interrupt and get some data
    ; INT 0x13 results go into registers, see https://en.wikipedia.org/wiki/INT_13H
    ; CF	Set On Error, Clear If No Error
    ; AH	Return Code
    ; AL	Actual Sectors Read Count
    jc disk_error ; Check the carry flag (cf register) and error if set 

    pop dx
    cmp al, dh ; BIOS sets dh register to the quantity of
               ; sectors actually read. Compare this against
               ; the al register, our original quantity request.
    jne sectors_error ; If the amount read and our request are
                      ; different, we report the error.
    popa ; Rebuild all the registers to how they were.
    ret


disk_error:
    mov bx, DISK_ERROR
    call print
    call print_nl

    mov dh, ah ; The ah register has a hex-based error code
    call print_hex ; Check out error code at http://stanislavs.org/helppc/int_13-1.html
    jmp disk_loop ; Since there's a problem, don't continue

sectors_error:
    mov bx, SECTORS_ERROR
    call print

disk_loop:
    jmp $ ; We hit this loop if there was an error reading or a mismatch on sectors read

DISK_ERROR: db "Disk read error:", 0
SECTORS_ERROR: db "Unable to read all sectors", 0