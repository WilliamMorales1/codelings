#include "commands.h"
#include "term.h"

#include <dirent.h>
#include <errno.h>
#include <limits.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

#define MARKER "I AM NOT DONE"
#define MAX_EXERCISES 512
#define MAX_OUTPUT (64 * 1024)

typedef struct {
    char chapter[NAME_MAX + 1];
    char name[NAME_MAX + 1];
    char path[PATH_MAX];
} Ex;

static Ex exercises[MAX_EXERCISES];
static int exercise_ct = 0;

int chdir_to_root(void) {
    char cwd[PATH_MAX];
    if (getcwd(cwd, sizeof cwd) == NULL)
        return -1;
    for (;;) {
        struct stat st;
        if (stat("exercises", &st) == 0 && S_ISDIR(st.st_mode))
            return 0;
        if (strcmp(cwd, "/") == 0 || chdir("..") != 0 || getcwd(cwd, sizeof cwd) == NULL)
            break;
    }
    fprintf(stderr, "could not find an exercises/ directory; run clings from inside the repository\n");
    return -1;
}

static int is_dir(const struct dirent *d) {
    return d->d_type == DT_DIR && d->d_name[0] != '.';
}

static int is_c_file(const struct dirent *d) {
    size_t n = strlen(d->d_name);
    return d->d_type == DT_REG && n > 2 && strcmp(d->d_name + n - 2, ".c") == 0;
}

static int by_name(const struct dirent **a, const struct dirent **b) {
    return strcasecmp((*a)->d_name, (*b)->d_name);
}

static void discover(void) {
    struct dirent **chapters;
    int n = scandir("exercises", &chapters, is_dir, by_name);
    exercise_ct = 0;
    for (int i = 0; i < n; i++) {
        char dir[NAME_MAX + 16];
        snprintf(dir, sizeof dir, "exercises/%s", chapters[i]->d_name);
        struct dirent **files;
        int m = scandir(dir, &files, is_c_file, by_name);
        for (int j = 0; j < m; j++) {
            if (exercise_ct < MAX_EXERCISES) {
                Ex *e = &exercises[exercise_ct++];
                snprintf(e->chapter, sizeof e->chapter, "%s", chapters[i]->d_name);
                snprintf(e->path, sizeof e->path, "%s/%s", dir, files[j]->d_name);
                snprintf(e->name, sizeof e->name, "%.*s",
                         (int)(strlen(files[j]->d_name) - 2), files[j]->d_name);
            }
            free(files[j]);
        }
        if (m >= 0)
            free(files);
        free(chapters[i]);
    }
    if (n >= 0)
        free(chapters);
}

static char *slurp(const char *path) {
    FILE *f = fopen(path, "r");
    if (f == NULL)
        return NULL;
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    rewind(f);
    char *buf = malloc(size + 1);
    size_t got = fread(buf, 1, size, f);
    buf[got] = '\0';
    fclose(f);
    return buf;
}

static bool pending(const Ex *e) {
    char *s = slurp(e->path);
    bool p = s != NULL && strstr(s, MARKER) != NULL;
    free(s);
    return p;
}

#define PROGRESS_FILE ".clings-progress"

/// stamp writes a cheap change token (mtime and size) for path into buf.
static void stamp(const char *path, char *buf, size_t cap) {
    struct stat st;
    if (stat(path, &st) != 0)
        snprintf(buf, cap, "gone");
    else
        snprintf(buf, cap, "%lld.%ld:%lld", (long long)st.st_mtim.tv_sec, st.st_mtim.tv_nsec, (long long)st.st_size);
}

static const char *norm(const char *path) {
    return strncmp(path, "./", 2) == 0 ? path + 2 : path;
}

/// progress_done reports whether path passed and has not changed since.
static bool progress_done(const char *path) {
    char want[128], line[PATH_MAX + 160], st[128];
    stamp(path, st, sizeof st);
    snprintf(want, sizeof want, "%s", st);
    FILE *f = fopen(PROGRESS_FILE, "r");
    if (f == NULL)
        return false;
    bool done = false;
    size_t n = strlen(norm(path));
    while (fgets(line, sizeof line, f)) {
        line[strcspn(line, "\n")] = '\0';
        if (strncmp(line, norm(path), n) == 0 && line[n] == ' ' && strcmp(line + n + 1, want) == 0)
            done = true;
    }
    fclose(f);
    return done;
}

