#!/bin/sh
set -eu

usage() {
	cat <<'EOF'
Usage:
  ./install.sh [--destdir DIR]

Install the Meizu M2172 ALSA UCM and WirePlumber configuration.

Examples:
  sudo ./install.sh
  ./install.sh --destdir /path/to/rootfs
  DESTDIR=/path/to/rootfs ./install.sh
EOF
}

destdir=${DESTDIR:-}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--destdir)
			shift
			if [ "$#" -eq 0 ]; then
				echo "install.sh: --destdir requires a directory" >&2
				exit 2
			fi
			destdir=$1
			;;
		--destdir=*)
			destdir=${1#--destdir=}
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "install.sh: unknown argument: $1" >&2
			usage >&2
			exit 2
			;;
	esac
	shift
done

case "$destdir" in
	/) destdir= ;;
	*/) destdir=${destdir%/} ;;
esac

if [ -z "$destdir" ] && [ "$(id -u)" -ne 0 ]; then
	echo "install.sh: installing to / requires root; run with sudo or set DESTDIR" >&2
	exit 1
fi

srcdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

install_ucm() {
	src=$1
	dst=$2

	install -Dm644 "$srcdir/$src" "$destdir$dst"
	printf 'installed %s -> %s\n' "$src" "$destdir$dst"
}

install_ucm "m2172/m2172.conf" \
	"/usr/share/alsa/ucm2/m2172/m2172.conf"
install_ucm "m2172/Speaker.conf" \
	"/usr/share/alsa/ucm2/m2172/Speaker.conf"
install_ucm "m2172/Earpiece.conf" \
	"/usr/share/alsa/ucm2/m2172/Earpiece.conf"
install_ucm "m2172/StereoSpeaker.conf" \
	"/usr/share/alsa/ucm2/m2172/StereoSpeaker.conf"
install_ucm "conf.d/sm8250/meizu-m2172-sndcard.conf" \
	"/usr/share/alsa/ucm2/conf.d/sm8250/meizu-m2172-sndcard.conf"
install_ucm "wireplumber/wireplumber.conf.d/51-bluez-hfp.conf" \
	"/etc/wireplumber/wireplumber.conf.d/51-bluez-hfp.conf"

if [ -z "$destdir" ]; then
	cat <<'EOF'

Installed to the running system.
Restart user audio services to reload the configuration:
  systemctl --user restart wireplumber pipewire pipewire-pulse
EOF
fi
