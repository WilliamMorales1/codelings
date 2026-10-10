// matmul2: tiled matrix multiply
//
// The naive kernel reads every element of A and B N times from global memory.
// Tiling loads a TILE x TILE piece of A and one of B into shared memory, and each
// thread of the block reuses them TILE times before moving on to the next pair.
// Two barriers per step: after loading (so the tiles are complete) and after
// using them (so nobody overwrites a tile that is still being read).
//
// Task: the B tile is loaded with A's index pattern. A's tiles walk right along
// this block's rows; B's tiles have to walk down this block's columns.
// The check runs compute-sanitizer racecheck too.
#include <cstdio>

#define TILE 16

__global__ void matmul(const float *A, const float *B, float *C, int N) {
    __shared__ float As[TILE][TILE], Bs[TILE][TILE];
    int tx = threadIdx.x, ty = threadIdx.y;
    int row = blockIdx.y * TILE + ty, col = blockIdx.x * TILE + tx;
    float acc = 0.0f;
    for (int t = 0; t < N / TILE; t++) {
        As[ty][tx] = A[row * N + t * TILE + tx];
        Bs[ty][tx] = B[row * N + t * TILE + tx];
        __syncthreads();
        for (int k = 0; k < TILE; k++) acc += As[ty][k] * Bs[k][tx];
        __syncthreads();
    }
    C[row * N + col] = acc;
}

int main() {
    const int N = 128;
    static float A[N * N], B[N * N], C[N * N];
    for (int i = 0; i < N * N; i++) {
        A[i] = i % 7 - 3;
        B[i] = i % 5 - 2;
    }
    float *dA, *dB, *dC;
    cudaMalloc(&dA, sizeof A);
    cudaMalloc(&dB, sizeof B);
    cudaMalloc(&dC, sizeof C);
    cudaMemcpy(dA, A, sizeof A, cudaMemcpyHostToDevice);
    cudaMemcpy(dB, B, sizeof B, cudaMemcpyHostToDevice);
    dim3 block(TILE, TILE), grid(N / TILE, N / TILE);
    matmul<<<grid, block>>>(dA, dB, dC, N);
    cudaMemcpy(C, dC, sizeof C, cudaMemcpyDeviceToHost);
    cudaFree(dA);
    cudaFree(dB);
    cudaFree(dC);

    int mismatches = 0;
    for (int r = 0; r < N; r++)
        for (int c = 0; c < N; c++) {
            float want = 0;
            for (int k = 0; k < N; k++) want += A[r * N + k] * B[k * N + c];
            mismatches += C[r * N + c] != want;
        }
    printf("C[0][1] = %g, C[127][127] = %g\n", C[1], C[N * N - 1]);
    printf("mismatches: %d\n", mismatches);
    return 0;
}
