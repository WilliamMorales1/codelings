// kernels4: the bounds check
//
// Rounding the block count up means the last block has threads past the end of
// the array. Unless they check, they read and write memory that isn't theirs.
// The GPU often doesn't crash when that happens, which is worse: you silently
// corrupt whatever lives next door.
//
// compute-sanitizer finds these. This exercise's check runs the program under
// `compute-sanitizer --tool memcheck`, and so can you:
//     nvcc -I include -o /tmp/k4 exercises/01_kernels/kernels4.cu
//     compute-sanitizer /tmp/k4
//
// Task: stop the extra threads from touching memory past the end of the arrays.
#include <cstdio>

__global__ void scale(const float *in, float *out, float k, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    out[i] = k * in[i];
}

int main() {
    const int n = 1000, threads = 256;
    const int blocks = (n + threads - 1) / threads;

    static float h[n];
    for (int i = 0; i < n; i++) h[i] = i;
    float *d_in, *d_out;
    cudaMalloc(&d_in, n * sizeof(float));
    cudaMalloc(&d_out, n * sizeof(float));
    cudaMemcpy(d_in, h, sizeof h, cudaMemcpyHostToDevice);
    scale<<<blocks, threads>>>(d_in, d_out, 2.0f, n);
    cudaMemcpy(h, d_out, sizeof h, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);

    double sum = 0;
    for (int i = 0; i < n; i++) sum += h[i];
    printf("out[999] = %.1f\n", h[999]);
    printf("sum = %.1f\n", sum);
    return 0;
}
