# systemdlings

Small exercises to get you used to reading and writing **systemd units**:
services, dependencies, timers, the journal, sandboxing, sockets, path units
and drop-ins.

Shamelessly modelled on [rustlings](https://github.com/rust-lang/rustlings).
Every exercise is a directory of unit files (sometimes with a script) that
does not do what it should yet. You fix it and save; once the check passes
the exercise is done and the runner moves you to the next one.

Checks do not just parse your files. They load them into your own **user
manager** (`systemctl --user`), start them, and read back what happened with
`systemctl --user show` and `journalctl --user`. Where no unit has to run
(calendar expressions, `[Install]`, security scores), they use the offline
tools: `systemd-analyze calendar`, `systemctl --root`, `systemd-analyze
security --offline=true`.

## What the checks touch (and what they never touch)

- Only units named `systemdlings-*`.
- Only the user manager. Nothing ever talks to the system manager, nothing
  needs sudo.
- Unit files are copied to `$XDG_RUNTIME_DIR/systemd/user/` (a tmpfs that is
  part of the user manager's search path, gone after logout/reboot), and the
  exercise directory to `$XDG_RUNTIME_DIR/systemdlings/<exercise>/` (that is
  `%t/systemdlings/<exercise>/` inside a unit). Nothing is written to
  `~/.config/systemd/user`.
- Every check stops, resets and removes what it installed when it ends, pass
  or fail. If a check is killed (timeout, Ctrl-C), the runner sweeps up
  after it; `systemdlings clean` removes any `systemdlings-*` leftovers by
  hand, and `systemdlings doctor` lists them.

## Setup

**Linux with systemd only** (Arch, Debian/Ubuntu, Fedora and most others).
The checks also want `jq`, and the runner needs Go 1.27+:

```sh
sudo pacman -S jq go             # Arch
sudo apt install jq golang       # Debian/Ubuntu
sudo dnf install jq golang       # Fedora
```

If your package manager's Go is older than 1.27, get it from [go.dev/dl](https://go.dev/dl/).

You need a running user manager, which you have in any normal login
session (`systemctl --user is-system-running` says `running` or
`degraded`). Build the runner:

```sh
git clone https://github.com/WilliamMorales1/codelings
cd codelings/systemdlings
go build -o systemdlings .
./systemdlings doctor
```

The sandboxing chapter uses unprivileged user namespaces and, for
`MemoryMax=`/`CPUQuota=`, the memory and cpu cgroup controllers delegated to
`user@.service`. Both are the default on current distros, except that Ubuntu
24.04+ blocks user namespaces through AppArmor (allow them with
`sudo sysctl kernel.apparmor_restrict_unprivileged_userns=0`). Check the
controllers with
`cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/cgroup.controllers`.

## Usage

```sh
./systemdlings watch          # the main loop: re-checks every time you save
./systemdlings                # check once, stop at the first unsolved exercise
./systemdlings list           # every exercise and its status
./systemdlings run units3     # check one exercise by name
./systemdlings hint units3    # print its hint
./systemdlings solution units3
./systemdlings reset units3   # back to the original, unsolved files
./systemdlings doctor         # tools, user manager, leftover units
./systemdlings clean          # stop and remove leftover systemdlings-* units
```

In fish, put the runner on your `PATH` for the session:

```sh
set -gx PATH $PWD $PATH
systemdlings watch 03         # only chapter 03
```

Open a second terminal with `systemdlings watch` running, edit the file it
points at, and save. The `File:` line is an OSC 8 hyperlink (kitty, foot,
WezTerm, Ghostty, ...). `NO_COLOR=1` gives plain output.

Poking at a unit by hand while you work is encouraged; do it the same way the
checks do:

```sh
cp exercises/01_units/units3/systemdlings-ticker.service $XDG_RUNTIME_DIR/systemd/user/
systemctl --user daemon-reload
systemctl --user start systemdlings-ticker.service
systemctl --user status systemdlings-ticker.service
journalctl --user -u systemdlings-ticker.service -f
systemctl --user stop systemdlings-ticker.service
rm $XDG_RUNTIME_DIR/systemd/user/systemdlings-ticker.service && systemctl --user daemon-reload
```

## The exercises

| Chapter | What it covers |
| --- | --- |
| `00_intro` | the workflow, how checks install and remove units |
| `01_units` | `[Unit]`/`[Service]`/`[Install]`, `Type=oneshot` + `RemainAfterExit=`, `Type=exec`, `Type=notify` + `NotifyAccess=`, user-manager targets |
| `02_lifecycle` | `Restart=on-failure` + `RestartSec=`, `StartLimitBurst=`/`StartLimitIntervalSec=`, `ExecStartPre=` and the `-` prefix, `SuccessExitStatus=`, `ExecStop=` vs `ExecStopPost=`, `KillSignal=` |
| `03_dependencies` | `Wants=` vs `After=`, `Requires=`, custom targets, `PartOf=`, `BindsTo=` |
| `04_environment` | `Environment=` quoting, `EnvironmentFile=`, `WorkingDirectory=`, templates and `%i`, `systemd-escape` with `%I`/`%f` |
| `05_timers` | `OnCalendar=` syntax (not cron), several schedules and `~`, `Unit=`, `Persistent=` + `RandomizedDelaySec=`, `OnActiveSec=`/`OnUnitActiveSec=`, transient timers with `systemd-run --user` |
| `06_journal` | `SyslogIdentifier=` and `-t`, `<N>` priority prefixes, `-o json` + jq, `StandardOutput=`/`StandardError=`, `systemd-cat` |
| `07_sandboxing` | `ProtectSystem=strict` + `ReadWritePaths=`, `ProtectHome=`, `PrivateTmp=`, `systemd-analyze security` scores, `MemoryMax=`/`MemorySwapMax=`/`CPUQuota=`, `PrivateNetwork=` |
| `08_socket_path` | socket activation with `Accept=yes` and `StandardInput=socket`, socket/template naming, `.path` units with `DirectoryNotEmpty=`, drop-ins that reset `ExecStart=`, drop-in ordering |

44 exercises. A full check of one exercise takes one to ten seconds, since the
timer and restart exercises have to wait for real events.

### Notes on the user manager

Most of `systemd.exec(5)` works in `systemctl --user` units, via user
namespaces: `ProtectSystem=`, `ProtectHome=`, `PrivateTmp=`,
`PrivateNetwork=`, `PrivateDevices=`, `NoNewPrivileges=`, `SystemCallFilter=`,
`MemoryMax=`, `CPUQuota=` all behave as documented. Things that do not:
`User=`/`Group=` (you cannot become someone else), capabilities you never
had, and journald-side per-unit settings: `LogLevelMax=` and
`LogExtraFields=` in a user unit only affect the manager's own messages about
the unit, not the service's output (found while building this course,
systemd 262). Remember also that `ProtectHome=` hides `/run/user`, so `%t`
too, and that a line printed by a short-lived child process can lose its
`_SYSTEMD_USER_UNIT` field and slip past `journalctl -u` (use
`SyslogIdentifier=` and `-t`).

## Layout

```
exercises/      the unit files you edit, one directory per exercise
solutions/      one reference solution per exercise
.templates/     pristine copies, used by `systemdlings reset`
checks/         one bash check per exercise (the spec), plus lib.sh with the
                shared install/start/journal/cleanup helpers
*.go            the runner (Go standard library only)
scripts/        verify-all.sh: every solution passes, every exercise fails
```

## Adding an exercise

1. Create `exercises/NN_chapter/name/` with the unit file(s). Every unit is
   named `systemdlings-*`; `install_units` refuses anything else. Put a
   header comment (title, concept, task) in the file the learner should
   open first. The exercise must fail its check as shipped.
2. Put the fixed version in `solutions/NN_chapter/name/` and copy the
   exercise to `.templates/NN_chapter/name/`.
3. Write `checks/NN_chapter/name.sh`: a `# REQUIRES:` line (tools, plus the
   pseudo-tool `user-manager` if it starts units), a `# HINT` comment block,
   then `source "$SYSTEMDLINGS_LIB"` and the helpers: `install_units`,
   `verify_units`, `start_ok`, `expect_prop`, `mark` + `wait_log`,
   `track` for anything started indirectly. Never call `systemctl` without
   `--user` (use `sctl`).
4. Run `scripts/verify-all.sh` (optionally with a chapter prefix). It checks
   that the solution passes, the stripped exercise fails, and that no
   `systemdlings-*` unit was left behind.

## Other ways to learn systemd

- [systemd.io](https://systemd.io/) - design notes and specs from upstream
- `man systemd.unit`, `man systemd.service`, `man systemd.exec`,
  `man systemd.timer`, `man systemd.time`, `man systemd.socket`,
  `man systemd.path`, `man systemd.resource-control`, `man systemd.special`
- [ArchWiki: systemd](https://wiki.archlinux.org/title/Systemd),
  [systemd/User](https://wiki.archlinux.org/title/Systemd/User),
  [systemd/Timers](https://wiki.archlinux.org/title/Systemd/Timers),
  [systemd/Journal](https://wiki.archlinux.org/title/Systemd/Journal)
- Lennart Poettering's "systemd for Administrators" blog series (old, still
  the best explanation of why things are the way they are)
