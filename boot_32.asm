org 0x7c00 ; bootloader offset
KERNEL_OFFSET equ 0x1000 ; Kernel location in memory

mov [BOOT_DRIVE], dl ; bios gives us the boot drive in dl register at boot

mov bp, 0x9000 ; set stack location
mov sp, bp ; set stack stack pointer to stack base pointer

mov bx, MSG_REAL_MODE
call print ; This will be written after the BIOS messages
call print_nl ; Print a new line

call load_kernel ; Get the kernel from the disk, see below

call switch_to_pm ;

jmp $ ; this will actually never be executed

%include "storage.asm"
%include "print_16.asm"
%include "gdt_32.asm"
%include "print_32.asm"
%include "switch_32.asm"

bits 16
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print

    mov bx, KERNEL_OFFSET ; 
    mov dh, 2
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret

[bits 32]
BEGIN_PM: ; Executed after the switch functions in switch_32.asm
    mov ebx, MSG_PROT_MODE
    call print_string_pm ; Print out to the upper left corner
    call KERNEL_OFFSET ; Execute kernel from memory location defined earlier
    jmp $ ; Chill till we die

BOOT_DRIVE db 0

MSG_REAL_MODE db "Started in 16-bit real mode", 0
MSG_LOAD_KERNEL db "Loading Kernel from disk", 0
MSG_PROT_MODE db "Loaded 32-bit protected mode", 0

; bootsector
times 510-($-$$) db 0
dw 0xaa55