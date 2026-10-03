> **Imported from [github.com/rust-lang/rustlings](https://github.com/rust-lang/rustlings)** by Carol Nichols and the rustlings contributors, under the MIT license (see [LICENSE](LICENSE)).
> This folder is what `rustlings init` (v6.5.0) generates. All credit for the course itself goes to the original authors.

# rustlings

Small exercises to get you used to reading and writing **Rust**, including reading and
responding to compiler messages. The original -lings: every other course here copies it.

## Setup

Install Rust with [rustup](https://rustup.rs), then the rustlings runner:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh   # or: brew install rustup / your package manager's rustup
cargo install rustlings@6.5.0 --locked
```

The exercises here match v6.5.0, so pin that version.

## Usage

```sh
cd rustlings
rustlings              # watch mode: re-checks on save, press h for a hint, l for the list
rustlings run [NAME]   # one exercise
rustlings hint [NAME]
rustlings reset NAME
```

Once you solve an exercise, its official solution appears in `solutions/`.
Rustlings keeps its own runner, so its commands differ slightly from the other courses.
For more, see the [rustlings website](https://rustlings.rust-lang.org).
