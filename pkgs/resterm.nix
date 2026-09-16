{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "resterm";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "unkn0wn-root";
    repo = "resterm";
    rev = "v${version}";
    # `nix build` will fail on the first run and print the correct hash;
    # paste it in here.
    hash = lib.fakeHash;
  };

  # Same story as `hash` above: run the build once, copy the real
  # vendorHash from the error message.
  vendorHash = lib.fakeHash;

  subPackages = [ "cmd/resterm" ];

  meta = {
    description = "Terminal API client for HTTP, GraphQL and gRPC using plain .http files";
    homepage = "https://github.com/unkn0wn-root/resterm";
    license = lib.licenses.mit;
    mainProgram = "resterm";
  };
}
