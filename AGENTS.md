# AGENTS.md

Guidelines for AI agents working in the stellasaur repository.

## Project overview

stellasaur is a custom bootc container image extending a Universal Blue Bluefin base. It produces a personalized Fedora Linux desktop that can be installed via `sudo bootc switch`. The image is built as a container with `podman build`, published to GHCR, and signed with cosign.

## Architecture

### Build pipeline

The `Containerfile` defines a multi-stage build parameterized by `BASE_IMAGE` (defaults to `bluefin-dx`). The first stage copies build scripts into a scratch context. The second stage starts from `ghcr.io/ublue-os/${BASE_IMAGE}:stable`, copies system files (scripts, services, ujust recipes, GNOME extensions) into the filesystem, then runs the orchestrator script `build_files/00_build.sh`. That orchestrator auto-discovers and invokes every other numbered script in `build_files/` in version-sorted order. The build finishes with `bootc container lint` to validate the image. CI uses a matrix strategy to build two variants: `bluefin-dx` (published as `stellasaur`) and `bluefin-dx-nvidia-open` (published as `stellasaur-nvidia`). Read the `Containerfile` and `build_files/00_build.sh` to understand the current build steps.

### Post-install flow

A systemd user service (`post-install-checker.service`) triggers on first graphical login. It skips system users and clones this repo so that ujust recipes are available. The user then runs `ujust do-post-install` to execute all post-install setup. See `ujust/README.md` for details.

### CI/CD

GitHub Actions workflows handle building the container image, pushing to GHCR, and signing with cosign. A separate workflow can build bootable disk images. Renovate and Dependabot manage dependency and action version pins — do not update those manually.

### Systemd services

Service units live in `services/user/` (per-login user services installed to `/usr/lib/systemd/user/`) and `services/system/` (boot-time system services installed to `/usr/lib/systemd/system/`). See `services/README.md` for how they work and how to add new ones.

### Disk configs

TOML files in `disk_config/` configure bootc-image-builder for different output formats (disk images, ISOs). They define partition layout and kickstart scripts. See `disk_config/README.md` for details on the config format and how to add new ones.

## Technology stack

- **OS base**: Fedora (via Universal Blue / Bluefin)
- **Image type**: bootc (OCI container as OS)
- **Container tool**: Podman
- **Package manager**: dnf5 (not dnf4)
- **Task runner**: Just (`Justfile` for dev, `ujust` for user recipes)
- **CI/CD**: GitHub Actions
- **Image signing**: cosign (sigstore)
- **Dependency updates**: Renovate + Dependabot

## Coding conventions

### Shell scripts

- All scripts in `build_files/` must start with `#!/bin/bash` and use `set -euo pipefail` (or `set -eoux pipefail` for verbose builds).
- Use `dnf5` for package operations, not `dnf`.
- Scripts are numbered with zero-padded prefixes in increments of 10 (e.g., `10_`, `20_`, `30_`). Use a gap or a sub-number (e.g., `141_`) if inserting between existing scripts.
- Each script should handle exactly one concern (one application, one repo, one config).
- To disable a script without removing it, add `exit 0` at the top of the script body.
- New scripts are automatically discovered and executed by `00_build.sh` — do not add them manually to the orchestrator.

### Just recipes

- Recipes in `ujust/` are imported by `custom.just`. New recipes need a corresponding `import` line in `custom.just` and should be added to the `do-post-install` recipe if they should run automatically.
- `60-custom.just` is the system-level entry point installed into the image. It imports `custom.just` from the cloned repo path.
- Recipes should be idempotent — safe to run multiple times.

### Containerfile

- All package installation happens inside `00_build.sh`, not as separate `RUN` layers in the Containerfile.
- The final `bootc container lint` must always pass.

## Important warnings

- **Git submodules**: Check `.gitmodules` before modifying anything under `system_files/`. Some directories are external submodules and should not be edited directly.
- **Action version pins**: Do not change commit SHA pins in `.github/workflows/` manually. They are managed by Renovate and Dependabot.
- **Secrets**: `cosign.key` is gitignored. Only `cosign.pub` (the public key) is in the repo. Never commit private keys.
- **Personal config**: Some ujust recipes contain hardcoded personal values (email, GitHub username, dotfiles repo). Be aware of this when suggesting changes.

## How to build and test

Run `just --list` to see all available recipes. Key workflows:

- `just build` — Build the container image locally with Podman (defaults to `bluefin-dx`; set `BASE_IMAGE=bluefin-dx-nvidia-open` env var for the Nvidia variant).
- `just lint` — Run shellcheck on all shell scripts.
- `just format` — Run shfmt on all shell scripts.
- `just check` — Validate just file syntax.

To test changes: modify a build script or the Containerfile, run `just build`, and verify the build succeeds (including the `bootc container lint` step). For ujust recipe changes, test by running the specific recipe directly (e.g., `ujust <recipe-name>`).

## Self-maintenance

After every change, evaluate whether any AI instruction files (`AGENTS.md`, `llms.txt`, and any `README.md` files in the repo) need to be updated to reflect the new state of the project. If a change introduces, removes, or modifies conventions, architecture, file structure, or workflows, update the relevant files so they stay accurate. Do not wait to be asked.
