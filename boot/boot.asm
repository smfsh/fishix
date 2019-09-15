org 0x7c00 ; Magic bootloader offset (or MBR location).
           ; This address, in decimal, is 31744 and
           ; 32768 (32KB) - 31744 = 1024 (1KB).
           ; This gives 512 bytes for this loader itself
           ; and 512 bytes for the stack of the loader.
           ; This comes from system architecture based on
           ; a maximum amount of memory of 32KB.

KERNEL_OFFSET equ 0x1000 ; Preparing the kernel location in memory.
                         ; We put this super early in memory, 0x1000
                         ; or 4096. This gives us a lot of overhead
                         ; to run our code before we hit the last 1KB
                         ; and overwrite the MBR memory location.

mov [BOOT_DRIVE], dl ; Bios sets dl register at boot based on the drive
                     ; where it found the magic number 0xAA55 in the first
                     ; cylinder-head-sector (CHS address 0 0 1) of said drive.
                     ; We set this to a non-register space now in case we
                     ; overwrite dl before we get to loading from it.

mov bp, 0x8000 ; Set location of our MBR stack base (bp) in memory
               ; We put this right at 32768. Because the stack grows
               ; downward, this gives us 512 bytes of stack memory
               ; before we hit the 512 bytes used by the MBR.
mov sp, bp ; Set stack stack pointer (sp) to stack base pointer (bp)

mov bx, MSG_REAL_MODE
call print ; This will be written after the BIOS messages
call print_nl ; Print a new line

call load_kernel ; Get the kernel from the disk, see below

call switch_to_pm ; Start setting up and switch to protected mode.
                  ; Specifically we're switching to 32-bit operating
                  ; mode and this requires setting up 32-bit memory
                  ; space known as GDT. Most of that setup is handled
                  ; in the gdt.asm file. We're also disabling 16-bit
                  ; BIOS interrupts so we need new ways to read from
                  ; the disk and write to the screen.

jmp $ ; Catch in case we fail to move into protected mode, the
      ; theorhetical max execution point of our bootloader.

; Includes, when assembled, are referenced files placed inline
%include "boot/storage.asm"
%include "boot/print.asm"
%include "boot/gdt.asm"
%include "boot/pm.asm"

bits 16 ; Although we start in 16-bit mode, the includes
        ; are setting bits to 32 elsewhere. The assembler
        ; can't figure it out on its own.
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print

    mov bx, KERNEL_OFFSET ; The bx register is used by INT 0x13 (13h)
                          ; to determine where data will be stored
                          ; in memory once it has been read.
                          ; The offset value is multiplied against
                          ; the extra segment (es). We have not
                          ; actually set this so it is 0x0. What we
                          ; see in practice is 0x0:0x9000 = 0x9000.
                          ; If we wanted to place our kernel way out
                          ; in memory, we do that by setting es early
                          ; such as 0xA000. Our calculation now looks
                          ; like 0xA000:0x9000 = 0xA9000, a very
                          ; different (and distant) space.
    mov dh, 32 ; Quantity of sectors to load, this should
               ; contain your entire kernel. Because this
               ; is all memory, loading something smaller
               ; and replacing in kernel-space might be
               ; a bit faster. To be determined.
    mov dl, [BOOT_DRIVE] ; Grab the value we saved earlier as, in our
                         ; case the MBR drive is the same drive that
                         ; contains our kernel code. This value is
                         ; predictable in that floppy is 0x00, second
                         ; floppy is 0x01, disk = 0x80, second disk is
                         ; 0x81, CD/DVD is 0xE0.
    call disk_load ; Move execution to storage.asm
    ret

bits 32
begin_pm: ; Executed after the switch functions in switch.asm
    mov ebx, MSG_PROT_MODE
    call print_string_pm ; Print out to the upper left corner because
                         ; now we're writing directly to the video 
                         ; memory starting at the first pixel 0xB8000.
    call KERNEL_OFFSET ; Move our execution pointer to where we loaded
                       ; the kernel data earlier in load_kernel.
    jmp $ ; Chill til the kernel returns to us, although hopefully it won't


; Memory reservations
BOOT_DRIVE db 0

; String reservations in memory
MSG_REAL_MODE db "Started in 16-bit real mode", 0
MSG_LOAD_KERNEL db "Loading Kernel from disk", 0
MSG_PROT_MODE db "Loaded 32-bit protected mode", 0

; Write remaining bootsector padding and magic boot code
times 510-($-$$) db 0
dw 0xaa55 ; 16-bit word letting the bios know we're the chosen one