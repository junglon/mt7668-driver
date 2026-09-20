CONFIG_MT7668 ?= m
# SPDX-License-Identifier: GPL-2.0-only
#
# MediaTek MT7668 (SDIO) proprietary fullmac WiFi driver
#
# Ported from the MediaTek MT6632/MT7668 combo driver release.
# The driver carries its own 802.11 stack and talks to the kernel
# through cfg80211 (plus legacy wireless extensions).
#

# Keep the chip defines identical to the vendor release: the whole
# combo stack is compiled with -DMT6632 while chips/ contains the
# per-chip glue for both MT6632 and MT7668; the SDIO device table
# selects the right chip at probe time.
ccflags-y += -DLINUX -DMT6632
ccflags-y += -UMT6620 -UMT6628 -UMT5931 -UMT6630

# The vendor codebase intentionally defines hundreds of global
# functions without prototypes; the vendor Kbuild suppresses that
# class of diagnostics, so do the same instead of churning the code.
ccflags-y += -Wno-missing-prototypes
ccflags-y += -Wno-missing-declarations
ccflags-y += -Wno-incompatible-pointer-types

# The vendor code includes a few bare libc headers (e.g. <stddef.h>).
# Since v6.12-ish the kernel no longer adds the compiler's own include
# directory to the search path, so add it back here for this driver.
ccflags-y += -isystem $(shell $(CC) -print-file-name=include)

ccflags-y += -D_HIF_SDIO=1
ccflags-y += -DDBG=0
# Keep ASSERT() non-fatal: with BUILD_QA_DBG=1 every ASSERT() expands to
# panic("Oops"), and a single malformed firmware-download response from a
# wedged chip would take down the whole kernel. Vendor/Armbian builds ship
# this at 0, where a failed assert degrades to a recoverable driver error.
ccflags-y += -DBUILD_QA_DBG=0
ccflags-y += -DCFG_BUILT_IN_DRIVER=0
ccflags-y += -DCFG_SUPPORT_DEBUG_FS=0
ccflags-y += -DWLAN_INCLUDE_PROC
ccflags-y += -DCFG_ANDROID_AOSP_PRIV_CMD
ccflags-y += -DCFG_SUPPORT_AGPS_ASSIST=1
ccflags-y += -DCFG_SUPPORT_TSF_USING_BOOTTIME=1
ccflags-y += -DCFG_SUPPORT_CHNL_CONFLICT_REVISE=0
ccflags-y += -DCFG_SUPPORT_AEE=0
ccflags-y += -DCFG_SUPPORT_PASSPOINT=0
ccflags-y += -DCFG_HS20_DEBUG=0
ccflags-y += -DCFG_ENABLE_GTK_FRAME_FILTER=0
ccflags-y += -DCFG_MET_PACKET_TRACE_SUPPORT=1
ccflags-y += -DCFG_MET_TAG_SUPPORT=0

ccflags-y += -I$(src)/os -I$(src)/os/linux/include
ccflags-y += -I$(src)/include -I$(src)/include/nic -I$(src)/include/mgmt -I$(src)/include/chips
ccflags-y += -I$(src)/os/linux/hif/sdio/include

COMMON_DIR  := common/
OS_DIR      := os/linux/
HIF_DIR     := os/linux/hif/sdio/
NIC_DIR     := nic/
MGMT_DIR    := mgmt/
CHIPS       := chips/

COMMON_OBJS :=	$(COMMON_DIR)dump.o \
		$(COMMON_DIR)wlan_lib.o \
		$(COMMON_DIR)wlan_oid.o \
		$(COMMON_DIR)wlan_bow.o \
		$(COMMON_DIR)wlan_p2p.o

NIC_OBJS :=	$(NIC_DIR)nic.o \
		$(NIC_DIR)nic_tx.o \
		$(NIC_DIR)nic_rx.o \
		$(NIC_DIR)nic_pwr_mgt.o \
		$(NIC_DIR)nic_rate.o \
		$(NIC_DIR)cmd_buf.o \
		$(NIC_DIR)que_mgt.o \
		$(NIC_DIR)nic_cmd_event.o \
		$(NIC_DIR)nic_umac.o \
		$(NIC_DIR)p2p_nic.o

