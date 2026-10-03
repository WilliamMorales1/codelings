#include "display.h"
#include "commands.h"
#include "runna.h"
#include "term.h"
#include <stdio.h>
#include <string.h>

static void clear_screen(void) {
    printf("\033[2J\033[H");
}

void display(
    Exercise *exercise, 
    ExecutionState *exercise_state, 
    DisplayMode display_mode
) {
    int total;
    int done;
    switch (display_mode) {
        case FAILURE:
            clear_screen();
            done = count_done(&total);
            display_progress(done, total);
            puts("");

            display_failure(exercise, exercise_state);
            break;
        case MARKED_INCOMPLETE:
            clear_screen();
            done = count_done(&total);
            display_progress(done, total);
            puts("");

            display_marked_incomplete(exercise, exercise_state);
            break;
        case COMPLETE:
            display_success();
            break;
    }
    fflush(stdout);
}

static void print_file_line(const char *path) {
    printf("  File: ");
    print_file_link(path);
    printf("\n\n");
}

void display_failure(Exercise *exercise, ExecutionState *exercise_state) {
    FailureMode failure_type = exercise_state->failure_mode;
    File failed_file = exercise->exercise_files->files[exercise_state->failing_file];

    if (failure_type == COMPILATION) {
        printf("⚠️ %sCompiling of %s failed! Please try again. Here's the output: %s\n", C_RED, failed_file.file_path, C_RESET);
        print_file_line(failed_file.file_path);
        fflush(stdout);
        exec_compile_output(failed_file.file_path, failed_file.file_name_no_ext);
        return;
    }

    if (failure_type == RUNTIME) {
        printf("⚠️  %sRunning of %s failed! Please try again. Here's the output: %s\n", C_RED, failed_file.file_path, C_RESET);
        print_file_line(failed_file.file_path);
        fflush(stdout);
        exec_run_output(failed_file.file_name_no_ext);
        return;
    }
}

void display_marked_incomplete(Exercise *exercise, ExecutionState *exercise_state) {
    File failed_file = exercise->exercise_files->files[exercise_state->failing_file];

    printf("✅ %sYou've completed exercise: %s %s\n", C_GREEN, failed_file.file_path, C_RESET);
    print_file_line(failed_file.file_path);
    printf("😎 The code is compiling! 😎 \n");
    puts("");
    printf("Output: \n");
    puts("==========================================");
    fflush(stdout);
    exec_run_output(failed_file.file_name_no_ext);
    puts("==========================================");
    puts("");
    puts("You can keep working on it for fun,\nor delete the commented line below in the exercise file to proceed to the next exercise. \n");
    printf("%s1 | %s// ❌ I AM NOT DONE \n", C_BLUE, C_RESET);
    printf("%s2 | %s\n", C_BLUE, C_RESET);
    printf("%s3 | %s\n\n", C_BLUE, C_RESET);
    printf("%sStuck? Run `./clings hint %s` in another terminal.%s\n", C_DIM, failed_file.file_name_no_ext, C_RESET);
}

void display_progress(int done, int total) {
    print_progress(done, total);
}

void display_success() {
    clear_screen();
    printf("%s"
           "      _ _                 \n"
           "     | (_)                \n"
           "  ___| |_ _ __   __ _ ___ \n"
           " / __| | | '_ \\ / _` / __|\n"
           "| (__| | | | | | (_| \\__ \\\n"
           " \\___|_|_|_| |_|\\__, |___/\n"
           "                 __/ |    \n"
           "                |___/     \n"
           "%s\n", C_GREEN, C_RESET);
    printf("%sCongratulations on completing clings!%s\n", C_GREEN, C_RESET);
}

void display_debug(Exercise *exercise) {
    for (size_t fi = 0; fi < exercise->exercise_files->file_ct; fi++) {
        File exercise_file = exercise->exercise_files->files[fi];

        printf("Exercise: %s | File type: %i | marked incomplete: %i | file diff "
             "found: %i \n",
             exercise_file.file_name, exercise_file.file_type,
             exercise_file.marked_incomplete, exercise_file.file_diff);
    }
}
