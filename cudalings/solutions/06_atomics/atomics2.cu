// atomics2: claiming a slot
//
// atomicAdd returns the value from *before* the add. That makes it a way to hand
// out unique indices: a thread that wants to append to an output array claims
// slot atomicAdd(&count, 1), and nobody else will get that slot.
//
// Task: keep only the multiples of 7, packed at the front of `out` (in any
// order). Right now two threads can read the same `count` and overwrite each
// other.
#include <algorithm>
#include <cstdio>

__global__ void keep_multiples_of_7(const int *in, int *out, int *count, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n && in[i] % 7 == 0) {
        int slot = atomicAdd(count, 1);
        out[slot] = in[i];
    }
}

int main() {
    const int n = 10000;
    static int in[n], out[n];
    for (int i = 0; i < n; i++) in[i] = i;

    int *d_in, *d_out, *d_count;
    cudaMalloc(&d_in, sizeof in);
    cudaMalloc(&d_out, sizeof out);
    cudaMalloc(&d_count, sizeof(int));
    cudaMemcpy(d_in, in, sizeof in, cudaMemcpyHostToDevice);
    cudaMemset(d_count, 0, sizeof(int));
    keep_multiples_of_7<<<(n + 255) / 256, 256>>>(d_in, d_out, d_count, n);
    int count = 0;
    cudaMemcpy(&count, d_count, sizeof count, cudaMemcpyDeviceToHost);
    cudaMemcpy(out, d_out, sizeof out, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);
    cudaFree(d_count);

    std::sort(out, out + count);
    bool correct = count == (n + 6) / 7;
    for (int k = 0; correct && k < count; k++) correct = out[k] == 7 * k;
    printf("kept: %d\n", count);
    printf("all multiples of 7, each once: %s\n", correct ? "yes" : "no");
    return 0;
}
