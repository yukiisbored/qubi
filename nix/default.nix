{ sources ? import ./sources.nix }:

let
  pkgs = import sources.nixpkgs {};

  shell = pkgs.mkShell {
    buildInputs = with pkgs; [
      nim
      nimlsp
      emscripten
    ];
  };
in
{
  inherit shell;
}
