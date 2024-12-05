{
  pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixos-24.11.tar.gz") {} 
}: 

let 
  pkgs_rl = import (fetchTarball "https://github.com/ryansname/nix/archive/7a9407e.tar.gz") { inherit pkgs; };
in
pkgs.mkShell {
  nativeBuildInputs = [
  ];
  
  buildInputs = [
    pkgs.entr
  
    pkgs.git
    pkgs.go
    pkgs.gopls
    pkgs.golangci-lint
    pkgs.golangci-lint-langserver

    pkgs_rl.zig
    pkgs_rl.zls
  ];
}
