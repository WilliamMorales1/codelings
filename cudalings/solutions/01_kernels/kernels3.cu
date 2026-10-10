// kernels3: how many blocks?
//
// n is rarely a multiple of the block size. With n = 1000 and 256 threads per
// block, n / 256 is 3 blocks: 768 threads, so the last 232 elements are never
// touched. Round the division up instead.
//
// Task: fix `blocks` so that every element gets a thread.
#include <cstdio>

__global__ void fill(int *out, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) out[i] = 1;
}

int main() {
    const int n = 1000, threads = 256;
    int blocks = (n + threads - 1) / threads;

    int *d_out;
    cudaMalloc(&d_out, n * sizeof(int));
    cudaMemset(d_out, 0, n * sizeof(int));
    fill<<<blocks, threads>>>(d_out, n);

    static int h_out[n];
    cudaMemcpy(h_out, d_out, sizeof h_out, cudaMemcpyDeviceToHost);
    cudaFree(d_out);
    int filled = 0;
    for (int i = 0; i < n; i++) filled += h_out[i];
    printf("blocks: %d\n", blocks);
    printf("filled: %d of %d\n", filled, n);
    return 0;
}
