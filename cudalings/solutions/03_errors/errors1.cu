// errors1: launches can fail
//
// A block holds at most 1024 threads. Ask for more and the kernel never runs,
// but nothing crashes either: the error only shows up if you ask for it, with
// cudaGetLastError() right after the launch.
//
// Task: the program already prints the launch error. Pick a valid block size.
#include <cstdio>

__global__ void fill(int *v, int n, int x) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) v[i] = x;
}

int main() {
    const int n = 4096;
    const int threads = 256;
    const int blocks = (n + threads - 1) / threads;

    int *d;
    cudaMalloc(&d, n * sizeof(int));
    cudaMemset(d, 0, n * sizeof(int));
    fill<<<blocks, threads>>>(d, n, 7);
    printf("launch: %s\n", cudaGetErrorString(cudaGetLastError()));

    static int h[n];
    cudaMemcpy(h, d, sizeof h, cudaMemcpyDeviceToHost);
    cudaFree(d);
    int filled = 0;
    for (int i = 0; i < n; i++) filled += h[i] == 7;
    printf("filled: %d of %d\n", filled, n);
    return 0;
}
