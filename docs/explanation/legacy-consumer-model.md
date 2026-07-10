# Legacy Consumer Model

The public framework no longer carries concrete consumer identity. Legacy
consumer examples are placeholders only.

Use a private consumer repo for concrete hosts, user names, host hardware,
recipient scaffolding, and encrypted secret values. That private repo imports
this public framework and calls `lib.mkHost` or `lib.mkHomeHost`.
