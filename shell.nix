{
  pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixos-24.11.tar.gz") {} 
}: 

let 
  pkgs_rl = import (fetchTarball "https://github.com/ryansname/nix/archive/3b7e5fe.tar.gz") { inherit pkgs; };
  zig_ver = "0.14.0-dev.2371+c013f45ad";
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

    (pkgs_rl.zig { version = zig_ver; })
    (pkgs_rl.zls { version = "532cc25"; srcHash = "sha256-i33Ez/uYy6VzhByudLOUlNTMmqb+T+gu5m0nEyMr7wA="; zigVersion = zig_ver; })
  ];
}
