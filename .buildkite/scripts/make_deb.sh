#!/usr/bin/env bash

set -euo pipefail

BUILD_NET="${BUILD_NET:-mainnet}"


VERSION=$(echo $VERSION_TAG | sed -e 's,validator,,')
DIAGNOSTIC=1 ./rebar3 as validator release -n miner -v ${VERSION} || ./rebar3 as validator release -n miner -v ${VERSION}

wget -O /tmp/genesis https://snapshots.helium.wtf/genesis.${BUILD_NET}

fpm -n validator \
    -v "${VERSION}" \
    -s dir \
    -t deb \
    --depends libssl1.1 \
    --depends libsodium23 \
    --depends libncurses5 \
    --depends dbus \
    --depends libstdc++6 \
    --deb-systemd deb/miner.service \
    --before-install deb/before_install.sh \
    --after-install deb/after_install.sh \
    --after-remove deb/after_remove.sh \
    --before-upgrade deb/before_upgrade.sh \
    --after-upgrade deb/after_upgrade.sh \
    --deb-no-default-config-files \
    --deb-systemd-enable \
    --deb-systemd-auto-start \
    --deb-systemd-restart-after-upgrade \
    --deb-user helium \
    --deb-group helium \
    _build/validator/rel/=/opt \
    /tmp/genesis=/opt/miner/update/genesis

rm -f /tmp/genesis
