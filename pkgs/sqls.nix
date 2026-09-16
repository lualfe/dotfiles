{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "sqls";
  version = "0.2.48";

  src = fetchFromGitHub {
    owner = "sqls-server";
    repo = "sqls";
    rev = "v${version}";
    # `nix build` will fail on the first run and print the correct hash;
    # paste it in here.
    hash = lib.fakeHash;
  };

  # Same story as `hash` above: run the build once, copy the real
  # vendorHash from the error message.
  vendorHash = lib.fakeHash;

  meta = {
    description = "SQL language server written in Go";
    homepage = "https://github.com/sqls-server/sqls";
    license = lib.licenses.mit;
    mainProgram = "sqls";
  };
}
