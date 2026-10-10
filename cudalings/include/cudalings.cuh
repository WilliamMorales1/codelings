// Helpers shared by the exercises. You don't need to edit this file.
#pragma once
#include <cstdio>
#include <cstdlib>

// CUDA_CHECK aborts with the file, line and error text when a runtime call fails.
#define CUDA_CHECK(call)                                                          \
    do {                                                                          \
        cudaError_t err_ = (call);                                                \
        if (err_ != cudaSuccess) {                                                \
            fprintf(stderr, "%s:%d: %s failed: %s\n", __FILE__, __LINE__, #call, \
                    cudaGetErrorString(err_));                                    \
            exit(1);                                                              \
        }                                                                         \
    } while (0)

// print_ints prints n ints on one line, separated by spaces.
inline void print_ints(const int *v, int n) {
    for (int i = 0; i < n; i++) printf(i ? " %d" : "%d", v[i]);
    printf("\n");
}
