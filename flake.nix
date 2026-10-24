{
  description = "NaviBeat Linux music player";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};

    version = "1.0.45";

    src = pkgs.fetchurl {
      url = "https://github.com/nenadjokic/navibeat-linux/releases/download/v${version}/NaviBeat-linux-x86_64.AppImage";

      hash = "sha256-1swVK8nroUSzdZ/dWEmXEDKf8YMP25iJvdA9rT/S1Fw=";
    };

    appimageContents = pkgs.appimageTools.extract {
      pname = "navibeat";
      inherit version src;
    };
  in {
    packages.${system}.default = pkgs.appimageTools.wrapType2 {
      pname = "navibeat";
      inherit version src;

      extraPkgs = p:
        with p; [
          alsa-lib
          libpulseaudio
          stdenv.cc.cc.lib
        ];

      extraInstallCommands = ''
        if [ -d ${appimageContents} ]; then
          install -Dm444 \
            ${appimageContents}/navibeat.desktop \
            $out/share/applications/navibeat.desktop \
            2>/dev/null || true
        fi
      '';
    };

    apps.${system}.default = {
      type = "app";
      program = "${self.packages.${system}.default}/bin/navibeat";
    };
  };
}
