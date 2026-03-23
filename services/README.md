# services

Systemd service units that are installed into the image at build time. The `Containerfile` copies them into the appropriate systemd paths, and the build orchestrator (`build_files/00_build.sh`) enables them.

## Directory structure

- `user/` — Per-login user services, installed to `/usr/lib/systemd/user/`. These run in each user's session and use `WantedBy=default.target`. Enabled with `systemctl enable --global`.
- `system/` — System-wide services, installed to `/usr/lib/systemd/system/`. These run as root at boot and use `WantedBy=multi-user.target`. Enabled with `systemctl enable`.

## How it works

Each `.service` file defines a systemd unit. Services reference executable scripts located in `system_files/usr/bin/`. The service unit defines *when* and *how* the script runs (triggers, dependencies, restart policy), while the script itself contains the actual logic.

When adding or modifying a service, check both the `.service` file here and its corresponding script in `system_files/usr/bin/`.

## Adding a new service

1. Decide whether the service is a **user** service (runs per-login session) or a **system** service (runs at boot as root).
2. Create a `.service` file in `user/` or `system/` following standard [systemd unit file format](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html).
3. Place the executable script it references in `system_files/usr/bin/`.
4. Add the appropriate `systemctl enable` call in `build_files/00_build.sh`:
   - User services: `systemctl enable --global /usr/lib/systemd/user/<name>.service`
   - System services: `systemctl enable /usr/lib/systemd/system/<name>.service`
