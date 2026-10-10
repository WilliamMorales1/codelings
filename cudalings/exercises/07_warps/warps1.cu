// warps1: warp shuffles
//
// A warp is 32 threads that execute together. They can read each other's
// registers directly: __shfl_down_sync(mask, v, offset) gives each lane the `v`
// of lane (its own lane + offset). Halving the offset each step sums a whole
// warp in five steps, with no shared memory:
//     offset 16: lane 0 adds lane 16, lane 1 adds lane 17, ...
//     offset 8, 4, 2, 1: ... until lane 0 holds the total.
// The mask 0xffffffff says all 32 lanes take part.
//
// Task: fill in the loop body of warp_sum.
#include "cudalings.cuh"

__device__ int warp_sum(int v) {
    for (int offset = 16; offset > 0; offset /= 2) {
        // TODO: add the v of the lane `offset` places above this one
    }
    return v;
}

__global__ void sums(const int *in, int *out) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int total = warp_sum(in[i]);
    if (threadIdx.x % 32 == 0) out[i / 32] = total;
}

int main() {
    const int n = 128, warps = n / 32;
    int h[n];
    for (int i = 0; i < n; i++) h[i] = i;
    int *d_in, *d_out;
    cudaMalloc(&d_in, sizeof h);
    cudaMalloc(&d_out, warps * sizeof(int));
    cudaMemcpy(d_in, h, sizeof h, cudaMemcpyHostToDevice);
    sums<<<1, n>>>(d_in, d_out);
    int out[warps];
    cudaMemcpy(out, d_out, sizeof out, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);
    print_ints(out, warps);
    return 0;
}
