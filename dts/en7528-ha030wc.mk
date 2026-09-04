# HA030WC 设备定义
# 追加到 openwrt/target/linux/econet/image/en7528.mk 末尾

define Device/nokia_ha030wc
  $(call Device/tclinux-ubi)
  DEVICE_VENDOR := Nokia Bell
  DEVICE_MODEL := HA030WC
  DEVICE_DTS := en7528_nokia_ha030wc
  FACTORY_SIZE := 32m
  TRX_LOADADDR := 0x80002000
  KERNEL := kernel-bin | append-dtb | tclinux-free-bootbase-jump | lzma | \
    kernel-trx
  DEVICE_PACKAGES := kmod-mt7603 kmod-mt7615e kmod-mt7663-firmware-ap
endef
TARGET_DEVICES += nokia_ha030wc

# 硬件确认：
#   2.4G = MT7603 → kmod-mt7603
#   5G   = MT7663 → kmod-mt7615e + kmod-mt7663-firmware-ap
#   SoC  = EN7561DU（bootloader 报 EN7528）
#   RAM  = 128MB DDR3
#   Flash= Winbond W25N01G 128MB SPI NAND
