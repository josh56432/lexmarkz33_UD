# 🖨️ Lexmark Z33 Universal Driver VM   
**Image:** [`docker.io/josh56432/lexmarkz33_ud:latest`](https://hub.docker.com/r/josh56432/lexmarkz33_ud)  
**Base:** Alpine Linux + QEMU + Embedded Red Hat 8 VM  

---

## 📘 Overview

This container provides a **self-contained environment** for the **Lexmark Z33** printer using an **embedded Red Hat 8 virtual machine**.  
Because the Z33 driver depends on deprecated 32-bit Red Hat libraries, the setup uses **QEMU** to emulate a working RH8 environment automatically inside an Alpine container.

The image can run **headless** for print job forwarding or in **VNC debug mode** for graphical interaction. It is recommended to run this on a standalone print server

---

## 🧩 Features

- 🧠 Fully automated QEMU i386 VM startup inside a minimal Alpine base  
- ⚙️ Embedded **Red Hat 8** guest with USB passthrough  
- 🖨️ Native **Lexmark Z33** USB driver (`/lexmarkz33-1.0-3.sh`)  
- 🧾 Built-in banner and usage guide at startup  
- 🪟 Optional **VNC interface** on `:5901` for GUI debugging  
- 🧰 Ready for **systemd-based persistent operation**

---

## 🐋 Quick Start

You can pull and run directly — **no build needed**:

```bash
podman run --rm -it --privileged docker.io/josh56432/lexmarkz33_ud:latest
```

or with Docker:

```bash
docker run --rm -it --privileged josh56432/lexmarkz33_ud:latest
```
or with ghcr.io:

```bash
podman run --rm -it --privileged ghcr.io/josh56432/lexmarkz33_ud:latest
```
```bash
docker run --rm -it --privileged ghcr.io/josh56432/lexmarkz33_ud:latest
```


---

## ▶️ Usage Modes

### 🧩 Normal (Headless)
Serial console only (`console=ttyS0`):

```bash
podman run --rm -it --privileged docker.io/josh56432/lexmarkz33_ud:latest
```

### ⚙️ Install Mode (recommended for first time run)
Boots the VM with VGA + VNC and executes  
`/lexmarkz33-1.0-3.sh` automatically:

```bash
podman run --rm -it --privileged -p 5901:5901 docker.io/josh56432/lexmarkz33_ud:latest --install
```

Access via VNC:
```bash
vncviewer 127.0.0.1:5901
```

### 🪟 Debug Mode (for cleaning cycles and installing new cartridges)
VGA + VNC enabled, auto-runs `z23-z33lsc` for testing:

```bash
podman run --rm -it --privileged -p 5901:5901 docker.io/josh56432/lexmarkz33_ud:latest --debug
```

---

## 🧠 Persistent Operation (Podman Only)

Instead of writing a manual systemd service, use **Podman’s native systemd integration**:

1. Generate a systemd unit for persistent operation:
   ```bash
   podman generate systemd --name lexmark-vm --files --new
   ```

2. Move the generated service file into place:
   ```bash
   sudo mv container-lexmark-vm.service /etc/systemd/system/
   ```

3. Enable and start automatically on boot:
   ```bash
   sudo systemctl enable --now container-lexmark-vm.service
   ```

4. Verify it’s running:
   ```bash
   systemctl status container-lexmark-vm.service
   ```

This ensures the container runs in the background, restarts on failure, and stops cleanly with the system.

---


## 🧠 Troubleshooting

- **Permission denied** during save/build  
  → Ensure writable directory or use `sudo`.  
- **VNC not showing**  
  → Map port 5901 (`-p 5901:5901`) and ensure `vga=normal`.  
- **USB passthrough fails**  
  → Verify the printer appears:  
  ```
  lsusb | grep Lexmark
  Bus 001 Device 002: ID 043d:0021 Lexmark Z33 Printer
  ```

---

## ☕ Credits

Lexmark Z33 Printer Universal Driver VM  
by **Josh (@josh56432)**  
[Buy me a coffee ☕](https://buymeacoffee.com/josh56432)
