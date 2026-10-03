A multi-stage build uses multiple `FROM` instructions. Each `FROM` starts a new build stage. You can name stages and copy artifacts from one stage to another.

Here is the basic structure:

```Dockerfile
# --- Build Stage ---
# Give the stage a name, like "builder"
FROM golang:1.21-alpine AS builder

# Set the working directory
WORKDIR /src

# Copy source and build the static binary
COPY app/ .
# CGO_ENABLED=0 creates a static binary that can run in a minimal image like 'scratch'
RUN CGO_ENABLED=0 go build -o /app/server .


# --- Final Stage ---
# Start a new, clean stage from a minimal base image
FROM scratch

# Copy *only* the compiled binary from the "builder" stage
COPY --from=builder /app/server /server

# Expose the application port
EXPOSE 8080

# Set the command to run the binary
CMD ["/server"]
```
Using `scratch` results in the smallest possible image, as it's completely empty. `alpine` is another great choice if you need a shell or other basic utilities.
