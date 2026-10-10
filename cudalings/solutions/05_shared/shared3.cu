// shared3: halos
//
// A 1D stencil, out[i] = in[i-R] + ... + in[i+R], reads every input 2R + 1
// times. Loading the block's inputs into shared memory first means global memory
// is read about once per element. But the threads at the edges of a block also
// need R neighbours on each side that belong to the blocks next door: the halo.
//
// Here the input has R elements of padding at each end, so element g lives at
// in[g + R] and every read is in bounds.
//
// Task: the first R threads load the left halo. Have them load the right one too.
#include <cstdio>

#define R 3
#define BLOCK 128

__global__ void stencil(const int *in, int *out) {
    __shared__ int tile[BLOCK + 2 * R];
    int g = blockIdx.x * BLOCK + threadIdx.x;
    int l = threadIdx.x + R;
    tile[l] = in[g + R];
    if (threadIdx.x < R) {
        tile[l - R] = in[g];
        tile[l + BLOCK] = in[g + BLOCK + R];
    }
    __syncthreads();
    int sum = 0;
    for (int k = -R; k <= R; k++) sum += tile[l + k];
    out[g] = sum;
}

int main() {
    const int n = 8 * BLOCK;
    static int in[n + 2 * R], out[n];
    for (int i = 0; i < n + 2 * R; i++) in[i] = i % 11 + 1;

    int *d_in, *d_out;
    cudaMalloc(&d_in, sizeof in);
    cudaMalloc(&d_out, sizeof out);
    cudaMemcpy(d_in, in, sizeof in, cudaMemcpyHostToDevice);
    stencil<<<n / BLOCK, BLOCK>>>(d_in, d_out);
    cudaMemcpy(out, d_out, sizeof out, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);

    int mismatches = 0;
    for (int g = 0; g < n; g++) {
        int want = 0;
        for (int k = 0; k <= 2 * R; k++) want += in[g + k];
        mismatches += out[g] != want;
    }
    printf("out[0] = %d, out[127] = %d, out[128] = %d\n", out[0], out[127], out[128]);
    printf("mismatches: %d\n", mismatches);
    return 0;
}
