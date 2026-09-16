{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "sqls";
  version = "0.2.48";

  src = fetchFromGitHub {
    owner = "sqls-server";
    repo = "sqls";
    rev = "v${version}";
    hash = "sha256-TjGu8QcwYIPoW2v61fXpq/oZKoksOUZ2/dnleJhPjFM=";
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