void progress_record(const char *path, bool passed) {
    const char *p = norm(path);
    size_t n = strlen(p);
    char *old = slurp(PROGRESS_FILE);
    FILE *f = fopen(PROGRESS_FILE, "w");
    if (f == NULL) {
        free(old);
        return;
    }
    for (char *line = old ? strtok(old, "\n") : NULL; line; line = strtok(NULL, "\n"))
        if (!(strncmp(line, p, n) == 0 && line[n] == ' '))
            fprintf(f, "%s\n", line);
    if (passed) {
        char st[128];
        stamp(path, st, sizeof st);
        fprintf(f, "%s %s\n", p, st);
    }
    fclose(f);
    free(old);
}

/// done means the exercise passed since its last edit and, if it still carries a marker, that is gone too.
static bool done(const Ex *e) {
    return progress_done(e->path) && !pending(e);
}

/// Runs a shell command, capturing stdout+stderr into out; returns the exit status.
static int capture(const char *cmd, char *out, size_t cap) {
    char full[PATH_MAX * 3];
    snprintf(full, sizeof full, "%s 2>&1", cmd);
    FILE *p = popen(full, "r");
    if (p == NULL) {
        snprintf(out, cap, "could not run: %s", cmd);
        return -1;
    }
    size_t len = fread(out, 1, cap - 1, p);
    out[len] = '\0';
    int status = pclose(p);
    return WIFEXITED(status) ? WEXITSTATUS(status) : -1;
}

/// Compiles and runs one exercise, the same way the watch loop does.
static bool check(const Ex *e, char *out, size_t cap) {
    mkdir("bin", 0700);
    char cmd[PATH_MAX * 2];
    snprintf(cmd, sizeof cmd, "gcc '%s' -o 'bin/%s' -lm", e->path, e->name);
    if (capture(cmd, out, cap) != 0)
        return false;
    snprintf(cmd, sizeof cmd, "./bin/%s", e->name);
    bool ok = capture(cmd, out, cap) == 0;
    progress_record(e->path, ok);
    return ok;
}

static void indent(const char *s) {
    const char *line = s;
    while (*line) {
        const char *nl = strchr(line, '\n');
        int len = nl ? (int)(nl - line) : (int)strlen(line);
        printf("    %.*s\n", len, line);
        if (!nl)
            break;
        line = nl + 1;
    }
}

static void print_file(const Ex *e) {
    printf("  File: ");
    print_file_link(e->path);
    putchar('\n');
}

static char out[MAX_OUTPUT];

/// Prints the outcome of a check whose output is in out; returns true when the learner may move on.
static bool report(const Ex *e, bool compiled_and_ran) {
    if (!compiled_and_ran) {
        printf("%sx %s/%s fails.%s\n", C_RED, e->chapter, e->name, C_RESET);
        print_file(e);
        indent(out);
        printf("\n  Stuck? `clings hint %s`\n", e->name);
        return false;
    }
    if (pending(e)) {
        printf("%s! %s/%s compiles, but is not done yet.%s\n", C_YELLOW, e->chapter, e->name, C_RESET);
        print_file(e);
        indent(out);
        printf("\n  This one can't be checked by running it: once you're happy with it,\n"
               "  delete the `// ❌ " MARKER "` line to move on.\n");
        return false;
    }
    printf("%sv %s/%s passes!%s\n", C_GREEN, e->chapter, e->name, C_RESET);
    indent(out);
    return true;
}

static const Ex *find(const char *needle) {
    if (needle == NULL) {
        for (int i = 0; i < exercise_ct; i++)
            if (!done(&exercises[i]))
                return &exercises[i];
        return NULL;
    }
    for (int i = 0; i < exercise_ct; i++) {
        const Ex *e = &exercises[i];
        if (strcmp(e->name, needle) == 0 || strcmp(e->path, needle) == 0)
            return e;
    }
    fprintf(stderr, "%sno exercise named `%s` (try `clings list`)%s\n", C_RED, needle, C_RESET);
    return NULL;
}

int cmd_verify(void) {
    discover();
    for (int i = 0; i < exercise_ct; i++) {
        if (done(&exercises[i]))
            continue;
        bool ok = check(&exercises[i], out, sizeof out);
        if (!ok || pending(&exercises[i])) {
            print_progress(i, exercise_ct);
            putchar('\n');
            report(&exercises[i], ok);
            return 1;
        }
    }
    print_progress(exercise_ct, exercise_ct);
    printf("%sAll %d exercises complete.%s\n", C_GREEN, exercise_ct, C_RESET);
    return 0;
}

