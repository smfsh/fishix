#define VIDEO_ADDRESS 0xb8000 // Base VGA memory address
#define MAX_ROWS 25
#define MAX_COLS 80

#define REG_SCREEN_CTRL 0x3d4 // Port to ask for data
#define REG_SCREEN_DATA 0x3d5 // Port to recieve answer

#define DEFAULT_COLOR 0x5 // Purple on black

void print(char *message);
void print_at(char *message, int col, int row);
void clear_screen();