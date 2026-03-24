# build_files

Shell scripts that run during the container image build. Each script handles one concern — installing a package, adding a repository, or configuring the system.

## Execution

`00_build.sh` is the orchestrator. It automatically discovers and runs every other numbered script in version-sorted order, enables systemd services, and cleans the package cache. It is invoked by the `RUN` directive in the `Containerfile`. New scripts are picked up automatically — there is no need to register them in `00_build.sh`.

## Naming convention

Scripts use zero-padded numeric prefixes followed by a descriptive name: `<number>_<name>.sh`. The numbering controls execution order and uses increments of 10 to leave room for future additions. If a new script is closely related to an existing one, use a sub-number (e.g., `141_` follows `140_`).

## Adding a new build script

1. Choose a number that places it in the correct execution order relative to existing scripts.
2. Create the file as `<number>_<descriptive-name>.sh`.
3. Start with:
   ```bash
   #!/bin/bash

   set -euo pipefail

   echo "::group:: ===$(basename "$0")==="
   ```
4. End with:
   ```bash
   echo "::endgroup::"
   ```
5. Use `dnf5` (not `dnf`) for package operations.
6. Keep the script focused on a single application or config concern.

## Disabling a script

Add `exit 0` at the top of the script body. This keeps the script in the repo for future re-enablement without breaking the build.