int cmd_run(const char *name) {
    discover();
    const Ex *e = find(name);
    if (e == NULL) {
        if (name == NULL)
            printf("%sEvery exercise is done.%s\n", C_GREEN, C_RESET);
        return name == NULL ? 0 : 2;
    }
    return report(e, check(e, out, sizeof out)) ? 0 : 1;
}

/// Prints the exercise's opening comment and the chapter README, which together act as the hint.
int cmd_hint(const char *name) {
    discover();
    const Ex *e = find(name);
    if (e == NULL)
        return name == NULL ? 0 : 2;
    printf("%s%s/%s%s\n", C_CYAN, e->chapter, e->name, C_RESET);
    char *src = slurp(e->path);
    char *start = src ? strstr(src, "/*") : NULL;
    char *end = start ? strstr(start, "*/") : NULL;
    if (end) {
        *end = '\0';
        indent(start + 2);
    }
    free(src);
    char readme[PATH_MAX];
    snprintf(readme, sizeof readme, "exercises/%s/README.md", e->chapter);
    char *r = slurp(readme);
    if (r) {
        printf("\n%sChapter notes:%s\n", C_CYAN, C_RESET);
        indent(r);
        free(r);
    }
    return 0;
}

int cmd_list(void) {
    discover();
    int n_done = 0;
    for (int i = 0; i < exercise_ct; i++) {
        const Ex *e = &exercises[i];
        bool p = !done(e);
        n_done += !p;
        printf("%s%s%s  %-32s ", p ? C_YELLOW : C_GREEN, p ? "PENDING" : "DONE   ", C_RESET, e->name);
        print_file_link(e->path);
        putchar('\n');
    }
    putchar('\n');
    print_progress(n_done, exercise_ct);
    return 0;
}

int cmd_reset(const char *name) {
    if (name == NULL) {
        fprintf(stderr, "which exercise? (try `clings list`)\n");
        return 2;
    }
    discover();
    const Ex *e = find(name);
    if (e == NULL)
        return 2;
    char tmpl[PATH_MAX + 16];
    snprintf(tmpl, sizeof tmpl, ".templates/%s", e->path + strlen("exercises/"));
    char *src = slurp(tmpl);
    if (src == NULL) {
        fprintf(stderr, "%sno pristine copy at %s%s\n", C_RED, tmpl, C_RESET);
        return 1;
    }
    FILE *f = fopen(e->path, "w");
    if (f == NULL) {
        perror(e->path);
        free(src);
        return 1;
    }
    fputs(src, f);
    fclose(f);
    free(src);
    printf("%sreset %s to its original state%s\n", C_YELLOW, e->name, C_RESET);
    return 0;
}

static bool on_path(const char *tool, char *found, size_t cap) {
    const char *path = getenv("PATH");
    if (path == NULL)
        return false;
    char *copy = strdup(path);
    bool ok = false;
    for (char *dir = strtok(copy, ":"); dir && !ok; dir = strtok(NULL, ":")) {
        snprintf(found, cap, "%s/%s", dir, tool);
        ok = access(found, X_OK) == 0;
    }
    free(copy);
    return ok;
}

int cmd_doctor(void) {
    const char *tools[][2] = {
        {"gcc", "install gcc (or build-essential on Debian/Ubuntu)"},
        {"make", "install make"},
    };
    int missing = 0;
    char found[PATH_MAX];
    for (size_t i = 0; i < sizeof tools / sizeof tools[0]; i++) {
        if (on_path(tools[i][0], found, sizeof found)) {
            printf("%sok     %s %-6s %s\n", C_GREEN, C_RESET, tools[i][0], found);
        } else {
            missing++;
            printf("%smissing%s %-6s %s\n", C_RED, C_RESET, tools[i][0], tools[i][1]);
        }
    }
    if (on_path("gdb", found, sizeof found))
        printf("%sok     %s %-6s %s %s(optional: debugging)%s\n", C_GREEN, C_RESET, "gdb", found, C_DIM, C_RESET);
    else
        printf("%smissing%s %-6s %s %s(optional: debugging)%s\n", C_YELLOW, C_RESET, "gdb", "install gdb", C_DIM, C_RESET);
    putchar('\n');
    if (missing == 0) {
        printf("%sEverything is installed.%s\n", C_GREEN, C_RESET);
        return 0;
    }
    printf("%s%d missing.%s\n", C_YELLOW, missing, C_RESET);
    return 1;
}

int count_done(int *total) {
    discover();
    int n = 0;
    for (int i = 0; i < exercise_ct; i++)
        n += done(&exercises[i]);
    *total = exercise_ct;
    return n;
}
