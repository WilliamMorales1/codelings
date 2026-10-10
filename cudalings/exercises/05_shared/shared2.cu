// shared2: dynamic shared memory
//
// `__shared__ float buf[256];` fixes the size at compile time. To choose it at
// launch time, declare `extern __shared__ float buf[];` and pass the size in
// bytes as the third launch parameter: kernel<<<blocks, threads, bytes>>>.
// Leave it out and the array is zero bytes long.
//
// Task: the kernel uses one float of shared memory per thread. Pass that size
// when launching. The check runs compute-sanitizer memcheck too.
#include "cudalings.cuh"

__global__ void rotate(const float *in, float *out) {
    extern __shared__ float buf[];
    int t = threadIdx.x;
    int i = blockIdx.x * blockDim.x + t;
    buf[t] = in[i];
    __syncthreads();
    out[i] = buf[(t + 1) % blockDim.x];
}

int main() {
    const int threads = 128, blocks = 4, n = threads * blocks;
    static float h[n];
    for (int i = 0; i < n; i++) h[i] = i;
    float *d_in, *d_out;
    CUDA_CHECK(cudaMalloc(&d_in, sizeof h));
    CUDA_CHECK(cudaMalloc(&d_out, sizeof h));
    CUDA_CHECK(cudaMemcpy(d_in, h, sizeof h, cudaMemcpyHostToDevice));
    rotate<<<blocks, threads>>>(d_in, d_out);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaMemcpy(h, d_out, sizeof h, cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaFree(d_in));
    CUDA_CHECK(cudaFree(d_out));

    int mismatches = 0;
    for (int i = 0; i < n; i++) mismatches += h[i] != (i / threads) * threads + (i + 1) % threads;
    printf("out[0] = %g, out[127] = %g\n", h[0], h[127]);
    printf("mismatches: %d\n", mismatches);
    return 0;
}
