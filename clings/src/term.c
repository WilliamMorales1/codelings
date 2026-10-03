#include "term.h"

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

bool no_color = false;

void term_init(void) {
    const char *nc = getenv("NO_COLOR");
    no_color = (nc != NULL && nc[0] != '\0') || !isatty(STDOUT_FILENO);
}

const char *ansi(const char *seq) { return no_color ? "" : seq; }

void print_file_link(const char *path) {
    char abs[PATH_MAX];
    if (no_color || realpath(path, abs) == NULL) {
        printf("%s", path);
        return;
    }
    printf("\033]8;;file://%s\033\\%s\033]8;;\033\\", abs, path);
}

void print_progress(int done, int total) {
    const int width = 32;
    int filled = total > 0 ? width * done / total : 0;
    printf("Progress: [%s", C_GREEN);
    for (int i = 0; i < width; i++)
        putchar(i < filled ? '#' : '-');
    printf("%s] %d/%d\n", C_RESET, done, total);
}
