## About

A carefully crafted OpenCore **ISO** image that makes creating macOS virtual machines on **Proxmox VE** and **QEMU/KVM** straightforward.

Completely redesigned from scratch with a clean, efficient architecture that eliminates outdated methods and legacy configurations.[^legacy]

Supports every Intel-based macOS release, from **Mac OS X 10.4 Tiger** through **macOS 26 Tahoe**.[^osx]

Also compatible with **libvirt** and **Virt-Manager**.

> [!TIP]
> **For AMD users:**
> Enjoy a true **vanilla macOS** experience with no kernel patches.
> This is likely the best way to run macOS on AMD hardware while still retaining full hypervisor access to run other VMs.

> [!Note]
> **Found this useful?** Give it a ⭐ star to help others discover it!

## Table of Contents

- [Download](#download)
- [Quick Start Guide](#quick-start-guide)
  - [1. Create a New VM](#1-create-a-new-vm-in-the-proxmox-ve-web-interface)
  - [2. General](#2-general)
  - [3. OS](#3-os)
  - [4. System](#4-system)
  - [5. Hard Disk](#5-hard-disk)
  - [6. CPU](#6-cpu)
  - [7. Memory](#7-memory)
  - [8. Network](#8-network)
  - [9. Finalize](#9-finalize)
  - [10. Troubleshooting](#10-troubleshooting)
- [Post-Install](#post-install)
- [macOS Tahoe Cursor Freeze Fix](#macos-tahoe-cursor-freeze-fix)
- [Contributing](#contributing)
- [Credits](#credits)
- [License & Attribution](#license--attribution)
- [Disclaimer](#disclaimer)

---

## Download

* Get the latest OpenCore-ISO: 👉 [Release page](https://github.com/LongQT-sea/OpenCore-ISO/releases)
* For macOS installers and recovery ISOs: 👉 [LongQT-sea/macos-iso-builder](https://github.com/LongQT-sea/macos-iso-builder)

> [!CAUTION]
> These iso are **true CD/DVD ISO image**.
> Do **NOT** modify VM config to change ***`media=cdrom`*** to ***`media=disk`***.

> [!TIP]
> Run [**`Create_macOS_ISO.command`**](/Create_macOS_ISO.command) inside your VM to download the full macOS installer from Apple and generate a proper DVD-format macOS installer ISO.

---

## Quick Start Guide

### 1. Create a New VM in the Proxmox VE web interface

---

### 2. General

* **VM ID**: Any available ID
* **Name**: Any name you like for the macOS VM

---

### 3. OS

* **ISO Image**: Select `LongQT-OpenCore-v0.X.iso`
* **Guest OS Type**: Leave as default (`Linux`)

---

### 4. System

* **Machine Type**: **q35** *(if you must use `i440fx`, [cpu-models.conf](https://github.com/LongQT-sea/OpenCore-ISO/blob/main/cpu-models.conf) is required)*
* **BIOS**: OVMF (UEFI)
* **Add EFI Disk**: ✅ Enabled
* **Pre-Enroll Keys**: ❌ Untick to disable Secure Boot
* **QEMU Guest Agent**:

  * ✅ Enable for macOS 10.14 – macOS 26
  * ❌ Leave as default for macOS 10.4 – macOS 10.13

---

### 5. Hard Disk

The **disk bus type** depends on your needs:

* **VirtIO** – Better performance
* **SATA** – Supports TRIM/Discard for more efficient storage usage

| macOS Version            | Supports Bus Type       |
| ------------------------ | ----------------------- |
| macOS 10.15 – macOS 26   | `SATA` / `VirtIO Block` |
| macOS 10.4 – macOS 10.14 | `SATA`                  |

> [!Tip]
> Choosing `SATA` with ✅ SSD emulation and ✅ Discard enabled is recommended, as it automatically supports TRIM for more efficient storage usage.

---

### 6. CPU

#### Cores

* Choose based on your hardware: 1 / 2 / 4 / 8 / 16 / 32 / 64

> [!TIP]
> * For 6 cores: choose 2 cores and 3 sockets
> * For 12 cores: choose 4 cores and 3 sockets
> * For 20 cores: choose 4 cores and 5 sockets
> * For 24 cores: choose 8 cores and 3 sockets

#### Type (Model)

| macOS Version            | Recommended CPU Type                               |
| ------------------------ | -------------------------------------------------- |
| macOS 10.11 – macOS 26   | `Skylake-Client-v4`, `Skylake-Server-v4` (AVX-512) |
| macOS 10.4 – macOS 10.10 | `Penryn`                                           |

> [!NOTE]
> **AMD CPUs:**
> * For **macOS 10.4 – macOS 12**, tick ✅ **Advanced**, and under **Extra CPU Flags**, turn off `pcid` and `spec-ctrl`. [^amdcpu]
> * For **macOS 13 – macOS 26**, set the CPU manually via the Proxmox VE Shell, example:
>
>   ```
>   qm set [VMID] --args "-cpu Skylake-Client-v4,vendor=GenuineIntel"
>   qm set [VMID] --args "-cpu Skylake-Server-v4,vendor=GenuineIntel"
>   ```
> ---
>  **Intel CPUs:**
> * Intel HEDT / E5-2xxx v3/v4 need to override CPUID `model`[^intel-hedt], example:
>
>   ```
>   qm set [VMID] --args "-cpu Broadwell-noTSX,vendor=GenuineIntel,model=158"
>   qm set [VMID] --args "-cpu Haswell-noTSX,vendor=GenuineIntel,model=158"
>   ```
> * Intel Haswell desktops need to override `stepping` when using `Haswell-noTSX`[^haswell]:
>   ```
>   qm set [VMID] --args "-cpu Haswell-noTSX,vendor=GenuineIntel,stepping=3"
>   ```
> * Avoid using [`host`](https://browser.geekbench.com/v6/cpu/14313138) passthrough CPU types — they can be **~30% slower (single-core)** and **~44% slower (multi-core)** compared to [`recommended`](https://browser.geekbench.com/v6/cpu/14205183) CPU types.

For more details, see [QEMU CPU Guide – macOS Guests](https://github.com/LongQT-sea/qemu-cpu-guide?#macos-guests).

---

### 7. Memory

* **RAM**: Minimum 2 GB (4 GB or more recommended)
* Disable ❌ Ballooning Device

---

### 8. Network

Choose the correct adapter based on macOS version:

| macOS Version       | Network Adapter    |
| ------------------- | ------------------ |
| macOS 11 – 26       | `VirtIO` (default) |
| macOS 10.11 – 10.15 | `VMware vmxnet3`   |
| macOS 10.4 – 10.10  | `Intel E1000`      |

---

### 9. Finalize

Add an **additional CD/DVD drive** for the macOS installer or Recovery ISO, then start the VM to proceed with the installation of macOS.
> [!Tip]
> * First-time installation? Open **Disk Utility** to format your hard disk before proceeding with the macOS installation.
> * Skip the iCloud login screen if prompted, see [Post-Install](#post-install) for iCloud setup instructions.

### 10. Troubleshooting
If you encounter boot issues, check:
* Secure Boot is **disabled** (`Pre-Enroll Keys` unticked)
* The ISO is mounted as a **CD/DVD**, not a disk
* Try different **CPU model**
* macOS 10.4 Tiger requires USB mouse. Run this in the VM Monitor tab: `device_add usb-mouse`

---

## Post-Install

### 1. Install OpenCore onto the macOS startup disk (macOS 10.11 – macOS 26)
   * After macOS installation is complete, open **`LongQT-OpenCore`** on the Desktop and run **`Mount_EFI.command`** to mount the EFI partition on the macOS startup disk.
   * Copy the **EFI** folder from **`LongQT-OpenCore/EFI_RELEASE/`** to the mounted EFI partition. This ensures that macOS will boot using the OpenCore EFI stored on the macOS startup disk in future startups.
   * Run **`Install_Python3.command`** to install Python 3, many apps and scripts need it.
   * Copy **`Mount_EFI.command`**, **`ProperTree`**, and **`GenSMBIOS`** to the Desktop for later use when you need to edit **`config.plist`**.
   * You can now remove the **LongQT-OpenCore** ISO CD/DVD from the VM **Hardware** tab.

### 2. To enable iCloud, iMessage, and other iServices:
   * Follow [Dortania iServices guide](https://dortania.github.io/OpenCore-Post-Install/universal/iservices.html)
   * For macOS 15 and macOS 26, need to install [VMHide.kext](https://github.com/Carnations-Botanica/VMHide)

### 3. For smooth GUI performance and 3D acceleration

* Pass through a supported Intel iGPU or dGPU:

  * **Intel iGPU passthrough:** see [LongQT-sea/intel-igpu-passthru](https://github.com/LongQT-sea/intel-igpu-passthru)
  * **dGPU passthrough:** ensure you have a supported dGPU, see [Dortania GPU Buyers Guide](https://dortania.github.io/GPU-Buyers-Guide/modern-gpus/amd-gpu.html#native-amd-gpus)

> [!IMPORTANT]
> PCIe/dGPU passthrough on a **q35** machine requires:
> * Disable Resizable BAR / Smart Access Memory in UEFI/BIOS.
> * Disable QEMU’s ACPI-based PCI hotplug (revert to native PCIe hotplug) by running this in the Proxmox shell:

> ```
> clear; read -p "Enter your macOS VM ID number: " VMID; \
> ARGS="$(qm config $VMID --current | grep ^args: | cut -d' ' -f2-)"; \
> qm set $VMID -args "$ARGS -global ICH9-LPC.acpi-pci-hotplug-with-bridge-support=off"
> ```

> [!Tip]
> On modern macOS versions, if you need a dummy virtual sound device (e.g., for **Parsec, Sunshine/MoonLight**), run this in Proxmox shell:
> ```
> clear; read -p "Enter your macOS VM ID number: " VMID; \
> ARGS="$(qm config $VMID --current | grep ^args: | cut -d' ' -f2-)"; \
> qm set $VMID -args "$ARGS -device virtio-sound,audiodev=dummy -audiodev none,id=dummy"
> ```

> [!Tip]
> To disable SIP, press <kbd>Spacebar</kbd> in the OpenCore boot menu and select the "Toggle SIP" option.

---

## macOS Tahoe Cursor Freeze Fix

On **macOS 26**, the cursor may randomly freeze. A temporary workaround is to toggle **Use tablet for pointer** in VM’s **Options** tab.

A better fix is to use **`virtio-tablet-pci`**. To do this, disable **Use tablet for pointer** in VM’s **Options** tab, then run this in Proxmox shell:
   ```
   clear; read -p "Enter your macOS VM ID number: " VMID; \
   ARGS="$(qm config $VMID --current | grep ^args: | cut -d' ' -f2-)"; \
   qm set $VMID -args "$ARGS -device virtio-tablet"
   ```
> [!Note]
> With **`virtio-tablet-pci`**, middle-click on your real mouse acts as a right-click in the VM.
 
The most reliable solution is to passthrough a physical mouse and keyboard together with an iGPU or dGPU.

Alternatively, use a remote desktop solution, e.g. **VNC Screen Sharing** (Settings → General → Sharing) or **Chrome Remote Desktop**.

---

## Contributing
Contributions are welcome! Please feel free to submit a pull request. For major changes, open a **Discussion** first to discuss what you would like to change.

## Credits
- [Acidanthera](https://github.com/acidanthera) team for OpenCorePkg and kexts.
- [CorpNewt](https://github.com/corpnewt) for ProperTree, GenSMBIOS.
- [Dortania](https://dortania.github.io/) for comprehensive guides.

## License & Attribution

This project is licensed under the MIT License (see [LICENSE](LICENSE) file). This also includes components from Acidanthera and other developers, each with their own licenses. All third-party components retain their original licenses.

**If you create content using this project** (videos, blog posts, tutorials, articles):
- Please link back to this repository: `https://github.com/LongQT-sea/OpenCore-ISO`
- Mention that detailed **instructions** are in this GitHub repo.

Thank you for respecting the work that went into this project!

## Disclaimer
This project is provided “as‑is”, without any warranty, for educational and research purposes. In no event shall the authors or contributors be liable for any direct, indirect, incidental, special, or consequential damages arising from use of the project, even if advised of the possibility of such damages.

All product names, trademarks, and registered trademarks are property of their respective owners. All company, product, and service names used in this repository are for identification purposes only.

[^legacy]: No messy custom args needed (no OSK strings, no lengthy `-cpu` parameters) and freely configure CPU core count on AMD CPUs.
[^osx]: Tested on Proxmox VE 9.
[^amdcpu]: The `pcid` and `spec-ctrl` flags are Intel-only CPU features.
[^intel-hedt]: Override the CPUID model to one used in real Macs (e.g., `model=158` → Coffee Lake CPUID model).
[^haswell]: QEMU Haswell-noTSX CPU model has `stepping=4`, but macOS expects `stepping=3`.