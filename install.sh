#!/bin/sh
set -eu

[ "$(id -u)" -eq 0 ] || { echo "Run as root" >&2; exit 1; }
base=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
mkdir -p /usr/bin /etc/init.d /etc/config
cp "$base/files/usr/bin/notify" /usr/bin/notify
cp "$base/files/usr/bin/notify-worker" /usr/bin/notify-worker
cp "$base/files/etc/init.d/notify-worker" /etc/init.d/notify-worker
chmod 0755 /usr/bin/notify /usr/bin/notify-worker /etc/init.d/notify-worker
if [ ! -e /etc/config/notify ]; then
	cp "$base/files/etc/config/notify" /etc/config/notify
fi
chmod 600 /etc/config/notify
/etc/init.d/notify-worker enable
echo "Installed. Edit /etc/config/notify, then run: /etc/init.d/notify-worker start"
