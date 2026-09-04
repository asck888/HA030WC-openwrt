#!/bin/bash
# ============================================================
# HA030WC (Econet EN7561DU / bootloader 报 EN7528) OpenWrt 编译脚本
# 运行环境：Ubuntu 22.04/24.04 x86_64（物理机或 WSL2）
# 用法：
#   chmod +x build-econet.sh
#   ./build-econet.sh
#
# 硬件（TTL 日志确认）：
#   SoC  EN7561DU（EN7528 家族）  RAM 128MB
#   Flash Winbond W25N01G 128MB SPI NAND
#   WiFi MT7613BEN(5G) + MT7603(2.4G)
#   Bootloader: free bootbase（对应 tclinux-free-bootbase-jump）
# ============================================================
set -e

WORKDIR="$HOME/openwrt-ha030wc"
REPO="https://github.com/openwrt/openwrt.git"
BRANCH="main"          # econet 只在 master；稳定版 23.05/24.10 没有

# 1. 安装编译依赖（Ubuntu/Debian）
sudo apt-get update
sudo apt-get install -y build-essential clang flex bison g++ gawk \
  gcc-multilib g++-multilib gettext git libncurses-dev libssl-dev \
  python3 python3-setuptools rsync swig unzip zlib1g-dev file wget \
  libelf-dev device-tree-compiler

# 2. 拉取源码
if [ ! -d "$WORKDIR/openwrt" ]; then
  git clone -b "$BRANCH" --depth 1 "$REPO" "$WORKDIR/openwrt"
fi
cd "$WORKDIR/openwrt"
git pull --ff-only || true

# 3. 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a

PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# 4. 把本项目的 files/ 定制层覆盖进去（AP 配置 + 极简网页 + MAC 脚本）
rm -rf "$WORKDIR/openwrt/files"
cp -r "$PROJ_DIR/files" "$WORKDIR/openwrt/files"

# 5. 安装 HA030WC 专用 DTS 和设备定义
cp "$PROJ_DIR/dts/en7528_nokia_ha030wc.dts" target/linux/econet/dts/
cat "$PROJ_DIR/dts/en7528-ha030wc.mk" >> target/linux/econet/image/en7528.mk

# 6. 写 .config
#    先选 en7528_generic（通用镜像，可能直接启动）；
#    若 generic 能启动但内存/网口不对，再把 GENERIC 换成 nokia_ha030wc。
cat > .config <<EOF
CONFIG_TARGET_econet=y
CONFIG_TARGET_econet_en7528=y
CONFIG_TARGET_MULTI_PROFILE=y
CONFIG_TARGET_DEVICE_econet_en7528_GENERIC=y
CONFIG_TARGET_DEVICE_econet_en7528_nokia_ha030wc=y
CONFIG_PACKAGE_uhttpd=y
CONFIG_PACKAGE_uhttpd-mod-ubus=n
CONFIG_PACKAGE_luci=n
CONFIG_PACKAGE_uci=y
# 2.4G
CONFIG_PACKAGE_kmod-mt7603=y
# 5G (MT7613BEN)
CONFIG_PACKAGE_kmod-mt76x2e=y
CONFIG_PACKAGE_kmod-mt76x2-common=y
CONFIG_PACKAGE_mt76x2e-firmware=y
CONFIG_PACKAGE_wpad-mbedtls=y
# 精简：不要 PPP/DHCPv6（纯 AP 用不到）
CONFIG_PACKAGE_odhcp6c=n
CONFIG_PACKAGE_odhcpd-ipv6only=n
CONFIG_PACKAGE_ppp=n
CONFIG_PACKAGE_kmod-ppp=n
CONFIG_PACKAGE_kmod-pppoe=n
EOF

make defconfig

# 7. 编译（首次约 1~2 小时）
make download -j8
make -j"$(nproc)" V=s

echo "============================================================"
echo "编译完成！固件在："
ls -lh bin/targets/econet/en7528/*.bin 2>/dev/null || echo "（未找到 .bin，请检查上面的编译日志）"
echo "刷入方式见 docs/02-TTL刷机流程.md"
