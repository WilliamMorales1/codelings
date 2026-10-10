// memory4: unified memory and waiting
//
// cudaMallocManaged gives you one pointer that works on both sides; the driver
// moves the data to whichever processor touches it. No cudaMemcpy needed.
//
// But a launch returns immediately, long before the kernel is done. Read the
// results too early and you see the old values (or, on some systems, crash).
// cudaDeviceSynchronize() blocks until all queued GPU work has finished.
//
// Task: wait for the kernel before printing. This kernel is deliberately slow,
// so reading early always shows the problem.
#include "cudalings.cuh"

__global__ void slow_cube(int *v, int n) {
    long long start = clock64();
    while (clock64() - start < 50000000) {
    }
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) v[i] = v[i] * v[i] * v[i];
}

int main() {
    const int n = 10;
    int *data;
    CUDA_CHECK(cudaMallocManaged(&data, n * sizeof(int)));
    for (int i = 0; i < n; i++) data[i] = i;

    slow_cube<<<1, 32>>>(data, n);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    print_ints(data, n);
    CUDA_CHECK(cudaFree(data));
    return 0;
}
