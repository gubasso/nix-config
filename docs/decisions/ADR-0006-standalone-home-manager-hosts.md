# ADR-0006: Standalone Home Manager Hosts

Status: Superseded by ADR-0009

## Context

This ADR previously recorded concrete standalone Home Manager host identities in
the public repo.

## Decision

Standalone Home Manager support remains part of the public framework through
`lib.mkHomeHost`, but concrete standalone host outputs and identifying values
belong in the private consumer.

## Consequences

Public docs use placeholders such as `<user>@<host>`. Private docs carry the
actual host inventory and activation procedures.
