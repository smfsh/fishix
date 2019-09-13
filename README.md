### Automatic Build

`make` -- build the final image to write to a storage medium

`make run` -- run final image in the qemu emulator

### Manual Build Commands

```bash
i686-elf-gcc -ffreestanding -c kernel/kernel.c -o kernel.o
nasm boot/kernel_entry.asm -f elf -o kernel_entry.o
i686-elf-ld -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary
nasm boot/boot.asm -f bin -o boot.bin
cat boot.bin kernel.bin > os-image.bin
qemu-system-i386 -fda os-image.bin
```

### Arch Linux Dependencies for Compilation

* i686-elf-binutils
* i686-elf-gcc
* gdb-multiarch
* qemu-arch-extra
* nasm
