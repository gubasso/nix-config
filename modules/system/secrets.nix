{ ... }:

{
  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";

    # No secrets declared yet. Keeping secrets out of Nix modules ensures no
    # plaintext ever reaches /nix/store.
    #
    # TODO(round 6): replace nix/.sops.yaml's placeholder recipient
    # (`age1replace-with-orion-age-recipient`) with the real orion age
    # recipient, then add real encrypted files under nix/secrets/.
    #
    # Intended future shape for user-owned keyring/SSH/GPG material:
    # secrets."keyring/example.yaml" = {
    #   sopsFile = ../../secrets/keyring/example.yaml;
    #   owner = "gubasso";
    #   group = "users";
    #   mode = "0400";
    # };
  };
}
