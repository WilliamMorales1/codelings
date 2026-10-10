// intro2: kernels return void
//
// A kernel can't hand a value back with `return`: it runs on another processor,
// often as thousands of threads at once. Instead the host passes in a pointer to
// GPU memory, the kernel writes its answer there, and the host copies it back.
//
// Task: make this compile. A __global__ function must return void.
#include <cstdio>

__global__ void answer(int *out) {
    *out = 42;
}

int main() {
    int *d_out;
    cudaMalloc(&d_out, sizeof(int));
    answer<<<1, 1>>>(d_out);

    int h_out = 0;
    cudaMemcpy(&h_out, d_out, sizeof(int), cudaMemcpyDeviceToHost);
    cudaFree(d_out);
    printf("The answer is %d\n", h_out);
    return 0;
}
