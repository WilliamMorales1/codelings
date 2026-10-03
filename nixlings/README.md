> **Imported from [github.com/spacekookie/nixlings](https://github.com/spacekookie/nixlings)** by spacekookie, under the CC BY-SA 4.0 license (see [LICENSE](LICENSE)).
> Changes in this copy: new `./nixlings` runner, checks in `checks/`, solutions in `solutions/`. All credit for the course itself goes to the original authors.

![](./logo.png)

❄️💙 **Greetings and welcome to nixlings.**

This project contains small exercises to get you used to reading and
writing Nix code.  This includes reading and responding to error
messages from the Nix daemon.


## Running the exercises

The exercises live in `exercises/<chapter>/`, ordered by file name. Fix a file
and save: as soon as its check passes, it is done and the runner moves on.
Every exercise is checked by `checks/<chapter>/<name>.nix`, a function from the
imported exercise to `true`.

```
./nixlings watch [CHAPTER]   re-check every time you save, stop at the first unsolved exercise
./nixlings [verify]          the same, once
./nixlings run [NAME]        one exercise (default: the next unsolved one)
./nixlings hint [NAME]       a hint for an exercise
./nixlings list              every exercise, DONE/PENDING, and its file
./nixlings solution NAME     the reference solution from solutions/
./nixlings reset NAME        restore an exercise from .templates/
./nixlings doctor            nix, and the <nixpkgs> channel the 03_map chapter imports
```

`NAME` is `chapter/name` (`02_functions/1_argument`) or just the file name
(`1_argument`). File paths are printed as clickable OSC 8 links; `NO_COLOR=1`
turns colours and links off.

The runner only needs `nix-instantiate`, so no experimental features have to be
enabled. To poke at an exercise by hand:

```
$ nix-instantiate --eval --strict exercises/01_attrsets/0_basic.nix -A output
```

Install Nix on any Linux or macOS with the [official installer](https://nixos.org/download/)
(`sh <(curl -L https://nixos.org/nix/install) --daemon`), then add a nixpkgs channel for chapter 03.
On Arch you can instead `sudo pacman -S nix`, `sudo systemctl enable --now nix-daemon.socket`
and add yourself to `nix-users`.
`scripts/verify-all.sh` checks that every solution passes and every untouched
exercise fails.

If you have any questions, feel free to open an issue :)


## Excercise order

Some of the excercises are harder than others.  Generally excercises
can be done in any order, but if you're new, the following order is
recommended:

1. 01_attrsets
2. 02_functions
3. 03_map
