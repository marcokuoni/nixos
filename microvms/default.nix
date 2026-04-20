#
# /etc/nixos/microvms.nix  (example path — put this wherever you keep system config)
#
# One place on the host to register every project microVM you care about.
# Adding a new project is a single entry in the `vms` list below.
#
# Import this module from your configuration.nix, e.g.:
#
#     imports = [
#       ./hardware-configuration.nix
#       ./microvms.nix
#     ];
#
# Then once per system change:
#
#     sudo nixos-rebuild switch
#
# After that, lifecycle is managed by systemd:
#
#     systemctl start  microvm@innovationsbox
#     systemctl stop   microvm@innovationsbox
#     journalctl -u microvm@innovationsbox -f
#
# systemd takes care of virtiofsd + qemu + ordering, survives host reboots,
# restarts on crash, and captures the console to the journal.
#
{ config, lib, pkgs, inputs, ... }:

let
  # ───────────────────────────────────────────────────────────────────────
  #  Register your project microVMs here.
  #  Key   = VM name; must match PROJECT_NAME in that project's .env.
  #  Value = absolute path to the project checkout on disk.
  # ───────────────────────────────────────────────────────────────────────
  vms = {
    innovationsbox = "/home/progressio/lemonbrain/git/concrete_microvm";

    # Add more projects like this:
    # anotherproject = "/home/progressio/lemonbrain/git/anotherproject";
  };
in
{
  # Pull in the microvm.nix host module from the flake input.
  # Make sure your flake.nix exposes `microvm` as an input and passes it
  # through specialArgs (see README-host.md for the 3-line addition).
  imports = [ inputs.microvm.nixosModules.host ];

  # Declaratively register each VM.  `flake` points at the project's own
  # flake, and `updateFlake` enables `microvm -u <name>` for in-place
  # update.  The `--impure` dance is still required because project flakes
  # read .env from disk; the host module will pass impure down via
  # extraArgs below.
  microvm = {
    autostart = [];   # nothing auto-starts on host boot; set to the names you want always-on
    vms = lib.mapAttrs (name: path: {
      # `flake` expects an evaluated flake (attrset with `.nixosConfigurations`,
      # etc.).  `builtins.getFlake` loads it; requires --impure on the host
      # rebuild because `path:...` refs depend on disk state.
      flake = builtins.getFlake "path:${path}";
    }) vms;
  };

  # No Environment= override on microvm@.service: the `--impure` requirement
  # only applies to the host `nixos-rebuild` invocation, not the microvm build
  # that systemd kicks off (the flake is already resolved to a store path by
  # the time we get there).
}
