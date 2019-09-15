#include "screen.h"
#include "../kernel/ports.h"

int print_char(char character, int col, int row, char attribute);
int get_screen_offset(int col, int row);
int get_cursor_offset();
void set_cursor_offset(int offset);
int get_offset_row(int offset);
int get_offset_col(int offset);


/* Public Functions */

void print(char *message) {
    print_at(message, -1, -1);
}

void print_at(char *message, int col, int row) {
    int offset;
    if (col >= 0 && row >= 0) {
        offset = get_screen_offset(col, row);
    } else {
        offset = get_cursor_offset();
        row = get_offset_row(offset);
        col = get_offset_col(offset);
    }

    int i = 0;
    while (message[i] != 0) {
        int next_character;
        next_character = print_char(message[i++], col, row, DEFAULT_COLOR);
        row = get_offset_row(next_character);
        col = get_offset_col(next_character);
    }
}

// Replace all characters with a blank character
void clear_screen() {
    int size = MAX_COLS * MAX_ROWS;
    int i;
    volatile char *address = (volatile char *) VIDEO_ADDRESS;

    // Loop through each position and clear it out
    for (i = 0; i < size; i++) {
        address[i*2] = ' '; // Empty character
        address[i*2+1] = 0x00; // Black background
    }

    set_cursor_offset(get_screen_offset(0, 0));
}

/* Private Functions */

// Write out a string to the top left corner of the screen
void write_simple_string(const char *string, int attribute) {
    volatile char *screen = (volatile char *) VIDEO_ADDRESS;
    // Print and increment position for each string character
    while(*string != 0)
    {
        *screen++ = *string++;
        *screen++ = attribute; // Values 1-16 for colors
    }
}

int print_char(char character, int col, int row, char attribute) {
    volatile unsigned char *address = (volatile unsigned char *) VIDEO_ADDRESS;

    // Check if an attribute was set and if not use our default
    if (!attribute) {
        attribute = DEFAULT_COLOR;
    }

    int offset; // Initialize offset variable

    // Check if we want to explicitly place the character
    // at a defined point on the screen (col and row) or
    // use the current cursor position.
    if (col >= 0 && row >= 0) {
        offset = get_screen_offset(col, row);
    } else {
        offset = get_cursor_offset();
    }

    // Check if we want to go to a new line
    if (character == '\n') {
        // Figure out which row we're currently on by dividing
        // the current offset by two (because the offset is the
        // VGA memory location and two bytes per character) and
        // and the maximum amount of columns.
        int rows = offset / (2 * MAX_COLS);
        // Set the offset to the colum 0 and the subsequent row
        offset = get_screen_offset(0, rows + 1);
    } else {
        // Not a new line; use the offset as an decimal index
        // from the original memory value of col 0, row 0.
        address[offset] = character;
        // Go one more position to set the attribute byte.
        address[offset + 1] = attribute;
    }

    // Add two to the offset and set the cursor so the next
    // printed character will be there.
    offset += 2;

    set_cursor_offset(offset);
    return offset;

    // offset = check_scroll(offset);
}

int get_screen_offset(int col, int row) {
    // Each printed character on the screen is
    // two bytes. We calculate by multiplying the
    // current row by the max amount of columns
    // then add the current colum to figure out
    // exact position. Multiply by two (because
    // there are two bytes per character here) and
    // you have your (decimal value) position.
    return (row * MAX_COLS + col) * 2;
}

int get_cursor_offset() {
    int offset;
    
    // Ask for cursor offset high byte from VGA port
    port_byte_out(REG_SCREEN_CTRL, 14);
    offset = port_byte_in(REG_SCREEN_DATA) << 8;

    // Ask for cursor offset low byte from VGA port
    port_byte_out(REG_SCREEN_CTRL, 15);
    offset += port_byte_in(REG_SCREEN_DATA);

    return offset * 2; // Position times size becase
                       // the VGA controller gives us a 
                       // character number here and we
                       // need to know where this would be
                       // in memory.
}

void set_cursor_offset(int offset) {
    offset = offset / 2; // Divide by two because two bytes per
                         // and the VGA controller expects the
                         // character number here, not the memory
                         // value of the character.

    // Instruct VGA port that we're going to write the high byte
    port_byte_out(REG_SCREEN_CTRL, 14);
    port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8));

    // Instruct VGA port that we're going to write the low byte
    port_byte_out(REG_SCREEN_CTRL, 15);
    port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset & 0xff));
}

// From an offset, calculate which row it belongs to
int get_offset_row(int offset) {
    return offset / (2 * MAX_COLS);
}

// From an offset, calculate which column it belongs to
int get_offset_col(int offset) {
    return (offset - (get_offset_row(offset) * 2 * MAX_COLS)) / 2;
}