// reduce3: one number from many blocks
//
// Blocks can't wait for each other inside a kernel, so a full reduction takes
// two launches: the first leaves one partial sum per block, and the second runs
// as a single block that reduces the partials.
//
// `block_sum` uses a grid-stride loop to load, so one block can sum any number
// of values.
//
// Task: launch the second pass.
#include <cstdio>

#define BLOCK 256

__global__ void block_sum(const int *in, int *out, int n) {
    __shared__ int sdata[BLOCK];
    int t = threadIdx.x;
    int acc = 0;
    for (int i = blockIdx.x * BLOCK + t; i < n; i += BLOCK * gridDim.x) acc += in[i];
    sdata[t] = acc;
    __syncthreads();
    for (int s = BLOCK / 2; s > 0; s /= 2) {
        if (t < s) sdata[t] += sdata[t + s];
        __syncthreads();
    }
    if (t == 0) out[blockIdx.x] = sdata[0];
}

int main() {
    const int n = 200000, blocks = 64;
    static int in[n];
    long long want = 0;
    for (int i = 0; i < n; i++) {
        in[i] = i % 1000;
        want += in[i];
    }
    int *d_in, *d_partial, *d_total;
    cudaMalloc(&d_in, sizeof in);
    cudaMalloc(&d_partial, blocks * sizeof(int));
    cudaMalloc(&d_total, sizeof(int));
    cudaMemcpy(d_in, in, sizeof in, cudaMemcpyHostToDevice);
    cudaMemset(d_total, 0, sizeof(int));

    block_sum<<<blocks, BLOCK>>>(d_in, d_partial, n);
    // TODO: second pass: one block reduces the `blocks` partials into d_total

    int total = 0;
    cudaMemcpy(&total, d_total, sizeof total, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_partial);
    cudaFree(d_total);
    printf("total: %d\n", total);
    printf("correct: %s\n", total == want ? "yes" : "no");
    return 0;
}
