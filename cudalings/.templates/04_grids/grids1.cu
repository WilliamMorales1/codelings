// grids1: 2D blocks
//
// threadIdx, blockIdx, blockDim and gridDim each have .x, .y and .z. For images
// and matrices the convention is x for the column and y for the row, so threads
// with consecutive x touch consecutive addresses of a row-major array.
//
// Task: `label` should write row * 1000 + col into every cell of an H x W
// row-major matrix. Its row and column are mixed up.
#include <cstdio>

__global__ void label(int *m, int H, int W) {
    int col = blockIdx.y * blockDim.y + threadIdx.y;
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < H && col < W) m[row * W + col] = row * 1000 + col;
}

int main() {
    const int H = 19, W = 37;
    dim3 block(16, 16);
    dim3 grid((W + 15) / 16, (H + 15) / 16);

    int *d;
    cudaMalloc(&d, H * W * sizeof(int));
    cudaMemset(d, 0xff, H * W * sizeof(int));
    label<<<grid, block>>>(d, H, W);
    static int m[H * W];
    cudaMemcpy(m, d, sizeof m, cudaMemcpyDeviceToHost);
    cudaFree(d);

    int mismatches = 0;
    for (int r = 0; r < H; r++)
        for (int c = 0; c < W; c++) mismatches += m[r * W + c] != r * 1000 + c;
    printf("m[0][36] = %d\n", m[W - 1]);
    printf("m[18][0] = %d\n", m[(H - 1) * W]);
    printf("mismatches: %d\n", mismatches);
    return 0;
}
