// grids3: mirror an image
//
// Task: `mirror` flips each row of a W x H greyscale image left to right, so
// column 0 swaps with column W - 1. One index is off by one. The check also
// runs compute-sanitizer memcheck.
#include <cstdio>

__global__ void mirror(const unsigned char *in, unsigned char *out, int W, int H) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    if (row < H && col < W) out[row * W + (W - col)] = in[row * W + col];
}

int main() {
    const int W = 50, H = 30;
    static unsigned char in[W * H], out[W * H];
    for (int r = 0; r < H; r++)
        for (int c = 0; c < W; c++) in[r * W + c] = (r * 7 + c * 3) % 256;

    unsigned char *d_in, *d_out;
    cudaMalloc(&d_in, sizeof in);
    cudaMalloc(&d_out, sizeof out);
    cudaMemcpy(d_in, in, sizeof in, cudaMemcpyHostToDevice);
    cudaMemset(d_out, 0, sizeof out);
    dim3 block(16, 16), grid((W + 15) / 16, (H + 15) / 16);
    mirror<<<grid, block>>>(d_in, d_out, W, H);
    cudaMemcpy(out, d_out, sizeof out, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);

    int mismatches = 0;
    for (int r = 0; r < H; r++)
        for (int c = 0; c < W; c++) mismatches += out[r * W + c] != in[r * W + (W - 1 - c)];
    printf("out[0][0] = %d, in[0][49] = %d\n", out[0], in[W - 1]);
    printf("mismatches: %d\n", mismatches);
    return 0;
}
