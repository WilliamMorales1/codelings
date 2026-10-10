// matmul1: naive matrix multiply
//
// C = A * B for N x N row-major matrices. C[row][col] is the dot product of row
// `row` of A with column `col` of B. One thread computes one element of C.
//
// Task: the kernel walks along a row of B instead of down a column. Fix the
// index into B.
#include <cstdio>

__global__ void matmul(const float *A, const float *B, float *C, int N) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    if (row >= N || col >= N) return;
    float acc = 0.0f;
    for (int k = 0; k < N; k++) acc += A[row * N + k] * B[k * N + col];
    C[row * N + col] = acc;
}

int main() {
    const int N = 64;
    static float A[N * N], B[N * N], C[N * N];
    // Small integers keep every float sum exact, so the CPU and GPU agree bit for bit.
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
    dim3 block(16, 16), grid(N / 16, N / 16);
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
    printf("C[0][1] = %g, C[63][63] = %g\n", C[1], C[N * N - 1]);
    printf("mismatches: %d\n", mismatches);
    return 0;
}
