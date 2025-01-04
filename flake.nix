{
  description = "Development environment with Talos, Cilium, and kubectl";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            talos
            cilium-cli
            kubectl
          ];

          shellHook = ''
            echo "Kubernetes tools environment loaded!"
            echo "Available tools:"
            echo "- talos ($(talos version))"
            echo "- cilium ($(cilium version))"
            echo "- kubectl ($(kubectl version --client))"
          '';
        };
      });
}
