{
  inputs,
  pkgs,
  lazyvim,
  ...
}:
{
  imports = [ lazyvim.homeManagerModules.default ];
  #https://github.com/pfassina/lazyvim-nix
  programs.lazyvim = {
    enable = true;

    # Add LSP servers and tools
    extraPackages = with pkgs; [
      rust-analyzer
      nodePackages.typescript-language-server
    ];

    # Add treesitter parsers
    treesitterParsers = with pkgs.tree-sitter-grammars; [
      tree-sitter-rust
      tree-sitter-typescript
      tree-sitter-tsx
    ];
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
