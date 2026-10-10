# cudalings

Small exercises to get you used to writing **CUDA**: kernels, the thread hierarchy, device
memory, shared memory, warps, and the classic parallel patterns (reduction, scan, tiled
matmul) that everything else is built from.

Every exercise is one `.cu` program that doesn't compile yet, prints the wrong answer, or
gets flagged by `compute-sanitizer`. You fix it and save. Once it builds, runs cleanly and
prints exactly the expected output, it is done and the runner moves you on.

You should know some C or C++ (pointers, arrays, `malloc`). No GPU experience needed.

## Setup

You need an **NVIDIA GPU** and the CUDA toolkit (`nvcc` and `compute-sanitizer`). The
`-arch=native` flag needs CUDA 11.6 or newer.

```sh
sudo pacman -S cuda                     # Arch (installs to /opt/cuda)
sudo apt install nvidia-cuda-toolkit    # Debian/Ubuntu (or NVIDIA's apt repo for a newer one)
sudo dnf install cuda                   # Fedora, after adding NVIDIA's CUDA repo
```

On Windows, use WSL 2 with NVIDIA's Windows driver and the WSL CUDA toolkit. macOS has no
CUDA. Then check:

```sh
./cudalings doctor
```

The runner adds `/usr/local/cuda/bin` and `/opt/cuda/bin` to its `PATH` by itself.

### No NVIDIA GPU? Use Google Colab

