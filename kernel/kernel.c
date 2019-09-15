#include "../drivers/screen.h"

// Main function executed by the bootloader
void main() {
    // Remove bios and bootloader text from screen
    clear_screen();

    // Write out welcome string
    print("Kernel initiated... Welcome to fishix.");
}
