{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  tmux
  eza
  diff-so-fancy
  spaceship-prompt
  tflint
  tfswitch
  pre-commit
  aliyun-cli
  awscli2
  google-cloud-sdk
]