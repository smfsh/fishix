#define VIDEO_ADDRESS 0xb8000

void clear_screen();
void write_string(int color, const char *string);

// Main function executed by the bootloader
void main() {
    // Remove bios and bootloader text from screen
    clear_screen();

    // Write out welcome string
    write_string(5, "Kernel initiated... Welcome to fishix.");
}

// Replace all characters on an 80 * 25 size screen
void clear_screen() {
    int size = 80 * 25;
    int i;
    volatile char *screen = (volatile char *) VIDEO_ADDRESS;

    // Loop through each position and clear it out
    for (i = 0; i < size; i++) {
        screen[i*2] = ' '; // Empty character
        screen[i*2+1] = 0x00; // Black background
    }
}

// Write out a string to the top left corner of the screen
void write_string( int colour, const char *string ) {
    volatile char *screen = (volatile char *) VIDEO_ADDRESS;
    // Print and increment position for each string character
    while(*string != 0)
    {
        *screen++ = *string++;
        *screen++ = colour;
    }
}