```bash
i686-elf-gcc -ffreestanding -c kernel/kernel.c -o kernel.o
nasm boot/kernel_entry.asm -f elf -o kernel_entry.o
i686-elf-ld -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary
nasm boot/boot.asm -f bin -o boot.bin
cat boot.bin kernel.bin > os-image.bin
qemu-system-x86_64 -fda os-image.bin
```