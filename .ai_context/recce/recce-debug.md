---
title: Debug
icon: material/bug-check
---

The `recce debug` command is a diagnostic tool that helps you verify your Recce setup by checking the development and base environments. It validates that all required dbt artifacts are in place and tests the warehouse connection, ensuring everything is properly configured before running other Recce commands.

## Usage

```bash
recce debug [OPTIONS]
```

## Options

| Option                    | Description                                                       |
| ------------------------- | ----------------------------------------------------------------- |
| `-t, --target TEXT`       | Which target to load for the given profile                        |
| `--profile TEXT`          | Which existing profile to load                                    |
| `--project-dir PATH`      | Which directory to look in for the dbt_project.yml file           |
| `--profiles-dir PATH`     | Which directory to look in for the profiles.yml file              |
| `--target-path TEXT`      | dbt artifacts directory for your development branch               |
| `--target-base-path TEXT` | dbt artifacts directory to be used as the base for the comparison |
| `--help`                  | Show help message and exit                                        |

## Example Outputs

### Success Case

When everything is properly configured, you'll see output like this:

```shell
────────────────────── Development Environment ──────────────────────
[OK] Directory exists: target
[OK] Manifest JSON file exists : target/manifest.json
[OK] Catalog JSON file exists: target/catalog.json
─────────────────────────── Base Environment ────────────────────────
[OK] Directory exists: target-base
[OK] Manifest JSON file exists : target-base/manifest.json
[OK] Catalog JSON file exists: target-base/catalog.json
────────────────────── Warehouse Connection ─────────────────────────
[OK] Connection test
──────────────────────────── Result ─────────────────────────────────
[OK] Ready to launch! Type 'recce server'.
```

### Partial Setup Cases

Even when some components are missing, Recce can still launch with limited features and provides helpful tips:

#### Missing Base Environment Directory

```shell
────────────────────── Development Environment ──────────────────────
[OK] Directory exists: target
[OK] Manifest JSON file exists : target/manifest.json
[OK] Catalog JSON file exists: target/catalog.json
─────────────────────────── Base Environment ────────────────────────
[MISS] Directory not found: target-base
────────────────────── Warehouse Connection ─────────────────────────
[OK] Connection test
──────────────────────────── Result ─────────────────────────────────
[OK] Ready to launch with limited features. Type 'recce server'.
[TIP] Run dbt with '--target-path target-base' or overwrite the
      default directory of the base environment with
      '--target-base-path'.
```

#### Missing Base Environment Artifacts

```shell
────────────────────── Development Environment ──────────────────────
[OK] Directory exists: target
[OK] Manifest JSON file exists : target/manifest.json
[OK] Catalog JSON file exists: target/catalog.json
─────────────────────────── Base Environment ────────────────────────
[OK] Directory exists: target-base
[MISS] Manifest JSON file not found: target-base/manifest.json
[MISS] Catalog JSON file not found: target-base/catalog.json
────────────────────── Warehouse Connection ─────────────────────────
[OK] Connection test
──────────────────────────── Result ─────────────────────────────────
[OK] Ready to launch with limited features. Type 'recce server'.
[TIP] 'dbt run --target-path target-base' to generate the
      manifest JSON file for the base environment.
[TIP] 'dbt docs generate --target-path target-base' to generate
      the catalog JSON file for the base environment.
```

#### Connection Failure

When the database connection fails, you'll see output like this:

```shell
────────────────────── Development Environment ──────────────────────
[OK] Directory exists: target
[OK] Manifest JSON file exists : target/manifest.json
[OK] Catalog JSON file exists: target/catalog.json
─────────────────────────── Base Environment ────────────────────────
[OK] Directory exists: target-base
[OK] Manifest JSON file exists : target-base/manifest.json
[OK] Catalog JSON file exists: target-base/catalog.json
────────────────────── Warehouse Connection ─────────────────────────
[FAIL] Connection test
──────────────────────────── Result ─────────────────────────────────
[TIP] Run 'dbt debug' to check the connection.
```

## Related Documentation

- [Getting Started](../get-started.md): Learn how to set up your first Recce environment
- [Environment Preparation Best Practices](../guides/best-practices-prep-env.md): Detailed guide on preparing environments
- [Run Command](./recce-run.md): Execute checks from the command line
