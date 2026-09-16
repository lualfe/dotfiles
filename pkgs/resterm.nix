{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "resterm";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "unkn0wn-root";
    repo = "resterm";
    rev = "v${version}";
    hash = "sha256-qIxIUNTYmRsQU6u5MHyVhM89+svEz/6r+HX2Q/glOLk=";
  };

  vendorHash = "sha256-q5DvpQPAvy5TnuhyNiiEF4tcwUQFqCcEdeLzFOXcsko=";

  subPackages = [ "cmd/resterm" ];

  meta = {
    description = "Terminal API client for HTTP, GraphQL and gRPC using plain .http files";
    homepage = "https://github.com/unkn0wn-root/resterm";
    license = lib.licenses.mit;
    mainProgram = "resterm";
  };
}
