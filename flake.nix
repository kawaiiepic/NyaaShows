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

        config.android_sdk.accept_license = true;

        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [
            "30.0.3"
          ];
          platformVersions = ["33" "34"];
          abiVersions = ["x86_64"];
          includeEmulator = true;
          emulatorVersion = "35.1.4";
          includeSystemImages = true;
          systemImageTypes = ["google_apis_playstore"];
          includeNDK = true;
          ndkVersions = ["25.1.8937393"];
        };

        androidSdk = androidComposition.androidsdk;

        devShells.default =
          pkgs.mkShell
          {
            buildInputs = with pkgs; [
              pkg-config
              glib
              pcre2
              # cmake
              # flutter
              # ninja
              # corrosion
              # (pkgs.rust-bin.selectLatestNightlyWith (toolchain:
              #   toolchain.default.override {
              #     extensions = ["rust-src" "rustfmt" "clippy"];
              #     targets = ["wasm32-unknown-unknown" "aarch64-linux-android" "armv7-linux-androideabi" "x86_64-linux-android" "i686-linux-android"];
              #   }))
              gtk3
              # clang
              # llvmPackages.libclang
              # awscli2
              # cargo-lambda
              # jdk17
              # androidSdk
              # gcc-unwrapped
              # aapt
            ];

            shellHook = ''
              export LD_LIBRARY_PATH="$(pwd)/build/linux/x64/debug/bundle/lib:$(pwd)/build/linux/x64/release/bundle/lib:$LD_LIBRARY_PATH"
            '';
          };
      in {
        inherit devShells;
      }
    );
}
