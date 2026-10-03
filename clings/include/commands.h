#ifndef COMMANDS_H
#define COMMANDS_H

#include <stdbool.h>

/// Walks up from the working directory until it finds exercises/ and makes that the cwd.
int chdir_to_root(void);

int cmd_verify(void);
int cmd_run(const char *name);
int cmd_hint(const char *name);
int cmd_list(void);
int cmd_reset(const char *name);
int cmd_doctor(void);
/// Counts exercises whose marker is gone, for the watch loop's progress bar.
int count_done(int *total);
/// Remembers that path passed (or forgets it), keyed by its mtime and size.
void progress_record(const char *path, bool passed);

#endif
