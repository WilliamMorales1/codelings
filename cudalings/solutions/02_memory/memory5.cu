// memory5: constant memory
//
// __constant__ variables live in a small (64 KB), cached memory that kernels can
// only read. It is fast when every thread in a warp reads the same address, as
// with filter weights. The host fills it with cudaMemcpyToSymbol.
//
// Task: `weights` is never filled in, so the blur multiplies everything by zero.
// Copy h_weights into it.
#include <cstdio>

__constant__ float weights[5];

__global__ void blur(const float *in, float *out, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n) return;
    float acc = 0.0f;
    for (int k = -2; k <= 2; k++) {
        int j = min(max(i + k, 0), n - 1);
        acc += weights[k + 2] * in[j];
    }
    out[i] = acc;
}

int main() {
    const int n = 16;
    const float h_weights[5] = {1 / 16.0f, 4 / 16.0f, 6 / 16.0f, 4 / 16.0f, 1 / 16.0f};
    cudaMemcpyToSymbol(weights, h_weights, sizeof h_weights);

    float h[n] = {0};
    h[8] = 16.0f;
    float *d_in, *d_out;
    cudaMalloc(&d_in, sizeof h);
    cudaMalloc(&d_out, sizeof h);
    cudaMemcpy(d_in, h, sizeof h, cudaMemcpyHostToDevice);
    blur<<<1, 32>>>(d_in, d_out, n);
    cudaMemcpy(h, d_out, sizeof h, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);
    for (int i = 0; i < n; i++) printf(i ? " %g" : "%g", h[i]);
    printf("\n");
    return 0;
}
