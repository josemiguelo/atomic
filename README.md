# atomic

A custom [bootc](https://github.com/bootc-dev/bootc) image that integrates my personal tooling into [Bazzite](https://bazzite.gg/) (Universal Blue). Two variants are built: a standard `bazzite-dx` image and an Nvidia variant (`bazzite-dx-nvidia`).

## Repository structure

For a detailed overview of the project architecture, conventions, and repository layout, see [`llms.txt`](llms.txt) and [`AGENTS.md`](AGENTS.md). Each subdirectory also has its own `README.md` with specifics.

## How to use it

For using on a fresh installation, execute the following commands to use the default dx image:

```bash
sudo bootc switch ghcr.io/josemiguelo/atomic:latest
systemctl reboot
```


Use this if you want to use the dx-nvidia image:
```bash
sudo bootc switch ghcr.io/josemiguelo/atomic-nvidia:latest
systemctl reboot
```

## post-installation

Execute after login:

```bash
ujust do-post-install
```

## Todos

- install postman
- install scrcpy
- install dbeaver
- install azure-cli
