// Main function executed by the bootloader
void main() {
    // Access first video memory byte directly at 0xb8000
    char* video_memory = (char*) 0xb8000;
    // Set the video memory byte to X
    *video_memory = 'X';
}