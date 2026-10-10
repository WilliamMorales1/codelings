// kernels5: grid-stride loops
//
// Sometimes you want a fixed-size launch, say a few blocks per multiprocessor,
// however big n is. Then each thread handles several elements: it starts at its
// global index and steps forward by the total number of threads in the grid,
// blockDim.x * gridDim.x, until it runs off the end.
//
// Task: the launch has 4 * 128 = 512 threads for 100000 elements. Turn the body
// of `add_one` into a grid-stride loop so every element gets incremented.
#include <cstdio>

__global__ void add_one(int *data, int n) {
    for (int i = blockIdx.x * blockDim.x + threadIdx.x; i < n; i += blockDim.x * gridDim.x) {
        data[i] += 1;
    }
}

int main() {
    const int n = 100000;
    static int h[n];
    for (int i = 0; i < n; i++) h[i] = i;
    int *d;
    cudaMalloc(&d, sizeof h);
    cudaMemcpy(d, h, sizeof h, cudaMemcpyHostToDevice);
    add_one<<<4, 128>>>(d, n);
    cudaMemcpy(h, d, sizeof h, cudaMemcpyDeviceToHost);
    cudaFree(d);

    int wrong = 0;
    for (int i = 0; i < n; i++) wrong += h[i] != i + 1;
    printf("wrong: %d of %d\n", wrong, n);
    return 0;
}
