# MediaTek MT7668 SDIO Wi-Fi Driver for Linux 6.18+ (Amlogic G12A / Armbian)

Patched out-of-tree Linux kernel driver for the **MediaTek MT7668** SDIO 802.11ac Wi-Fi / Bluetooth combo module, specifically modified for modern Linux kernels (Linux 6.18+) and Amlogic G12A (S905X2) TV boxes such as **ZTE B860H V5**.

---

## Key Patches & Fixes Applied

### 1. Fix Level 1 Translation Fault Kernel Panic (`gl_os.h`)
- **Problem**: Indexing `ai4TxPendingFrameNumPerQueue[HW_BSSID_NUM]` and `arNetInterfaceInfo[HW_BSSID_NUM]` caused array out-of-bounds memory corruption when `HW_BSSID_NUM = 4`, leading to paging request panics on Linux 6.18+.
- **Fix**: Expanded array bounds to `HW_BSSID_NUM + 1`:
  ```c
  INT_32 ai4TxPendingFrameNumPerQueue[HW_BSSID_NUM + 1][CFG_MAX_TXQ_NUM];
  NET_INTERFACE_INFO_T arNetInterfaceInfo[HW_BSSID_NUM + 1];
  ```

### 2. Amlogic G12A Bounce Buffer FIFO Overflow Clamping (`config.h` & `gl_init.c`)
- **Problem**: Amlogic G12A `meson-gx-mmc` controller fails single SDIO DMA transfers larger than ~1.5KB, triggering hardware TX FIFO overflows (`WASR = 0x00000002`).
- **Fix**: Clamped maximum TX packet size and image block size to 1408 bytes:
  - `CFG_TX_MAX_PKT_SIZE = 1408`
  - `CMD_PKT_SIZE_FOR_IMAGE = 1408`
  - Set interface default MTU = 1408 bytes in `gl_init.c`: `prGlueInfo->prDevHandler->mtu = 1408;`

### 3. RX Enhancement & Handshake Timeout (`config.h`)
- **Problem**: `WHCR_RX_ENHANCE_MODE_EN` suppressed frame length reporting in `MCR_WRPLR`, causing polling timeouts (`halRxWaitResponse`) during firmware handshakes.
- **Fix**: Disabled `CFG_SDIO_RX_ENHANCE` and `CFG_SDIO_TX_AGG`.

---

## Build & Installation Instructions

### Prerequisites
Make sure kernel headers and build utilities are installed:
```bash
sudo apt update
sudo apt install build-essential linux-headers-$(uname -r) git
```

### 1. Building and Installing the Module
```bash
# Clone repository
git clone https://github.com/junglon/mt7668-driver.git
cd mt7668-driver

# Build kernel module
make

# Install module into kernel drivers directory
sudo make install
sudo depmod -a
```

### 2. Loading the Driver
```bash
sudo modprobe wlan_mt7668
```

To auto-load on system boot:
```bash
echo wlan_mt7668 | sudo tee /etc/modules-load.d/wlan_mt7668.conf
```

---

## Verified Performance (ZTE B860H V5 / Linux 6.18.48-ophub)

- **Upload Speed**: **94.6 Mbps**
- **Download Speed**: **64.2 Mbps**
- **Latency**: **1.06 ms - 1.51 ms**

```text
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec   113 MBytes  94.6 Mbits/sec    0   sender
[  5]   0.00-10.00  sec   113 MBytes  94.6 Mbits/sec        receiver
```

---

## Device Tree (DTS) Reference

Included in `dts/meson-g12a-b860h-v5.dts` is the updated Device Tree source for ZTE B860H V5:
- `pwm@19000` (`status = "okay"`) providing `wifi32k` (32.768 kHz clock).
- `sdio-pwrseq` on `GPIOX_6` with 200ms power-off delay and 500ms post-power-on delay.
- `meson-ir` NEC remote receiver on `GPIOAO_5`.

---

## License
GPL-2.0 / MediaTek Proprietary Driver Base.

---

## Credits

*Built with Antigravity using Gemini 3.6 Flash :)*
