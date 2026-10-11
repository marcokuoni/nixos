# Development: containers and running non-Nix binaries.
{
  virtualisation.docker.enable = true;

  # run unpatched binaries (downloaded tools, language toolchains)
  programs.nix-ld.enable = true;

  # SSHFS mounts with the allow_other option
  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';
}
