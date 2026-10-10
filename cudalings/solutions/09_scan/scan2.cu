// scan2: scanning more than one block
//
// For an array bigger than one block: (1) scan each block on its own and save
// each block's total, (2) scan the totals, (3) add to every element the sum of
// all the blocks before its own. That prefix for block b is the total of blocks
// 0 .. b-1, which is the *exclusive* scan of the totals: element b - 1 of their
// inclusive scan, or 0 for block 0.
//
// Task: add_offsets adds the inclusive scan, so each block also counts its own
// total. Fix it.
#include <cstdio>

#define BLOCK 256

__global__ void scan_blocks(const int *in, int *out, int *totals, int n) {
    __shared__ int x[BLOCK];
    int t = threadIdx.x;
    int i = blockIdx.x * BLOCK + t;
    x[t] = i < n ? in[i] : 0;
    __syncthreads();
    for (int offset = 1; offset < BLOCK; offset *= 2) {
        int add = t >= offset ? x[t - offset] : 0;
        __syncthreads();
        x[t] += add;
        __syncthreads();
    }
    if (i < n) out[i] = x[t];
    if (totals && t == BLOCK - 1) totals[blockIdx.x] = x[t];
}

__global__ void add_offsets(int *out, const int *scanned_totals) {
    if (blockIdx.x > 0) out[blockIdx.x * BLOCK + threadIdx.x] += scanned_totals[blockIdx.x - 1];
}

int main() {
    const int blocks = 16, n = blocks * BLOCK;
    static int in[n], out[n];
    for (int i = 0; i < n; i++) in[i] = i % 5 + 1;
    int *d_in, *d_out, *d_totals, *d_scanned;
    cudaMalloc(&d_in, sizeof in);
    cudaMalloc(&d_out, sizeof out);
    cudaMalloc(&d_totals, blocks * sizeof(int));
    cudaMalloc(&d_scanned, blocks * sizeof(int));
    cudaMemcpy(d_in, in, sizeof in, cudaMemcpyHostToDevice);

    scan_blocks<<<blocks, BLOCK>>>(d_in, d_out, d_totals, n);
    scan_blocks<<<1, BLOCK>>>(d_totals, d_scanned, nullptr, blocks);
    add_offsets<<<blocks, BLOCK>>>(d_out, d_scanned);

    cudaMemcpy(out, d_out, sizeof out, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);
    cudaFree(d_totals);
    cudaFree(d_scanned);

    int running = 0, wrong = 0;
    for (int i = 0; i < n; i++) wrong += out[i] != (running += in[i]);
    printf("out[255] = %d, out[256] = %d, out[%d] = %d\n", out[255], out[256], n - 1, out[n - 1]);
    printf("wrong: %d\n", wrong);
    return 0;
}
