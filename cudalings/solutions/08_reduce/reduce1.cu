// reduce1: tree reduction in shared memory
//
// To sum a block's values: load them into shared memory, then repeatedly have
// the first half of the threads add in the second half. 256 values become 128,
// then 64, ... then 1, with a __syncthreads() between steps so nobody reads a
// value that is still being written.
//
// Task: write the step inside the loop. Thread t, if t < s, adds sdata[t + s]
// into sdata[t]. The check runs compute-sanitizer racecheck too.
#include <cstdio>

#define BLOCK 256

__global__ void block_sum(const int *in, int *out) {
    __shared__ int sdata[BLOCK];
    int t = threadIdx.x;
    sdata[t] = in[blockIdx.x * BLOCK + t];
    __syncthreads();
    for (int s = BLOCK / 2; s > 0; s /= 2) {
        if (t < s) sdata[t] += sdata[t + s];
        __syncthreads();
    }
    if (t == 0) out[blockIdx.x] = sdata[0];
}

int main() {
    const int blocks = 8, n = blocks * BLOCK;
    static int in[n];
    for (int i = 0; i < n; i++) in[i] = (i * 37) % 101;
    int *d_in, *d_out;
    cudaMalloc(&d_in, sizeof in);
    cudaMalloc(&d_out, blocks * sizeof(int));
    cudaMemcpy(d_in, in, sizeof in, cudaMemcpyHostToDevice);
    block_sum<<<blocks, BLOCK>>>(d_in, d_out);
    int out[blocks];
    cudaMemcpy(out, d_out, sizeof out, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);

    int wrong = 0;
    for (int b = 0; b < blocks; b++) {
        int want = 0;
        for (int t = 0; t < BLOCK; t++) want += in[b * BLOCK + t];
        printf(b ? " %d" : "%d", out[b]);
        wrong += out[b] != want;
    }
    printf("\nwrong blocks: %d\n", wrong);
    return 0;
}
