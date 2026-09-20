# MediaTek MT7668 SDIO Wi-Fi Driver for Linux 6.18+ (Amlogic G12A / Armbian)

Patched out-of-tree Linux kernel driver for the **MediaTek MT7668** SDIO 802.11ac Wi-Fi combo module, updated for modern Linux kernels (Linux 6.18+) and Amlogic TV boxes.

---

## 🚀 Verified Proof of Operation (ZTE B860H V5)

This driver is tested and verified on **ZTE B860H V5** running **Armbian Linux 6.18.48-ophub**:
- **Clean dmesg**: Zero `[wlan]` trace log spam (`DBG_DISABLE_ALL_LOG 1`).
- **Power Stability**: Low-power auto-sleep disabled (`CFG_ENABLE_FULL_PM 0`) to prevent SDIO card removal timeouts (`error -110`).
- **DKMS Support**: Automatically compiles and updates across kernel upgrades via DKMS.
- **Verified Performance**:
  - **Upload**: **94.6 Mbps**
  - **Download**: **64.2 Mbps**
  - **Latency**: **1.06 ms - 1.51 ms**

```text
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec   113 MBytes  94.6 Mbits/sec    0   sender
[  5]   0.00-10.00  sec   113 MBytes  94.6 Mbits/sec        receiver
```

---

## 📦 Installation Methods

### Option A: Install via Debian Package (.deb)
Download `mt7668-dkms_1.0.0_all.deb` from [Releases](https://github.com/junglon/mt7668-driver/releases) and run:
```bash
sudo dpkg -i mt7668-dkms_1.0.0_all.deb
```

### Option B: Build & Install Debian Package from Source
```bash
git clone https://github.com/junglon/mt7668-driver.git
cd mt7668-driver
chmod +x build-deb.sh
./build-deb.sh
sudo dpkg -i mt7668-dkms_1.0.0_all.deb
```

---

## 🛠 Key Patches & Fixes Applied

1. **Level 1 Translation Fault Fix (`gl_os.h`)**: Expanded `ai4TxPendingFrameNumPerQueue` and `arNetInterfaceInfo` bounds to `HW_BSSID_NUM + 1` to resolve 6.18+ kernel paging panics.
2. **Amlogic G12A Bounce Buffer Clamping (`config.h` & `gl_init.c`)**: Clamped `CFG_TX_MAX_PKT_SIZE` and MTU to 1408 bytes to avoid SDIO DMA FIFO overflows.
3. **Log Spam Suppression (`debug.h`)**: Set `DBG_DISABLE_ALL_LOG 1` to ensure clean kernel logs without flooding `dmesg`.
4. **Power Management Stability (`config.h`)**: Set `CFG_ENABLE_FULL_PM 0` to maintain active SDIO clock synchronization.
5. **DKMS Integration (`dkms.conf` & `Makefile`)**: Added `CONFIG_MT7668 ?= m` for clean out-of-tree DKMS package generation.

---

## 📜 License
GPL-2.0 / MediaTek Proprietary Base.

---

## 🤝 Credits & References

- **MediaTek Inc.**: Original MT6632/MT7668 combo driver codebase.
- **Armbian & Ophub**: Kernel headers, build environment, and Amlogic G12A kernel support (`Linux 6.18.48-ophub`).
- **Antigravity**: Built with Google Antigravity using Gemini Flash 3.6 ⚡
