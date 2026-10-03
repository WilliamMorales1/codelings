> **Imported from [github.com/furkan/dockerlings](https://github.com/furkan/dockerlings)** by Furkan Aldemir, under the MIT license (see [LICENSE](LICENSE)).
> Changes in this copy: runner gained the shared verbs (`verify`, `watch`, `hint`, `list`, ...). All credit for the course itself goes to the original authors.

# Dockerlings
**Learn Docker by doing – the fun, interactive way**

> Need help with Docker?
> 
> I help teams containerize applications, improve development environments and CI/CD pipelines, and troubleshoot Docker deployments.
Available for consulting and training → furkanaldemir@gmail.com

---

[![asciicast](https://asciinema.org/a/758902.svg)](https://asciinema.org/a/758902)

---

- **100% interactive TUI** – Beautiful terminal interface powered by Bubble Tea  
- **Instant verification** – Run `check` and know immediately if you're right  
- **Progressive curriculum** – 15+ carefully crafted exercises that build on each other  
- **Real-world skills** – From basic images to multi-stage builds, volumes, networks, and Compose  
- **Zero friction** – Just clone, build, and start learning

---

## What you'll master

| Exercise     | You’ll learn                                                                 |
|--------------|-------------------------------------------------------------------------------|
| core-01–04   | Running containers, logs, exec, file operations                              |
| core-05–07   | Writing Dockerfiles, COPY, EXPOSE, ENV, LABEL                                |
| core-08–09   | Persistent volumes & live-reloading bind mounts                              |
| core-10–11   | Container networking and port publishing                                     |
| core-12–14   | Docker Compose, multi-service apps, named volumes, custom networks          |
| core-15      | Multi-stage builds for tiny, secure production images                        |

## Get started in 30 seconds

> You need [go](https://go.dev/doc/install) and [docker](https://docs.docker.com/engine/install/) installed.

```bash
git clone https://github.com/furkan/dockerlings.git
cd dockerlings
go build -o bin/dockerlings$(go env GOEXE) ./cmd/dockerlings
./bin/dockerlings$(go env GOEXE) watch
```

Use ↑↓ to navigate • c to check your solution • h for hints • o to open the file in `$EDITOR` • q to quit

`watch` re-checks the selected exercise every time you save one of its files, and shows the
check script's output when it fails.

## Commands

```
dockerlings [verify]     check unfinished exercises in order, stop at the first failure (default)
dockerlings watch        interactive TUI that re-checks on save
dockerlings run [ID]     check one exercise (default: the next unfinished one); alias: check
dockerlings hint [ID]    print an exercise's hint
dockerlings list         every exercise, DONE/PENDING/LOCKED, and the file to edit
dockerlings reset ID     restore an exercise's files from .templates/ and forget its progress
dockerlings doctor       bash, curl, docker, the daemon and the compose plugin
```

`ID` is an exercise id such as `core-03`. File paths are printed as clickable OSC 8 links;
`NO_COLOR=1` turns colours and links off. dockerlings finds the repository from any subdirectory,
so `go install ./cmd/dockerlings` works too.

## Test a solution manually (optional)

```bash
cd exercises/core-01
bash check.sh   # see detailed feedback
```

## Made for

- Beginners who want to understand Docker commands
- Intermediate devs preparing for real-world container workflows
- Anyone who learns best by breaking and fixing things
