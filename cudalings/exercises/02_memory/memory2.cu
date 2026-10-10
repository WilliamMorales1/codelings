// memory2: sizes are in bytes
//
// cudaMalloc and cudaMemcpy count bytes, not elements. Ask for n bytes and you
// get room for n / 4 floats.
//
// Task: fix the allocation so it holds n floats. The check also runs
// compute-sanitizer memcheck, which reports any access past the end of an
// allocation.
#include <cstdio>

__global__ void negate(float *v, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) v[i] = -v[i];
}

int main() {
    const int n = 256;
    float h[n];
    for (int i = 0; i < n; i++) h[i] = 0.5f * i;

    float *d;
    cudaMalloc(&d, n);
    cudaMemcpy(d, h, n * sizeof(float), cudaMemcpyHostToDevice);
    negate<<<1, n>>>(d, n);
    cudaMemcpy(h, d, n * sizeof(float), cudaMemcpyDeviceToHost);
    cudaFree(d);

    float sum = 0;
    for (int i = 0; i < n; i++) sum += h[i];
    printf("h[255] = %.1f\n", h[255]);
    printf("sum = %.1f\n", sum);
    return 0;
}
