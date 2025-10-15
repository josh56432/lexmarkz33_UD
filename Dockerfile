# =======================================================
# Minimal Alpine image running Red Hat 8 VM (Lexmark Z33)
# =======================================================
FROM alpine:latest

LABEL maintainer="Josh <josh56432>"
LABEL description="Minimal Alpine + QEMU + Embedded Red Hat 8 VM for Lexmark Z33 Universal Driver"

# --- install minimal runtime packages ---
RUN apk add --no-cache qemu-system-i386 tini bash usbutils coreutils

# --- copy in your prepared Red Hat 8 image ---
COPY image/redhat8.qcow2 /vm/redhat8.qcow2
WORKDIR /vm
EXPOSE 5901

# --- create the startup script with banner and mode logic ---
RUN cat > /usr/local/bin/run-vm <<'EOF'
#!/bin/bash
set -e

# === COLOUR CODES ===
BLUE="\033[1;34m"
CYAN="\033[1;36m"
RESET="\033[0m"

# === SPLASH ===
echo -e "${BLUE}"
echo "┌────────────────────────────────────────────────────────────┐"
echo "│   Lexmark Z33 Printer Universal Driver                     │"
echo "│   by josh56432                                             │"
echo "│   ☕ Buy me a coffee: https://buymeacoffee.com/josh56432    │"
echo "└────────────────────────────────────────────────────────────┘"
echo -e "${RESET}"

echo -e "${CYAN}USAGE:${RESET}"
echo "  podman run --rm -it --privileged lexmarkz33_ud                     # Normal headless mode"
echo "  podman run --rm -it --privileged -p 5901:5901 lexmarkz33_ud --install   # Install mode"
echo "  podman run --rm -it --privileged -p 5901:5901 lexmarkz33_ud --debug     # Debug mode"
echo ""
echo -e "${CYAN}SYSTEMD TIP:${RESET}"
echo "  To run persistently, create a systemd service that executes:"
echo "  podman run --rm --privileged --name lexmark-vm lexmarkz33_ud"
echo ""

# === FLAG PARSING ===
MODE=headless
for arg in "$@"; do
  [[ "$arg" == "--debug" ]] && MODE=debug
  [[ "$arg" == "--install" ]] && MODE=install
done

AUTOSTART=""
KARGS="root=/dev/hda1"

case "$MODE" in
  debug)
    echo "[INFO] Debug mode enabled: VGA + VNC + z23-z33lsc"
    AUTOSTART="z23-z33lsc"
    VNC="-vnc 0.0.0.0:1"
    ;;
  install)
    echo "[INFO] Install mode: VGA + VNC + /lexmarkz33-1.0-3.sh"
    AUTOSTART="/lexmarkz33-1.0-3.sh"
    VNC="-vnc 0.0.0.0:1"
    ;;
  *)
    echo "[INFO] Headless mode (default)"
    VNC="-nographic"
    ;;
esac

# Write autostart marker for the guest VM to read on boot
echo "$AUTOSTART" > /tmp/autostart.cmd

# --- launch QEMU ---
exec qemu-system-i386 \
  -m 512 \
  -hda /vm/redhat8.qcow2 \
  -boot c \
  -usb \
  -device usb-host,vendorid=0x043d,productid=0x0021 \
  -vga cirrus \
  $VNC \
  -monitor unix:/var/ryb/qemu-rh8-monitor.sock,server=on,wait=off \
  -serial unix:/var/ryb/qemu-rh8-serial.sock,server=on,wait=off
EOF

RUN chmod +x /usr/local/bin/run-vm

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/bin/run-vm"]
