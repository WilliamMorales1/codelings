// errors3: errors arrive late
//
// A launch only queues the kernel. cudaGetLastError() right after it catches a
// bad launch configuration, but not what goes wrong while the kernel runs: that
// is reported by the next call that waits for the GPU, such as
// cudaDeviceSynchronize(). Errors like an illegal address are also "sticky":
// once one happens, every later CUDA call in the process fails too.
//
// Task: this kernel writes through a null pointer. The launch itself looks
// fine. Make the program also report the error from running the kernel.
#include <cstdio>

__global__ void oops(int *p) {
    p[threadIdx.x] = 1;
}

int main() {
    oops<<<1, 32>>>(nullptr);
    printf("launch: %s\n", cudaGetErrorString(cudaGetLastError()));
    cudaError_t run = cudaDeviceSynchronize();
    printf("run: %s\n", cudaGetErrorString(run));
    return 0;
}
