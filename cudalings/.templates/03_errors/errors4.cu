// errors4: timing with events
//
// A CPU timer around a launch measures how long it took to queue the kernel, not
// to run it. CUDA events are timestamps the GPU records as it reaches them:
//     cudaEventRecord(start);
//     kernel<<<...>>>(...);
//     cudaEventRecord(stop);
//     cudaEventSynchronize(stop);            // wait until the GPU gets to `stop`
//     cudaEventElapsedTime(&ms, start, stop);
//
// Task: record the two events around the kernel and wait for `stop`, so that
// cudaEventElapsedTime succeeds.
#include "cudalings.cuh"

__global__ void saxpy(float a, const float *x, float *y, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) y[i] = a * x[i] + y[i];
}

int main() {
    const int n = 1 << 22;
    float *x, *y;
    CUDA_CHECK(cudaMalloc(&x, n * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&y, n * sizeof(float)));
    CUDA_CHECK(cudaMemset(x, 0, n * sizeof(float)));
    CUDA_CHECK(cudaMemset(y, 0, n * sizeof(float)));

    cudaEvent_t start, stop;
    CUDA_CHECK(cudaEventCreate(&start));
    CUDA_CHECK(cudaEventCreate(&stop));
    // TODO: record start
    saxpy<<<(n + 255) / 256, 256>>>(2.0f, x, y, n);
    // TODO: record stop, then wait for it

    float ms = 0;
    cudaError_t err = cudaEventElapsedTime(&ms, start, stop);
    printf("elapsed time: %s\n", err == cudaSuccess ? "ok" : cudaGetErrorString(err));
    printf("positive: %s\n", ms > 0 ? "yes" : "no");

    CUDA_CHECK(cudaEventDestroy(start));
    CUDA_CHECK(cudaEventDestroy(stop));
    CUDA_CHECK(cudaFree(x));
    CUDA_CHECK(cudaFree(y));
    return 0;
}
