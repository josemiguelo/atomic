ARG BASE_IMAGE=bluefin-dx

FROM busybox AS ctx

# main path scripts
COPY build_files /build_scripts
RUN chmod +x /build_scripts/*.sh

FROM ghcr.io/ublue-os/${BASE_IMAGE}:stable

## Make /opt immutable and be able to be used by the package manager.
RUN rm /opt && mkdir /opt

# user scripts
COPY system_files/usr/bin /usr/bin/
RUN chmod +x /usr/bin/*

# systemd services
COPY services /usr/lib/systemd/user/

# just files
COPY ujust/60-custom.just /usr/share/ublue-os/just/60-custom.just

COPY system_files/usr/share/gnome-shell/extensions/tmp/ddcutil/display-brightness-ddcutil@themightydeity.github.com \
  /usr/share/gnome-shell/extensions/display-brightness-ddcutil@themightydeity.github.com

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_scripts/00_build.sh

## Verify if final image and contents are correct.
RUN bootc container lint
