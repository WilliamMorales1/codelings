#define _POSIX_C_SOURCE 199309L
#include <time.h>

// nanosleep instead of spinning on clock(): the watch loop used to pin a CPU core.
void delay(int seconds) {
    struct timespec ts = {.tv_sec = seconds, .tv_nsec = 0};
    nanosleep(&ts, NULL);
}
