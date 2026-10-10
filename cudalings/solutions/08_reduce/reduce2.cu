// reduce2: warps first
//
// The shared-memory tree spends its last five steps with fewer than 32 threads
// doing anything. Faster: each warp sums its 32 values with shuffles (warps1),
// lane 0 of each warp writes one partial sum to shared memory, and the first
// warp sums those partials the same way.
//
// Task: a thread's lane is its position within its warp, threadIdx.x % 32, and
// its warp number is threadIdx.x / 32. The kernel has them swapped.
#include <cstdio>

#define BLOCK 256

__device__ int warp_sum(int v) {
    for (int offset = 16; offset > 0; offset /= 2) {
        v += __shfl_down_sync(0xffffffff, v, offset);
    }
    return v;
}

__global__ void block_sum(const int *in, int *out) {
    __shared__ int partial[BLOCK / 32];
    int lane = threadIdx.x % 32;
    int warp = threadIdx.x / 32;
    int v = warp_sum(in[blockIdx.x * BLOCK + threadIdx.x]);
    if (lane == 0) partial[warp] = v;
    __syncthreads();
    if (warp == 0) {
        v = warp_sum(lane < BLOCK / 32 ? partial[lane] : 0);
        if (lane == 0) out[blockIdx.x] = v;
    }
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
