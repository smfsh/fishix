; Global Descriptor Table
; Instead of addressing memory directly, once we're
; in 32-bit operating mode, we access it through a
; table, the GDT. This file defines the GDT.
; Our GDT is defines areas of memory for code and
; for data. In our simple setup, they actually
; overlap. In a more complex setup, they would be in
; separate areas, keeping execution points in one from
; accessing information in the other.
gdt_start:
    ; GDT must always start with a an eight byte null descriptor.
    ; This is done to ensure, once we've told the CPU where
    ; the GDT actually is, that it is actually a GDT and not
    ; some random bytes in memory. 
    dd 0x0 ; Four empty bytes
    dd 0x0 ; Another four to make eight.

; GDT for code segment
; Eight total bytes for a full segment descriptor
; Flag              Bit Value
; present           1
; privilege         0, 0
; type              1
; code              1
; conforming        0
; readable          1
; accessed          0
; granularity       1
; 32-bit            1
; 64-bit            0
; AVL               0
gdt_code:
    dw 0xffff    ; Segment Limit  (16 bits, 0-15)
    dw 0x0       ; Segment Base   (16 bits, 16-31)
    db 0x0       ; Segment Base   (8 bits, 32-39)
    db 10011010b ; Flags          (8 bits, 40-47)
    db 11001111b ; Flags          (4 bits, 48-51) 
                 ; Segment Limit  (4 bits, 52-55)
    db 0x0       ; Segment Base   (8 bits, 56 -63)

; GDT for data segment
; Same base and length, different flags
; Flag              Bit Value
; present           1
; privilege         0, 0
; type              1
; code              0
; expand down       0
; writable          1
; accessed          0
; granularity       1
; 32-bit            1
; 64-bit            0
; AVL               0
gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

; The end label is used strictly so the assembler
; can find the start and stop addresses of the
; tables defined above.
gdt_end:

; GDT descriptor used by the actual switch. The
; descriptor details the size (16 bits) and an
; address (32 bits).
gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; Size (16 bits), one less than true size
    dd gdt_start ; Our actual start address

; Define some constants for later use. These addresses
; are what the segment registers will contain in protected
; mode and tells our CPU how do utilize the segment.
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start