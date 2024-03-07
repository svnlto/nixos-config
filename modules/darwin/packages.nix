{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  dockutil
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
  granted

  packer
  consul
  vagrant
  vault
]
