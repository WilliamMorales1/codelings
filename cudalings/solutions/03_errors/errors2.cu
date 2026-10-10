// errors2: check every call
//
// Every CUDA runtime call returns a cudaError_t. Ignoring it is how bugs hide: a
// failed cudaMalloc leaves your pointer as garbage and the crash shows up three
// calls later. cudaGetErrorString turns an error code into text.
//
// Task: implement `ok`. When `err` is cudaSuccess it prints nothing and returns
// true. Otherwise it prints "<what> failed: <error string>" and returns false.
// (include/cudalings.cuh has CUDA_CHECK, a macro that does the same and exits;
// later exercises use it.)
#include <cstdio>

bool ok(cudaError_t err, const char *what) {
    if (err == cudaSuccess) return true;
    printf("%s failed: %s\n", what, cudaGetErrorString(err));
    return false;
}

int main() {
    float *huge = nullptr, *small = nullptr;
    // 1 PiB: no GPU has that much memory.
    ok(cudaMalloc(&huge, (size_t)1 << 50), "cudaMalloc(huge)");
    if (ok(cudaMalloc(&small, 1024), "cudaMalloc(small)")) printf("small allocation ok\n");
    ok(cudaFree(small), "cudaFree(small)");
    printf("done\n");
    return 0;
}
