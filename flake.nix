{
  description = "rbpatt2019's shared github workflows'";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    devenv.url = "github:cachix/devenv";
  };

  outputs =
    inputs@{
      nixpkgs,
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
          inputs.devenv.flakeModule
        ];
        systems = nixpkgs.lib.systems.flakeExposed;
        perSystem =
          { config, pkgs, ... }:
          {
            devShells.default = pkgs.mkShell {
              shellHook = ''
                ${config.pre-commit.installationScript}
                echo 1>&2 "Welcome to the development shell!"
              '';
            };
            pre-commit = {
              check.enable = false; # All non-trivial checks handled by treefmt
              settings.hooks = {
                check-added-large-files.enable = true;
                trim-trailing-whitespace.enable = true;
                end-of-file-fixer.enable = true;
                treefmt = {
                  enable = true;
                  verbose = true;
                  settings.formatters = [
                    pkgs.actionlint
                    pkgs.nixfmt-pkgs
                    pkgs.deadnix
                    pkgs.statix
                    pkgs.rstfmt
                    pkgs.yamlfmt
                  ];
                };
              };
            };
            treefmt = {
              programs = {
                actionlint.enable = true;
                nixfmt.enable = true;
                deadnix.enable = true;
                statix.enable = true;
                rstfmt.enable = true;
                yamlfmt.enable = true;
              };
            };
          };
      }
    );

}
