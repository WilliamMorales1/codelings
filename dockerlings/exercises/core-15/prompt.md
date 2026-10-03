Directory: exercises/core-15

When you build a compiled application (like Go, Rust, or C++), your `Dockerfile` often needs a full SDK with compilers and build tools. However, the final container only needs the compiled binary to run. Including the entire SDK in your final image makes it unnecessarily large and increases its security attack surface.

**Multi-stage builds** solve this problem elegantly. You use one stage (e.g., `FROM golang AS builder`) to compile your code, and a second, separate stage (e.g., `FROM scratch`) to create the final, minimal image, copying *only* the compiled binary from the first stage.

## Your Task

In this directory, you will find a simple Go web application and a `Dockerfile` that builds it using a single stage.

Your task is to **refactor the `Dockerfile`** to use a multi-stage build.

1.  **The first stage** (the "builder"):
    *   Should start from a `golang` image (e.g., `golang:1.21-alpine`).
    *   Should build the Go application binary.

2.  **The second stage** (the "final" image):
    *   Should start from a minimal base image like `scratch` or `alpine`.
    *   Should copy the compiled binary from the builder stage into the final image.
    *   Should set the `CMD` to run the application.

The verification script will build your `Dockerfile` and check two things: that the resulting image is significantly smaller than the original single-stage build, and that the application inside it still runs correctly.
