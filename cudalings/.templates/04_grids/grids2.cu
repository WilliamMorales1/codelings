// grids2: sizing a 2D grid
//
// dim3 grid(x, y): x comes first. The grid needs enough blocks along x to cover
// every column and enough along y to cover every row.
//
// Task: the grid is sized the wrong way round. Fix it.
#include <cstdio>

__global__ void label(int *m, int H, int W) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    if (row < H && col < W) m[row * W + col] = row * 1000 + col;
}

int main() {
    const int H = 40, W = 100;
    dim3 block(16, 16);
    dim3 grid((H + 15) / 16, (W + 15) / 16);

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
    printf("m[0][99] = %d\n", m[W - 1]);
    printf("m[39][0] = %d\n", m[(H - 1) * W]);
    printf("mismatches: %d\n", mismatches);
    return 0;
}
