{ pkgs ? (import <nixpkgs> { })
, rustPlatform ? pkgs.rustPlatform
, nixVersions ? pkgs.nixVersions
, nixForHarmonia ? nixVersions.unstable
, nix-gitignore ? pkgs.nix-gitignore
, lib ? pkgs.lib
, clippy ? pkgs.clippy
, pkg-config ? pkgs.pkg-config
, nlohmann_json ? pkgs.nlohmann_json
, libsodium ? pkgs.libsodium
, boost ? pkgs.boost
, openssl ? pkgs.openssl
, sqlite ? pkgs.sqlite
, enableClippy ? false
}:

rustPlatform.buildRustPackage ({
  name = "harmonia";
  src = nix-gitignore.gitignoreSource [ ] (lib.sources.sourceFilesBySuffices (lib.cleanSource ./.) [ ".rs" ".toml" ".lock" ".cpp" ".h" ".md" ]);
  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ pkg-config ] ++ lib.optionals enableClippy [ clippy ];
  buildInputs = [
    nixForHarmonia
    nlohmann_json
    libsodium
    boost
    openssl
    sqlite
  ];
  doCheck = false;

  meta = with lib; {
    description = "Nix binary cache implemented in rust using libnix-store";
    homepage = "https://github.com/helsinki-systems/harmonia";
    license = with licenses; [ mit ];
    maintainers = [ maintainers.conni2461 ];
    platforms = platforms.all;
  };
} // lib.optionalAttrs enableClippy {
  buildPhase = ''
    cargo clippy --all-targets --all-features -- -D warnings
    if grep -R 'dbg!' ./src; then
      echo "use of dbg macro found in code!"
      false
    fi
  '';
  installPhase = ''
    touch $out
  '';
})
