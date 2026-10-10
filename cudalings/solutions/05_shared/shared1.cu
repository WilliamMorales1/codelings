// shared1: __shared__ and __syncthreads
//
// __shared__ memory is a small, fast scratchpad shared by the threads of one
// block. A typical pattern: every thread loads one element into it, then threads
// read elements that *other* threads loaded. That second step is only safe after
// __syncthreads(), a barrier every thread of the block must reach before any
// can continue.
//
// Without the barrier the program may still print the right answer, when warps
// happen to run in a lucky order. The check runs
//     compute-sanitizer --tool racecheck
// which reports the hazard either way.
//
// Task: each block reverses its own 256 elements. Add the missing barrier.
#include <cstdio>

#define BLOCK 256

__global__ void reverse_blocks(const int *in, int *out) {
    __shared__ int tile[BLOCK];
    int t = threadIdx.x;
    int base = blockIdx.x * BLOCK;
    tile[t] = in[base + t];
    __syncthreads();
    out[base + t] = tile[BLOCK - 1 - t];
}

int main() {
    const int n = 4 * BLOCK;
    static int h[n];
    for (int i = 0; i < n; i++) h[i] = i;
    int *d_in, *d_out;
    cudaMalloc(&d_in, sizeof h);
    cudaMalloc(&d_out, sizeof h);
    cudaMemcpy(d_in, h, sizeof h, cudaMemcpyHostToDevice);
    reverse_blocks<<<n / BLOCK, BLOCK>>>(d_in, d_out);
    cudaMemcpy(h, d_out, sizeof h, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);

    int mismatches = 0;
    for (int i = 0; i < n; i++) mismatches += h[i] != (i / BLOCK) * BLOCK + (BLOCK - 1 - i % BLOCK);
    printf("out[0] = %d, out[255] = %d, out[256] = %d\n", h[0], h[255], h[256]);
    printf("mismatches: %d\n", mismatches);
    return 0;
}
