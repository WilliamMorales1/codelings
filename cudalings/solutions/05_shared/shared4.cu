// shared4: transpose through a tile
//
// A naive transpose reads rows and writes columns, so one side is always
// scattered across memory. Going through a shared tile fixes that: read a
// TILE x TILE block with row-wise (coalesced) reads, then write it out, again
// row-wise, to the mirrored block. The transpose itself happens in how you
// index the tile.
//
// Task: the write-out reads the tile with its indices the wrong way round.
#include <cstdio>

#define TILE 32

__global__ void transpose(const float *in, float *out, int W, int H) {
    __shared__ float tile[TILE][TILE + 1]; // +1 column avoids bank conflicts on the transposed read
    int x = blockIdx.x * TILE + threadIdx.x;
    int y = blockIdx.y * TILE + threadIdx.y;
    if (x < W && y < H) tile[threadIdx.y][threadIdx.x] = in[y * W + x];
    __syncthreads();
    x = blockIdx.y * TILE + threadIdx.x;
    y = blockIdx.x * TILE + threadIdx.y;
    if (x < H && y < W) out[y * H + x] = tile[threadIdx.x][threadIdx.y];
}

int main() {
    const int W = 100, H = 70;
    static float in[W * H], out[W * H];
    for (int i = 0; i < W * H; i++) in[i] = i;
    float *d_in, *d_out;
    cudaMalloc(&d_in, sizeof in);
    cudaMalloc(&d_out, sizeof out);
    cudaMemcpy(d_in, in, sizeof in, cudaMemcpyHostToDevice);
    dim3 block(TILE, TILE), grid((W + TILE - 1) / TILE, (H + TILE - 1) / TILE);
    transpose<<<grid, block>>>(d_in, d_out, W, H);
    cudaMemcpy(out, d_out, sizeof out, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);

    int mismatches = 0;
    for (int r = 0; r < H; r++)
        for (int c = 0; c < W; c++) mismatches += out[c * H + r] != in[r * W + c];
    printf("out[1][0] = %g\n", out[H]);
    printf("mismatches: %d\n", mismatches);
    return 0;
}
