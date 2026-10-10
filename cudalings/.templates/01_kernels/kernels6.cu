// kernels6: __device__ and __host__ functions
//
// Code called from a kernel must be compiled for the GPU. A plain C++ function
// is host-only. Mark it __device__ to call it from kernels, or
// __host__ __device__ to get a version for each side.
//
// Task: `smoothstep` is called by the kernel and by the CPU check in main. Make
// it compile for both.
#include <cmath>
#include <cstdio>

float smoothstep(float x) {
    x = x < 0.0f ? 0.0f : (x > 1.0f ? 1.0f : x);
    return x * x * (3.0f - 2.0f * x);
}

__global__ void apply(float *v, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) v[i] = smoothstep(v[i]);
}

int main() {
    const int n = 11;
    float h[n], ref[n];
    for (int i = 0; i < n; i++) h[i] = -0.25f + 0.15f * i;
    for (int i = 0; i < n; i++) ref[i] = smoothstep(h[i]);

    float *d;
    cudaMalloc(&d, sizeof h);
    cudaMemcpy(d, h, sizeof h, cudaMemcpyHostToDevice);
    apply<<<1, 32>>>(d, n);
    cudaMemcpy(h, d, sizeof h, cudaMemcpyDeviceToHost);
    cudaFree(d);

    bool same = true;
    for (int i = 0; i < n; i++) {
        printf(i ? " %.3f" : "%.3f", h[i]);
        same = same && fabsf(h[i] - ref[i]) < 1e-5f;
    }
    printf("\nmatches CPU: %s\n", same ? "yes" : "no");
    return 0;
}
