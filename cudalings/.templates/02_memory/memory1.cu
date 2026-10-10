// memory1: host and device memory
//
// The GPU has its own memory. cudaMalloc allocates there, and the pointer it
// returns only means something on the device. Data moves with cudaMemcpy, whose
// last argument spells out the direction:
//     cudaMemcpyHostToDevice   CPU -> GPU
//     cudaMemcpyDeviceToHost   GPU -> CPU
//
// Task: the input is copied up and doubled, but the results never come back.
// Fix the last copy.
#include "cudalings.cuh"

__global__ void twice(int *v, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) v[i] *= 2;
}

int main() {
    const int n = 8;
    int h[n];
    for (int i = 0; i < n; i++) h[i] = i + 1;

    int *d;
    cudaMalloc(&d, sizeof h);
    cudaMemcpy(d, h, sizeof h, cudaMemcpyHostToDevice);
    twice<<<1, n>>>(d, n);
    cudaMemcpy(h, d, sizeof h, cudaMemcpyHostToDevice);
    cudaFree(d);
    print_ints(h, n);
    return 0;
}
