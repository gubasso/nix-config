_:

{
  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";

    # No secrets declared here. Keeping secret declarations in the consumer
    # (not this shared module) ensures no plaintext ever reaches /nix/store and
    # keeps per-host recipients private.
    #
    # In the consumer: replace the placeholder recipients in its .sops.yaml with
    # real per-host age recipients, then add encrypted files under
    # secrets/<host>/ and declare them, e.g.:
    # secrets."keyring/example.yaml" = {
    #   sopsFile = ../../secrets/<host>/keyring/example.yaml;
    #   owner = "youruser";
    #   group = "users";
    #   mode = "0400";
    # };
  };
}
