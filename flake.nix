{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Rust
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
          overlays = [inputs.rust-overlay.overlays.default];
        };

        buildToolsVersion = "34.0.0";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [buildToolsVersion "28.0.3"];
          platformVersions = ["34" "28"];
          abiVersions = ["armeabi-v7a" "arm64-v8a"];
        };
        androidSdk = androidComposition.androidsdk;

        packages.default = pkgs.callPackage ./package.nix {};

        devShells.default =
          pkgs.mkShell
          {
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";

            buildInputs = with pkgs; [
              flutter
              androidSdk # The customized SDK that we've made above
              jdk17

              pkg-config
              libarchive.dev
              openssl.dev
              libxml2.dev
              libepoxy.dev
              xorg.libXtst
              libsysprof-capture
              sqlite.dev
              libpsl.dev
              nghttp2.dev
              libepoxy
              pcre2
              gtk3

              util-linux
              libselinux
              libsepol
              libthai
              libdatrie
              xorg.libXdmcp
              lerc
              libxkbcommon
              cmake
              mpv
              libass
              mimalloc
              ffmpeg
              libplacebo
              libunwind
              shaderc
              vulkan-loader
              lcms
              libdovi
              libdvdnav
              libdvdread
              mujs
              libbluray
              lua
              rubberband
              SDL2
              libuchardet
              zimg
              alsa-lib
              openal
              pipewire
              pulseaudio
              libcaca
              libdrm
              mesa
              xorg.libXScrnSaver
              xorg.libXpresent
              xorg.libXv
              nv-codec-headers-12
              libva
              libvdpau
              ninja
              webkitgtk_4_1
            ];

            shellHook = ''
              export LD_LIBRARY_PATH="$(pwd)/build/linux/x64/debug/bundle/lib:$(pwd)/build/linux/x64/release/bundle/lib:$LD_LIBRARY_PATH"
            '';
          };
      in {
        inherit devShells packages;
      }
    );
}
