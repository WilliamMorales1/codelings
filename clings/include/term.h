#ifndef TERM_H
#define TERM_H

#include <stdbool.h>

extern bool no_color;

void term_init(void);
/// Returns the ANSI sequence, or "" when NO_COLOR is set or stdout is not a terminal.
const char *ansi(const char *seq);
/// Prints path as an OSC 8 hyperlink to its absolute location (plain text when colour is off).
void print_file_link(const char *path);
void print_progress(int done, int total);

#define C_RESET ansi("\033[0m")
#define C_RED ansi("\033[1;31m")
#define C_GREEN ansi("\033[1;32m")
#define C_YELLOW ansi("\033[1;33m")
#define C_BLUE ansi("\033[1;34m")
#define C_CYAN ansi("\033[1;36m")
#define C_DIM ansi("\033[2m")

#endif
