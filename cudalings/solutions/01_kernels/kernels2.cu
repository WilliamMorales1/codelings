// kernels2: blockIdx and blockDim
//
// Threads come in blocks. threadIdx.x restarts at 0 in every block, so on its own
// it can't tell threads in different blocks apart. blockIdx.x is the block's
// number, and blockDim.x is how many threads each block has.
//
// Task: launched as 4 blocks of 8 threads, each of the 32 threads should write
// its global index into out[global index]. Work that index out.
#include "cudalings.cuh"

__global__ void iota(int *out) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    out[i] = i;
}

int main() {
    const int n = 32;
    int *d_out;
    cudaMalloc(&d_out, n * sizeof(int));
    cudaMemset(d_out, 0xff, n * sizeof(int)); // every int becomes -1
    iota<<<4, 8>>>(d_out);

    int h_out[n];
    cudaMemcpy(h_out, d_out, sizeof h_out, cudaMemcpyDeviceToHost);
    cudaFree(d_out);
    print_ints(h_out, n);
    return 0;
}
