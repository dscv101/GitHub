{
  imports = [
    # keep-sorted start prefix_order=../../,./
    ../../systems
    ./args.nix # the base args that is passed to the flake
    ./checks/default.nix # custom checks that are devised to test if the system is working as expected
    ./lib/default.nix # the lib that is used in the system
    ./packages/default.nix # our custom packages provided by the flake
    ./programs/default.nix # programs that run in the dev shell
    # keep-sorted end
  ];
}
