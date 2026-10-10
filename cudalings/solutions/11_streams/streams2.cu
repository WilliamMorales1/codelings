// streams2: overlapping copies and kernels
//
// Split the data into chunks and give each chunk its own stream: chunk 1 can be
// copying in while chunk 0 is being computed. Each stream works on its own slice
// of the arrays, so every copy and every kernel needs the chunk's offset.
//
// Task: one of the three operations per chunk works on the wrong slice.
#include "cudalings.cuh"

#define NSTREAMS 4

__global__ void square(int *v, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) v[i] = v[i] * v[i];
}

int main() {
    const int n = 1 << 20, chunk = n / NSTREAMS;
    int *h, *d;
    CUDA_CHECK(cudaMallocHost(&h, n * sizeof(int)));
    CUDA_CHECK(cudaMalloc(&d, n * sizeof(int)));
    for (int i = 0; i < n; i++) h[i] = i % 1000;

    cudaStream_t streams[NSTREAMS];
    for (int s = 0; s < NSTREAMS; s++) CUDA_CHECK(cudaStreamCreate(&streams[s]));
    for (int s = 0; s < NSTREAMS; s++) {
        int off = s * chunk;
        CUDA_CHECK(cudaMemcpyAsync(d + off, h + off, chunk * sizeof(int), cudaMemcpyHostToDevice, streams[s]));
        square<<<chunk / 256, 256, 0, streams[s]>>>(d + off, chunk);
        CUDA_CHECK(cudaMemcpyAsync(h + off, d + off, chunk * sizeof(int), cudaMemcpyDeviceToHost, streams[s]));
    }
    CUDA_CHECK(cudaDeviceSynchronize());

    int wrong = 0;
    for (int i = 0; i < n; i++) wrong += h[i] != (i % 1000) * (i % 1000);
    printf("h[%d] = %d\n", n - 1, h[n - 1]);
    printf("wrong: %d of %d\n", wrong, n);
    for (int s = 0; s < NSTREAMS; s++) CUDA_CHECK(cudaStreamDestroy(streams[s]));
    CUDA_CHECK(cudaFreeHost(h));
    CUDA_CHECK(cudaFree(d));
    return 0;
}
