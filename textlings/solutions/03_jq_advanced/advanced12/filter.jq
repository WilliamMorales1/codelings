# advanced12: def
#
# `def name: body;` defines a filter; `def f(g): ...;` takes a filter
# argument, and definitions may recurse. Put them at the top of the file.
#
# lsblk.json is `lsblk --json --bytes -o NAME,SIZE,TYPE,MOUNTPOINTS`.
# Print every device, children included, as  name size mounts , where
# size is human-readable (1 decimal, truncated, binary units: B, K, M, G,
# T) and mounts is the comma-joined non-null mountpoints, or "-":
#     nvme0n1 476.9G -
#     nvme0n1p1 1G /boot
# `devices` is done for you; write `human`.

def human:
  if . < 1024 then "\(.)B"
  else
    [., 0] | until(.[0] < 1024 or .[1] == 4; [.[0] / 1024, .[1] + 1])
    | "\(.[0] * 10 | floor / 10)\("BKMGT"[.[1]:.[1] + 1])"
  end;

def devices: ., (.children[]? | devices);

.blockdevices[]
| devices
| "\(.name) \(.size | human) \(.mountpoints | map(values) | if length == 0 then "-" else join(",") end)"
