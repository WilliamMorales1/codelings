// scan1: inclusive scan
//
// An inclusive scan (prefix sum) turns [3, 1, 4, 1] into [3, 4, 8, 9]. The
// Hillis-Steele way: at each step every element adds the one `offset` places to
// its left, with offset = 1, 2, 4, ... After log2(n) steps each element holds
// the sum of everything up to and including itself.
//
// The catch: in a step, thread t reads x[t - offset] while thread t - offset may
// be updating that same slot. Every read has to finish before anyone writes.
//
// Task: split the update into a read, a barrier, and a write. The check runs
// compute-sanitizer racecheck.
#include "cudalings.cuh"

#define BLOCK 256

__global__ void scan(const int *in, int *out) {
    __shared__ int x[BLOCK];
    int t = threadIdx.x;
    x[t] = in[t];
    __syncthreads();
    for (int offset = 1; offset < BLOCK; offset *= 2) {
        int add = t >= offset ? x[t - offset] : 0;
        __syncthreads();
        x[t] += add;
        __syncthreads();
    }
    out[t] = x[t];
}

int main() {
    int in[BLOCK], out[BLOCK];
    for (int i = 0; i < BLOCK; i++) in[i] = i % 5 + 1;
    int *d_in, *d_out;
    cudaMalloc(&d_in, sizeof in);
    cudaMalloc(&d_out, sizeof out);
    cudaMemcpy(d_in, in, sizeof in, cudaMemcpyHostToDevice);
    scan<<<1, BLOCK>>>(d_in, d_out);
    cudaMemcpy(out, d_out, sizeof out, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);

    int running = 0, wrong = 0;
    for (int i = 0; i < BLOCK; i++) wrong += out[i] != (running += in[i]);
    print_ints(out, 8);
    printf("out[255] = %d\n", out[255]);
    printf("wrong: %d\n", wrong);
    return 0;
}
