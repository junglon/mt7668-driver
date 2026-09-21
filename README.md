# MediaTek MT7668 SDIO Wi-Fi Driver for Linux 6.x (6.12 LTS, 6.18+) (Amlogic G12A / Armbian)

Patched out-of-tree Linux kernel driver for the **MediaTek MT7668** SDIO 802.11ac Wi-Fi combo module, updated for modern Linux kernels (Linux 6.12 LTS, 6.18+) on Debian Bookworm, Ubuntu Noble, and Amlogic TV boxes (e.g. ZTE B860H V5).

---

## 🚀 Verified Proof of Operation (ZTE B860H V5)

This driver is tested and verified on **ZTE B860H V5 (Amlogic G12A / S905X2)** running both **Ubuntu 24.04 Noble** and **Debian 12 Bookworm** (`Linux 6.12.107-ophub` & `6.18.48-ophub`):

- **Clean dmesg**: Zero `[wlan]` trace log spam (`DBG_DISABLE_ALL_LOG 1`).
- **Power Stability**: Low-power auto-sleep disabled (`CFG_ENABLE_FULL_PM 0`) to maintain SDIO clock synchronization.
- **DKMS Support**: Automatically compiles and updates across kernel upgrades via DKMS.
- **Universal Compiler Compatibility**: Works cleanly with GCC 12, 13, 14, and 15 without kernel header mismatch errors (`CONFIG_CC_HAS_MIN_FUNCTION_ALIGNMENT=`).
- **Verified Throughput (iperf3 to local gigabit server)**:
  - **5 GHz Band (Channel 157, 405-780 Mbps link rate)**:
    - **Upload (TX)**: **94.2 Mbps** (0 retransmits)
    - **Download (RX)**: **50.2 Mbps**
  - **2.4 GHz Band (Channel 6)**:
    - **Upload (TX)**: **81.2 Mbps** (0 retransmits)
    - **Download (RX)**: **26.9 Mbps**

```text
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec   112 MBytes  94.2 Mbits/sec    0   sender
[  5]   0.00-10.00  sec   110 MBytes  92.5 Mbits/sec        receiver
```

---

## 📦 Installation Methods

### Option A: Install via Debian Package (.deb) — Recommended
The `.deb` package installs the driver module via DKMS and automatically configures the Bluetooth blacklist and reboot stability service:

```bash
sudo apt update
sudo apt install -y dkms build-essential linux-headers-$(uname -r) wget
wget https://github.com/junglon/mt7668-driver/releases/download/v1.0.2/mt7668-dkms_1.0.2_all.deb
sudo dpkg -i mt7668-dkms_1.0.2_all.deb
```

### Option B: Build & Install Debian Package from Source
```bash
git clone https://github.com/junglon/mt7668-driver.git
cd mt7668-driver
chmod +x build-deb.sh
./build-deb.sh
sudo dpkg -i mt7668-dkms_1.0.2_all.deb
```

---

## 🔧 Essential System Configurations for TV Boxes

On Amlogic TV boxes such as the ZTE B860H V5, two hardware design traits require specific OS configurations, which are bundled in `system/` and automatically applied by the `.deb` package:

### 1. Bluetooth Blacklist (`system/etc/modprobe.d/blacklist-mt7668-bluetooth.conf`)
- **Why it is needed**: The MT7668 is a dual Wi-Fi + Bluetooth combo chip. Under Linux, the upstream kernel module `btmtksdio` attempts to probe Bluetooth on SDIO Function 2. On many TV box boards without dedicated MTK BT firmware loading or specific UART routing, `btmtksdio` times out waiting for firmware status:
  ```text
  Bluetooth: hci0: Execution of wmt command timed out
  Bluetooth: hci0: Failed to query firmware status (-110)
  ```
  These repeated timeouts stall the SDIO bus and flood kernel logs.
- **Solution**: Blacklisting `btmtksdio` and `btmtk` prevents the upstream driver from binding to Function 2, leaving the SDIO bus dedicated entirely and cleanly to Wi-Fi (`wlan_mt7668`).

### 2. SDIO Quiesce Shutdown Service (`system/etc/systemd/system/mt7668-shutdown.service`)
- **Why it is needed**: The MT7668 module on the ZTE B860H V5 is powered by always-on power rails (`VDDAO_3V3` and `VDDAO_1V8`). When a soft/warm reboot is executed (`reboot`), the Amlogic SoC resets while the MT7668 chip remains continuously powered. If the SDIO interface is not cleanly disconnected prior to SoC reset, the MT7668 internal SDIO controller remains in an active/busy state and fails to respond to CMD5 probe queries after reboot (`error -110`). This causes Wi-Fi to disappear until a hard AC power cycle.
- **Solution**: The `mt7668-shutdown.service` executes during shutdown and reboot targets:
  ```bash
  if [ -d /sys/bus/platform/drivers/meson-gx-mmc/ffe03000.sd ]; then
      echo ffe03000.sd > /sys/bus/platform/drivers/meson-gx-mmc/unbind
  fi
  ```
  This unbinds the SDIO host controller (`ffe03000.sd`) immediately before system reset, cleanly terminating the SDIO session and allowing the MT7668 to be re-detected on warm reboot with 100% reliability.

---

## 🛠 Key Driver Patches & Fixes Applied

1. **Level 1 Translation Fault Fix (`gl_os.h`)**: Expanded `ai4TxPendingFrameNumPerQueue` and `arNetInterfaceInfo` bounds to `HW_BSSID_NUM + 1` to resolve 6.18+ kernel paging panics.
2. **Amlogic G12A Bounce Buffer Clamping (`config.h` & `gl_init.c`)**: Clamped `CFG_TX_MAX_PKT_SIZE` and MTU to 1408 bytes to avoid SDIO DMA FIFO overflows on `meson-gx-mmc`.
3. **Log Spam Suppression (`debug.h`)**: Set `DBG_DISABLE_ALL_LOG 1` and eliminated redundant register polling loops to ensure clean kernel logs without flooding `dmesg`.
4. **Power Management Stability (`config.h`)**: Set `CFG_ENABLE_FULL_PM 0` to maintain active SDIO clock synchronization.
5. **Universal Compiler Compatibility (`Makefile` & `dkms.conf`)**: Injected `CONFIG_CC_HAS_MIN_FUNCTION_ALIGNMENT=` to bridge GCC 12/13/14 hosts with GCC 15 kernel builds.

---

## 📜 License
GPL-2.0 / MediaTek Proprietary Base.

---

## 🤝 Credits & References

- **MediaTek Inc.**: Original MT6632/MT7668 combo driver codebase.
- **Armbian & Ophub**: Kernel headers, build environment, and Amlogic G12A kernel support (`Linux 6.12 LTS` / `6.18+`).
- **Antigravity**: Built with Google Antigravity using Gemini Flash 3.6 ⚡
