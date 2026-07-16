# Documentation

This documentation covers the public `nix-config` framework.

- [Reference](reference/) documents public factories, modules, and generic
  layouts, including the [theme system](reference/theming.md) (ADR-0017).
- [Guides](guides/) use placeholders for private consumers and hosts.
  [development.md](guides/development.md) covers the fmt/lint/check/test workflow.
- [Explanation](explanation/) describes the public/private dependency model.
- [Decisions](decisions/) records ADRs. ADR-0009 supersedes the private-data
  portions of the earlier consolidated source-of-truth decisions; ADR-0010
  records the pre-commit/pre-push enforcement of the public-repo hygiene rules;
  ADR-0011 adopts the standard dev tooling (formatter, linters, test tier).

Private host inventories and activation procedures live in the private consumer
repo.
