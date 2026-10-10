// streams1: launching into a stream
//
// A stream is a queue of GPU work that runs in order. Work in different streams
// may overlap: a copy in one while a kernel runs in another. The full launch
// syntax is kernel<<<blocks, threads, sharedBytes, stream>>>. The stream comes
// fourth, after the dynamic shared memory size (0 if you use none).
//
// Copies into a stream use cudaMemcpyAsync, and only overlap with other work
// when the host memory is pinned (cudaMallocHost).
//
// Task: make the launch compile and run in `stream`.
#include "cudalings.cuh"

__global__ void scale(float *v, float k, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) v[i] *= k;
}

int main() {
    const int n = 1024, threads = 256, blocks = n / threads;
    cudaStream_t stream;
    CUDA_CHECK(cudaStreamCreate(&stream));
    float *h, *d;
    CUDA_CHECK(cudaMallocHost(&h, n * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d, n * sizeof(float)));
    for (int i = 0; i < n; i++) h[i] = i;

    CUDA_CHECK(cudaMemcpyAsync(d, h, n * sizeof(float), cudaMemcpyHostToDevice, stream));
    scale<<<blocks, threads, 0, stream>>>(d, 0.5f, n);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaMemcpyAsync(h, d, n * sizeof(float), cudaMemcpyDeviceToHost, stream));
    CUDA_CHECK(cudaStreamSynchronize(stream));

    double sum = 0;
    for (int i = 0; i < n; i++) sum += h[i];
    printf("h[1] = %g, h[1023] = %g\n", h[1], h[n - 1]);
    printf("sum = %.1f\n", sum);
    CUDA_CHECK(cudaFreeHost(h));
    CUDA_CHECK(cudaFree(d));
    CUDA_CHECK(cudaStreamDestroy(stream));
    return 0;
}
