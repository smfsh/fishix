bits 16
switch_to_pm:
    cli ; Disable all the interrupts set earlier
        ; by the BIOS. These will conflict in our
        ; 32-bit operating mode.
    lgdt [gdt_descriptor] ; Tell the CPU about the GDT

    mov eax, cr0 ; Grab the current value of cr0, a control register
    or eax, 0x1  ; Update the first bit to 1
    mov cr0, eax ; Set the control register to the updated value

    ; We're quasi in 32-bit operation mode at this point
    ; but it's possible the CPU still has instructions somewhere
    ; in it that are 16-bit. We want these to finish before moving
    ; on so we execute what's called a far jump. This is done by
    ; declaring a (far) segment and offset.
    jmp CODE_SEG:init_pm ; Perform the actual far jump
    ; During the jump, the code segment, cs, is updated
    ; appropriately, and automatically. We apply the offset
    ; that we set at CODE_SEG and arrive where we need to be.

bits 32
init_pm: ; We're now officially in 32-bit mode
    mov ax, DATA_SEG ; Now that we're here, we should update
    mov ds, ax       ; all additional segments to make sure
    mov ss, ax       ; they're aware of where the GDT has them
    mov es, ax       ; mapped for this mode.
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000 ; We update our stack positions as well
    mov esp, ebp     ; now that we have all this free space.

    call begin_pm ; Begin to execute code in 32-bit space, back at boot.asm