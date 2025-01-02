{
  description = "rbpatt2019's shared github workflows'";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      nixpkgs,
      treefmt-nix,
      self,
      ...
    }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux" # Most other systems
        "aarch64-linux" # Raspberry Pi 4
        "aarch64-darwin" # Apple Silicon
      ];
      get_pkgs = system: nixpkgs.legacyPackages.${system};
    in
    {
      formatter = forAllSystems (
        system:
        let
          pkgs = get_pkgs system;
          treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        treefmtEval.config.build.wrapper
      );
      # These only run with `nix flake check` if they are here, and not imported
      checks = forAllSystems (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
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
            actionlint.enable = true;
            yamllint.enable = true;
            flake-checker.enable = true;
            treefmt_custom = {
              # running treefmt integrated requires a toml
              enable = true;
              name = "treefmt";
              entry = "nix fmt";
              pass_filenames = true;
            };
          };
        };
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = get_pkgs system;
          precommit = self.checks.${system}.pre-commit-check;
        in
        import ./shell.nix { inherit pkgs precommit; }
      );
    };
}
