> **Imported from [github.com/sergiotapia/nimlings](https://github.com/sergiotapia/nimlings)** by Sergio Tapia, under the MIT license (see [LICENSE](LICENSE)).
> Changes in this copy: exercises moved to `exercises/`, solutions added, runner gained the shared verbs. All credit for the course itself goes to the original authors.

# Nimlings

Learn the Nim programming language by fixing broken programs.

The current Nim documentation is in depth and comprehensive, but for newcomers it's a bit 
suffocating and hard to know where you need to go next.

It's my sincere hope that this project gets more people interested in Nim!

### Goals

- Learn how to read and write Nim by fixing tiny programs.
- Real life Nim situations you'll see in normal day to day Nim work.
- Covers the 80% of Nim you'll see the majority of the time. 
  - If you need to learn the other 20%, we'll provide good sources to dive deep.

### Exercises

- [x] Hello world
- [x] Assignments
- [x] If conditionals
- [x] Strings
### Usage Guide

You only need to have Nim 1.4.4 and Nimble installed to run all the Nimlings.

Use `nimble run` in the terminal to run all your exercises. Exercises are
run sequentially and if one fails the others are halted. Give it a try.

Each exercise lives in `exercises/`: fix the program and save, and as soon as it
runs without failing it is marked done and nimlings moves on. Passes are
remembered in `.nimlings-progress` until you edit the file again. Pass a verb after the binary
name (`nimble run nimlings watch`), or `nimble build` once and call `./nimlings`:

```
nimlings [verify]        check exercises in order, stop at the first unsolved one (default)
nimlings watch           the same, re-checked every time you save
nimlings run [NAME]      one exercise (default: the next unsolved one)
nimlings hint [NAME]     the exercise's opening comment
nimlings list            every exercise, DONE/PENDING, and its file
nimlings solution NAME   the reference solution from solutions/
nimlings reset NAME      restore an exercise from .templates/
nimlings doctor          nim and nimble
```

`NAME` can be the file name without `.nim` or just its tail (`assignments`).
File paths are printed as clickable OSC 8 links; `NO_COLOR=1` turns colours and
links off.

Failure is the goal here, by failing and fixing the programs you will learn
how Nim works and how to leverage `nimble` to run your projects.

### Community

Want to talk about Nim or Nimlings? Join the official Nim discord server.

[Click to join our official Discord server](https://discord.gg/bjNXRC3jZF)

### Development

You need at least Nim 1.4.4

### Thank you's:

- rustlings for the direct inspiration!