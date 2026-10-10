// memory3: copy it up first
//
// Memory from cudaMalloc starts out holding garbage (often zeros, but that is
// never promised). A kernel only sees host data after you copy it over.
//
// The check runs compute-sanitizer --tool initcheck, which flags any read of
// device memory that nothing ever wrote.
//
// Task: the kernel reads d_in, but nothing ever put the input there.
#include "cudalings.cuh"

__global__ void plus_one(const int *in, int *out, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) out[i] = in[i] + 1;
}

int main() {
    const int n = 16;
    int h_in[n], h_out[n];
    for (int i = 0; i < n; i++) h_in[i] = 3 * i;

    int *d_in, *d_out;
    cudaMalloc(&d_in, sizeof h_in);
    cudaMalloc(&d_out, sizeof h_out);
    cudaMemcpy(d_in, h_in, sizeof h_in, cudaMemcpyHostToDevice);
    plus_one<<<1, n>>>(d_in, d_out, n);
    cudaMemcpy(h_out, d_out, sizeof h_out, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);
    print_ints(h_out, n);
    return 0;
}
