{
  description = "rbpatt2019's shared github workflows'";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        ...
      }:
      {
        imports = [
          inputs.treefmt-nix.flakeModule
          inputs.git-hooks-nix.flakeModule
        ];
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
        perSystem =
          { config, ... }:
          {
            treefmt = {
              flakeCheck = true;
              flakeFormatter = true;
              programs = {
                actionlint.enable = true;
                nixfmt.enable = true;
                statix.enable = true;
                deadnix.enable = true;
                rstfmt.enable = true;
                yamlfmt.enable = true;
              };
            };
            pre-commit.settings.hooks = {
              check-added-large-files.enable = true;
              check-merge-conflicts.enable = true;
              end-of-file-fixer.enable = true;
              mixed-line-endings.enable = true;
              trim-trailing-whitespace.enable = true;
              forbid-submodules = {
                enable = true;
                name = "Forbid git submodules";
                description = "Forbids all git submodules in current dir.";
                language = "fail";
                entry = "Git submodules are not allowed here: ";
                types = [ "directory" ];
              };
              treefmt.enable = true;
              flake-checker.enable = true;
            };
            devShells.default = config.pre-commit.devShell;
          };
      }
    );

}
