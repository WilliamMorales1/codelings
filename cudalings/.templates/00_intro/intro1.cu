// intro1: hello, GPU
//
// A kernel is a function marked __global__. The CPU (the "host") launches it on
// the GPU (the "device") with kernel<<<blocks, threadsPerBlock>>>(args).
// Launches are asynchronous: cudaDeviceSynchronize() waits for the kernel to
// finish, and also flushes anything the kernel printf'd.
//
// Task: this kernel is launched with zero blocks, so it never runs. Launch one
// block of one thread instead. Keep `./cudalings watch` running in another
// terminal; it re-checks every time you save.
#include <cstdio>

__global__ void hello() {
    printf("Hello from the GPU!\n");
}

int main() {
    printf("Hello from the CPU!\n");
    hello<<<0, 1>>>();
    cudaDeviceSynchronize();
    return 0;
}
