// atomics1: atomicAdd
//
// `bins[b]++` is three steps: load, add, store. When thousands of threads hit the
// same bin, two of them load the same old value and one increment is lost.
// atomicAdd(&bins[b], 1) does all three as one indivisible operation.
//
// Task: make the histogram count every value.
#include "cudalings.cuh"

__global__ void histogram(const int *values, int *bins, int n) {
    for (int i = blockIdx.x * blockDim.x + threadIdx.x; i < n; i += blockDim.x * gridDim.x) {
        bins[values[i]]++;
    }
}

int main() {
    const int n = 1 << 20, nbins = 8;
    static int values[n];
    for (int i = 0; i < n; i++) values[i] = (i * 2654435761u) >> 29;

    int *d_values, *d_bins;
    cudaMalloc(&d_values, sizeof values);
    cudaMalloc(&d_bins, nbins * sizeof(int));
    cudaMemcpy(d_values, values, sizeof values, cudaMemcpyHostToDevice);
    cudaMemset(d_bins, 0, nbins * sizeof(int));
    histogram<<<64, 256>>>(d_values, d_bins, n);
    int bins[nbins];
    cudaMemcpy(bins, d_bins, sizeof bins, cudaMemcpyDeviceToHost);
    cudaFree(d_values);
    cudaFree(d_bins);

    int total = 0;
    for (int b = 0; b < nbins; b++) total += bins[b];
    print_ints(bins, nbins);
    printf("total: %d of %d\n", total, n);
    return 0;
}
