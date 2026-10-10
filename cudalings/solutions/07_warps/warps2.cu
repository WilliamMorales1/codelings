// warps2: voting
//
// __ballot_sync(mask, predicate) returns, to every lane, a 32-bit mask with bit
// k set if lane k's predicate was true. __popc counts the set bits of an int.
//
// Task: count, per warp, how many values are negative. The kernel stores the
// raw ballot mask instead of the count.
#include "cudalings.cuh"

__global__ void count_negative(const int *in, int *out) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned mask = __ballot_sync(0xffffffff, in[i] < 0);
    if (threadIdx.x % 32 == 0) out[i / 32] = __popc(mask);
}

int main() {
    const int n = 128, warps = n / 32;
    int h[n];
    for (int i = 0; i < n; i++) h[i] = (i % 3 == 0 || i % 7 == 0) ? -i : i;
    int *d_in, *d_out;
    cudaMalloc(&d_in, sizeof h);
    cudaMalloc(&d_out, warps * sizeof(int));
    cudaMemcpy(d_in, h, sizeof h, cudaMemcpyHostToDevice);
    count_negative<<<1, n>>>(d_in, d_out);
    int out[warps];
    cudaMemcpy(out, d_out, sizeof out, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);
    print_ints(out, warps);
    return 0;
}
