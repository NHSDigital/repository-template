# Guide: Run Git hooks on commit

- [Guide: Run Git hooks on commit](#guide-run-git-hooks-on-commit)
  - [Overview](#overview)
  - [Key files](#key-files)
  - [Testing](#testing)

## Overview

Git hooks are managed by the [pre-commit](https://pre-commit.com/) framework and sourced from the shared repository [NHSDigital/nhs-notify-shared-modules](https://github.com/NHSDigital/nhs-notify-shared-modules). They are executed automatically on each commit, provided that the `make config` command has been run locally to set up the project. The same checks are also part of the CI/CD pipeline execution. This setup serves as a safety net and helps to ensure consistency.

The [pre-commit](https://pre-commit.com/) framework is a powerful tool for managing Git hooks, providing automated hook installation and management capabilities.

## Key files

- Configuration
  - [`pre-commit.yaml`](../../scripts/config/pre-commit.yaml)
  - [`init.mk`](../../scripts/init.mk): make targets
- Shared hooks source
  - [`NHSDigital/nhs-notify-shared-modules`](https://github.com/NHSDigital/nhs-notify-shared-modules)

## Testing

You can run and test the process by executing the following commands from your terminal. These commands should be run from the top-level directory of the repository:

```shell
make githooks-config
make githooks-run
```
