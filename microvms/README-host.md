# Host-side microVM management (Option A)

Register every project microVM in one place on your NixOS host so systemd
manages their lifecycle — `systemctl start/stop/status`, auto-restart on
crash, optional boot with the host, console in `journalctl`.

With this setup, the `vm_build.sh` / `vm_destroy.sh` scripts become
optional — you can keep using them for a single-project workflow, or call
`systemctl` directly.

## One-time setup

Your NixOS host is probably configured as a flake in `/etc/nixos/` (or
wherever). If it isn't yet — if you're on a classic
`/etc/nixos/configuration.nix` without `flake.nix` — either switch your
host to flakes first, or use Option B (the `vm_build.sh` scripts in this
repo) and ignore this file.

### 1. Add `microvm` as a flake input on the host

In your host `/etc/nixos/flake.nix` (not the project flake!), add:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # NEW:
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, microvm, ... }@inputs: {
    nixosConfigurations.<your-host-name> = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # NEW: forward all flake inputs to modules so they can `inputs.microvm.…`
      specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix
        # (your other modules)
      ];
    };
  };
}
```

The two new pieces are: `microvm` in `inputs`, and
`specialArgs = { inherit inputs; }` passed to `nixosSystem`.

### 2. Drop `microvms.nix` into `/etc/nixos/`

Copy `host/microvms.nix` from this repo somewhere your host config can see
it — typically next to `configuration.nix`:

```bash
sudo cp host/microvms.nix /etc/nixos/microvms.nix
```

### 3. Import it from `configuration.nix`

```nix
{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./microvms.nix            # <── add this line
  ];

  # … rest of your config …
}
```

### 4. Register your projects in `microvms.nix`

Edit the `vms` attrset at the top of the file:

```nix
vms = {
  innovationsbox = "/home/you/lemonbrain/git/concrete_microvm";
  anotherproject = "/home/you/lemonbrain/git/anotherproject";
};
```

The attribute name **must** match that project's `PROJECT_NAME` in
`.env` — the project flake names its `nixosConfigurations` entry after
it.

### 5. Rebuild the host (with --impure)

```bash
sudo nixos-rebuild switch --flake '.#laptop' --impure
```

`--impure` is required because project flakes load `.env` at eval
time via `builtins.getFlake "path:…"`. If you forget the flag, you get
a cryptic error about `builtins.getFlake` not being callable in a pure
context.  To avoid typing it every time, alias it in your shell:

```bash
alias nrs='sudo nixos-rebuild switch --flake .#laptop --impure'
```

You should now see systemd services:

```bash
systemctl list-units 'microvm@*'
```

## Daily use

Once the host module is installed, `make vm_build` / `make vm_destroy` in
any project auto-detect the systemd backend and delegate to it — no
change to your workflow. Under the hood:

```bash
make vm_build      # → sudo systemctl start microvm@innovationsbox
make vm_destroy    # → sudo systemctl stop  microvm@innovationsbox
```

Or run systemctl directly if you prefer:

```bash
sudo systemctl start   microvm@innovationsbox
sudo systemctl stop    microvm@innovationsbox
sudo systemctl status  microvm@innovationsbox
journalctl -u          microvm@innovationsbox -f   # live console

# After editing the project's flake.nix / vm/configuration.nix:
sudo systemctl restart microvm@innovationsbox      # rebuild + restart
```

**Force the standalone backend** (run `microvm-run` out-of-tree, e.g. on
a machine where you don't want to touch `/etc/nixos`):

```bash
VM_BACKEND=standalone make vm_build
```

If you want the VM to come up automatically when the host boots, add its
name to `autostart` in `microvms.nix`:

```nix
autostart = [ "innovationsbox" ];
```

## Adding a new project

1. Clone the project, drop the overlay on top, fill in `.env`.
2. Add one line to the `vms` list in `/etc/nixos/microvms.nix`.
3. `sudo nixos-rebuild switch`
4. `sudo systemctl start microvm@<newproject>`

No per-project host config. No virtiofsd juggling. `systemctl` is the
only verb.

## Troubleshooting

**`nixos-rebuild` complains about `--impure`.** Project flakes read `.env`
at eval time, so their builds need `--impure`. The `Environment=` line in
`microvms.nix` forwards this through. If you hit a specific flake that
refuses to evaluate, run `sudo nixos-rebuild switch --impure` once —
subsequent builds are cached.

**`systemctl start` fails immediately.** `journalctl -u microvm@<name> -n
100` shows the failure reason. Typical causes: the `path` in
`microvms.nix` doesn't exist, `name` doesn't match `PROJECT_NAME`, or the
project flake has a Nix eval error unrelated to microvm.nix — `cd` into
the project and run `./dev` to reproduce.

**The VM boots but shares are empty.** systemd's microvm@ service runs as
root; virtiofs shares need to be readable by the UIDs inside the VM. For
your project this is already handled (dev user in the guest = uid 1000,
files on host owned by your user = uid 1000, they line up).

**You want to keep the `vm_build.sh` workflow too.** They're not mutually
exclusive — but don't run both at once for the same project, or they'll
fight over ports and socket files. If systemd is managing the VM, use
`systemctl` and leave `make vm_build` alone; if not, `vm_build.sh` still
works fine standalone.
