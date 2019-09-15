// This file defines I/O operations using legacy CPU
// port operations. Modern CPU's utilize buses and other
// methods to communicate with devices.

// The specification for working with I/O always dictates
// that setting values can be varied: we can set these to
// registers, values, directly to bytes, etc. In our cases
// below, we use the register type a to handle these
// variables. The port used during I/O operations, however,
// must always use register dx or a raw single byte address
// dicated by either d (for the register) or N (for the
// raw address.)

unsigned char port_byte_in(unsigned short port) {
    // Inline assembly code that retrieves the value "result"
    // from register al. The value in al is propgated by setting
    // the value of register dx with a port. This port is an
    // unsigned short, which is 16 bits long. Passing a 32 bit
    // length as input would tell GCC to compile using register
    // edx instead of dx.
    unsigned char result;
    __asm__("in %%dx, %%al" // dx is our port, al is the value from the port
            : "=a" (result) // a is a constraint that grabs the result from
                            // register type a (or ax, eax.)
            : "d" (port));  // d is a contraint that forces the port to be
                            // compatible with register type d (or dx, edx.)
    return result;
}

void port_byte_out(unsigned short port, unsigned char data) {
    // Inline assembly code that places a single byte,
    // data, stored in register al, into memory at the
    // the port specified in register dx.
    __asm__("out %%al, %%dx"           // dx is our port, al is the data
            :                          // This line remains to signify
                                       // there is no output operand.
            : "a" (data), "d" (port)); // Same contraints are used as above
                                       // stating we use register types
                                       // a and d.
}

unsigned short port_word_in(unsigned short port) {
    // Basically the same as the port_byte_in() function
    // but the result comes from the full value of
    // register ax, not al. This gives us back a short
    // which is two bytes of information.
    unsigned short result;
    __asm__("in %%dx, %%ax" // Notice change from al to ax.
            : "=a" (result)
            : "d" (port));
    return result;
}

void port_word_out(unsigned short port, unsigned short data) {
    // Same as port_byte_out() function except we're setting
    // a value in the port that is 16 bits instead of 8 bits.
    __asm__("out %%ax, %%dx" // Notice change from al to ax.
            :
            : "a" (data), "d" (port));
}