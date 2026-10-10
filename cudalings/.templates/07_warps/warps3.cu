// warps3: broadcast
//
// __shfl_sync(mask, v, srcLane) gives every lane the `v` held by lane srcLane. A
// common use: one lane does something expensive, like an atomic, and shares the
// result with the rest of its warp.
//
// Task: lane 0 reserves 32 output slots for its warp with a single atomicAdd,
// and every lane should then use lane 0's `base`. Right now each lane fetches
// its own `base`, which is only set in lane 0.
#include <algorithm>
#include <cstdio>

__global__ void append(int *out, int *count) {
    int lane = threadIdx.x % 32;
    int base = 0;
    if (lane == 0) base = atomicAdd(count, 32);
    base = __shfl_sync(0xffffffff, base, lane);
    out[base + lane] = blockIdx.x * blockDim.x + threadIdx.x;
}

int main() {
    const int blocks = 8, threads = 64, n = blocks * threads;
    int *d_out, *d_count;
    cudaMalloc(&d_out, n * sizeof(int));
    cudaMalloc(&d_count, sizeof(int));
    cudaMemset(d_out, 0xff, n * sizeof(int));
    cudaMemset(d_count, 0, sizeof(int));
    append<<<blocks, threads>>>(d_out, d_count);
    static int out[n];
    int count = 0;
    cudaMemcpy(out, d_out, sizeof out, cudaMemcpyDeviceToHost);
    cudaMemcpy(&count, d_count, sizeof count, cudaMemcpyDeviceToHost);
    cudaFree(d_out);
    cudaFree(d_count);

    std::sort(out, out + n);
    bool once = true;
    for (int i = 0; i < n; i++) once = once && out[i] == i;
    printf("reserved: %d\n", count);
    printf("every thread wrote exactly one slot: %s\n", once ? "yes" : "no");
    return 0;
}
