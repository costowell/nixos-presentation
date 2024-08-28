{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = with pkgs; [
    marp-cli
    alejandra
    ungoogled-chromium
  ];
}
