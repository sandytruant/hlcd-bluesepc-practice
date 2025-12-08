// Compute floor(sqrt(x))
unsigned int sqrt_digit(unsigned int x) {
    unsigned int r = x;    // remainder
    unsigned int y = 0;    // partial result

    for (int n = 15; n >= 0; n--) {
        // Δ_n = (2*y)*2^n + 2^(2n)
        unsigned int delta = ((y << 1) << n) + (1u << (n+n));
        if (r >= delta) {
            r -= delta;
            y += (1u << n);
        }
    }
    return y;
}