[Google Colab](https://colab.research.google.com) lends you a free NVIDIA T4 with the CUDA
toolkit and `compute-sanitizer` already installed, so the whole course runs there. Free GPU
time is limited and handed out as available; if you can't get a GPU, try again later.

Colab VMs are thrown away when you disconnect or sit idle, and your edits and progress go
with them. To keep your work, put the course in your Google Drive.

#### In the browser

1. Open a new notebook at [colab.research.google.com](https://colab.research.google.com).
2. **Runtime > Change runtime type > T4 GPU > Save.**
3. In the first cell, mount Drive and get the course. Run it again in later sessions: it
   skips the clone when the course is already there.

   ```python
   from google.colab import drive
   drive.mount('/content/drive')
   %cd /content/drive/MyDrive
   ![ -d codelings ] || git clone https://github.com/WilliamMorales1/codelings
   %cd codelings/cudalings
   !bash cudalings doctor
   ```

   (To try it without Drive, skip the first two lines and clone into `/content`. That copy
   is lost when the runtime goes away.)
4. In a second cell, the check you'll re-run after every edit:

   ```python
   !bash cudalings run
   ```

5. To edit an exercise, open the folder icon on the left and go to
   `drive/MyDrive/codelings/cudalings/exercises/`. Double-click a `.cu` file to open it
   in an editor pane. Save with Ctrl+S, then re-run the cell from step 4.

Other commands work the same way in a cell: `!bash cudalings hint`, `!bash cudalings list`,
`!bash cudalings solution memory3`, `!bash cudalings reset memory3`. Use `bash cudalings`
rather than `./cudalings` because Drive doesn't always keep the executable bit. `watch`
never ends on its own, so it would hold the cell forever: use `run`. If your Colab plan
has a **Terminal** (bottom left), you can `cd` to the course there and run
`bash cudalings watch` like on your own machine.

#### From your own terminal, with the colab CLI

The [`colab` CLI](https://pypi.org/project/google-colab-cli/) (`uv tool install
google-colab-cli`) rents the same VM from your shell and gives you a real terminal on it,
so `watch` works:

```sh
colab new -s cuda --gpu T4      # rent a T4 VM
colab console -s cuda           # interactive shell on the VM; in it:
#   git clone https://github.com/WilliamMorales1/codelings /content/codelings
#   cd /content/codelings/cudalings && ./cudalings watch
```

In a second local terminal, open an exercise in your `$EDITOR`. When you save and close the
editor, the file is uploaded back to the VM and `watch` picks it up:

```sh
colab edit -s cuda /content/codelings/cudalings/exercises/00_intro/intro1.cu
```

Run `colab stop -s cuda` when you're done. An idle VM keeps using your compute quota, and
whatever is under `/content` is deleted along with it.

## Usage

```
./cudalings watch [CHAPTER]  # the main loop: re-check on save, move on when it passes
./cudalings                  # the same, once (alias: verify)
./cudalings run [NAME]       # one exercise (default: the next unsolved one)
./cudalings hint [NAME]      # a nudge
./cudalings list             # every exercise, DONE/PENDING, and the file to edit
./cudalings solution NAME    # the reference solution
./cudalings reset NAME       # restore the exercise from .templates/
./cudalings doctor           # nvcc, compute-sanitizer and a GPU
```

`NAME` is `02_memory/memory3` or just `memory3`. Builds go to `.build/`. Passes are
remembered in `.cudalings-progress` until you edit the file again, so `list` is instant.
`File:` paths are clickable OSC 8 links; `NO_COLOR=1` turns colours and links off.
`CUDALINGS_ARCH=sm_75` overrides `-arch=native`.

Some exercises print the right answer even with the bug in place, because a race or an
out-of-bounds write happened not to show up this time. Their checks also run the program
under `compute-sanitizer` (`memcheck`, `initcheck` or `racecheck`), which catches the bug
anyway. The exercise's comment says when.

## The exercises

| Chapter | Covers |
|---|---|
| `00_intro` | launching a kernel, `__global__`, writing results through a pointer |
| `01_kernels` | `threadIdx`, `blockIdx`, `blockDim`, rounding the grid up, bounds checks, grid-stride loops, `__host__ __device__` |
| `02_memory` | `cudaMalloc`/`cudaMemcpy` and their directions, sizes in bytes, unified memory, `__constant__` |
| `03_errors` | launch errors, checking every call, async and sticky errors, timing with events |
| `04_grids` | 2D blocks and grids, row/column indexing, image kernels |
| `05_shared` | `__shared__` and `__syncthreads`, dynamic shared memory, halos, tiled transpose |
| `06_atomics` | `atomicAdd` for histograms and for claiming output slots |
| `07_warps` | `__shfl_down_sync`, `__ballot_sync` + `__popc`, `__shfl_sync` broadcast |
| `08_reduce` | shared-memory tree reduction, warp-then-block reduction, two-pass reduction |
| `09_scan` | Hillis-Steele inclusive scan, multi-block scan |
| `10_matmul` | naive and tiled matrix multiply |
| `11_streams` | launching into streams, pinned memory, overlapping chunks |

38 exercises.

## Layout

```
exercises/<chapter>/<name>.cu   what you edit
.templates/<chapter>/<name>.cu  pristine copy, used by `reset`
solutions/<chapter>/<name>.cu   reference solution
checks/<chapter>/<name>.check   hint, expected output and sanitizer; discovery is driven by these
include/cudalings.cuh           CUDA_CHECK and print_ints, shared by the exercises
scripts/verify-all.sh           every solution passes, every untouched exercise fails
cudalings                       the runner (bash)
```

## Adding an exercise

1. Write `solutions/<chapter>/<name>.cu`: a comment block (title, what you learn, the task),
   then a complete program whose output proves the kernel works (values, a mismatch count).
   Keep output deterministic: integers, or floats whose sums are exact.
2. Copy it to `exercises/` and `.templates/` and break it the way a real mistake would, or
   leave a clear `TODO`.
3. Write `checks/<chapter>/<name>.check`: an optional `#! sanitizer <tool>` line, a `# HINT`
   line followed by `#` lines, then the exact expected stdout.
4. Run `scripts/verify-all.sh` on a machine with a GPU.

## Other ways to learn CUDA

- [CUDA C++ Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide/), the reference
- [An Even Easier Introduction to CUDA](https://developer.nvidia.com/blog/even-easier-introduction-cuda/), NVIDIA's gentle start
- *Programming Massively Parallel Processors* by Hwu, Kirk and El Hajj, the textbook
- [GPU Puzzles](https://github.com/srush/GPU-Puzzles), the same ideas as puzzles in Python/Numba
- [LeetGPU](https://leetgpu.com), kernel challenges in the browser, no GPU needed
