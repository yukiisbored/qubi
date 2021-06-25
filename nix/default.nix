{ sources ? import ./sources.nix }:

let
  pkgs = import sources.nixpkgs {};

  shell = pkgs.mkShell {
    buildInputs = with pkgs; [
      nim
      emscripten
      git

      xorg.libX11
      xorg.libXrandr
      xorg.libXinerama
      xorg.libXcursor
      xorg.libXi
      xorg.libXext

      nimlsp
    ];

    shellHook = ''
      export EM_CACHE="$HOME/.cache/emscripten"
      '';
  };
in
{
  inherit shell;
}
