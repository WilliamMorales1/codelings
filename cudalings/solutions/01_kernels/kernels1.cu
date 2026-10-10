// kernels1: threadIdx
//
// One launch runs many threads, all executing the same kernel. Each thread finds
// out which one it is from the built-in variable threadIdx.x (0, 1, 2, ... within
// its block) and uses it to pick its own piece of the work.
//
// Task: launched with 8 threads, each thread should write the square of its own
// index, out[i] = i * i. Right now every thread writes to out[0].
#include "cudalings.cuh"

__global__ void squares(int *out) {
    int i = threadIdx.x;
    out[i] = i * i;
}

int main() {
    const int n = 8;
    int *d_out;
    cudaMalloc(&d_out, n * sizeof(int));
    cudaMemset(d_out, 0, n * sizeof(int));
    squares<<<1, n>>>(d_out);

    int h_out[n];
    cudaMemcpy(h_out, d_out, sizeof h_out, cudaMemcpyDeviceToHost);
    cudaFree(d_out);
    print_ints(h_out, n);
    return 0;
}
