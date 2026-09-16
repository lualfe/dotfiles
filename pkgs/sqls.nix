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

  vendorHash = "sha256-VVa77h0mgWLEuL2+Q3qre5V71kbBaWaugNN9TcTC8y0=";

  meta = {
    description = "SQL language server written in Go";
    homepage = "https://github.com/sqls-server/sqls";
    license = lib.licenses.mit;
    mainProgram = "sqls";
  };
}