OS_OBJS :=	$(OS_DIR)gl_init.o \
		$(OS_DIR)gl_kal.o \
		$(OS_DIR)gl_bow.o \
		$(OS_DIR)gl_wext.o \
		$(OS_DIR)gl_wext_priv.o \
		$(OS_DIR)gl_ate_agent.o \
		$(OS_DIR)gl_qa_agent.o \
		$(OS_DIR)gl_hook_api.o \
		$(OS_DIR)gl_rst.o \
		$(OS_DIR)gl_cfg80211.o \
		$(OS_DIR)gl_proc.o \
		$(OS_DIR)gl_vendor.o \
		$(OS_DIR)platform.o \
		$(OS_DIR)gl_p2p.o \
		$(OS_DIR)gl_p2p_cfg80211.o \
		$(OS_DIR)gl_p2p_init.o \
		$(OS_DIR)gl_p2p_kal.o

MGMT_OBJS :=	$(MGMT_DIR)ais_fsm.o \
		$(MGMT_DIR)aaa_fsm.o \
		$(MGMT_DIR)assoc.o \
		$(MGMT_DIR)auth.o \
		$(MGMT_DIR)bss.o \
		$(MGMT_DIR)cnm.o \
		$(MGMT_DIR)cnm_timer.o \
		$(MGMT_DIR)cnm_mem.o \
		$(MGMT_DIR)hem_mbox.o \
		$(MGMT_DIR)mib.o \
		$(MGMT_DIR)privacy.o \
		$(MGMT_DIR)rate.o \
		$(MGMT_DIR)rlm.o \
		$(MGMT_DIR)rlm_domain.o \
		$(MGMT_DIR)reg_rule.o \
		$(MGMT_DIR)rlm_obss.o \
		$(MGMT_DIR)rlm_protection.o \
		$(MGMT_DIR)rsn.o \
		$(MGMT_DIR)saa_fsm.o \
		$(MGMT_DIR)scan.o \
		$(MGMT_DIR)scan_fsm.o \
		$(MGMT_DIR)swcr.o \
		$(MGMT_DIR)roaming_fsm.o \
		$(MGMT_DIR)tkip_mic.o \
		$(MGMT_DIR)hs20.o \
		$(MGMT_DIR)tdls.o \
		$(MGMT_DIR)p2p_dev_fsm.o \
		$(MGMT_DIR)p2p_dev_state.o \
		$(MGMT_DIR)p2p_role_fsm.o \
		$(MGMT_DIR)p2p_role_state.o \
		$(MGMT_DIR)p2p_func.o \
		$(MGMT_DIR)p2p_scan.o \
		$(MGMT_DIR)p2p_ie.o \
		$(MGMT_DIR)p2p_rlm.o \
		$(MGMT_DIR)p2p_assoc.o \
		$(MGMT_DIR)p2p_bss.o \
		$(MGMT_DIR)p2p_rlm_obss.o \
		$(MGMT_DIR)p2p_fsm.o \
		$(MGMT_DIR)wapi.o

CHIPS_OBJS :=	$(CHIPS)mt6632.o \
		$(CHIPS)mt7668.o

HIF_OBJS :=	$(HIF_DIR)arm.o \
		$(HIF_DIR)sdio.o \
		$(HIF_DIR)sdio_test_driver_core.o \
		$(HIF_DIR)sdio_test_driver_ops.o \
		$(HIF_DIR)hal_api.o

obj-$(CONFIG_MT7668) += wlan_mt7668.o

wlan_mt7668-objs += $(COMMON_OBJS)
wlan_mt7668-objs += $(NIC_OBJS)
wlan_mt7668-objs += $(OS_OBJS)
wlan_mt7668-objs += $(HIF_OBJS)
wlan_mt7668-objs += $(MGMT_OBJS)
wlan_mt7668-objs += $(CHIPS_OBJS)
