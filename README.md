# 诺基亚贝尔 HA030WC · OpenWrt AP 固件定制包

把这台中国移动定制的 HA030WC 改成一台**纯 AP**：只保留无线和 LAN 设置，网页极简，带一键改 MAC + 同 SSID。

## 硬件（主板照片 + TTL 日志确认）

- 主控：**Econet EN7561DU**（bootloader 报 EN7528 家族，mipsel）
- 内存：**128MB DDR3**
- 闪存：**Winbond W25N01G 128MB SPI NAND**
- 无线：MT7613BEN（5G）+ MT7603（2.4G）
- 网口：2×LAN + 1×WAN，全千兆
- Bootloader：free bootbase（对应 OpenWrt 的 tclinux-free-bootbase-jump）

## 现状（好消息）

OpenWrt 主线已有 **`econet/en7528`** 子目标，用的就是 NAND+UBI+free-bootbase，和本机对得上。
本仓库提供：① 直接套用的 `files/` 定制层；② HA030WC 专用 DTS；③ 一条命令编译脚本。
先试 `en7528_generic`，不行再用本仓库 DTS。详见 [`docs/01-硬件识别与现状.md`](docs/01-硬件识别与现状.md)。

## 目录结构

```
HA030WC-openwrt/
├── files/                      # 固件定制层（覆盖进 OpenWrt）
│   ├── etc/config/             # network/dhcp/firewall/system/uhttpd
│   ├── etc/uci-defaults/90-ap-setup   # 首启 AP 配置
│   ├── usr/bin/ap-mac-sync.sh  # 一键改 MAC + 同 SSID
│   └── www/cgi-bin/apconfig    # 极简网页后台
├── dts/
│   ├── en7528_nokia_ha030wc.dts       # HA030WC 专用设备树
│   └── en7528-ha030wc.mk              # 设备定义片段（追加到 en7528.mk）
├── build/
│   ├── build-econet.sh                 # 本地 Linux 编译
│   └── .github/workflows/build.yml     # GitHub Actions 云编译
└── docs/
    ├── 01-硬件识别与现状.md
    ├── 02-TTL刷机流程.md
    └── 流程图.html
```

## 这个固件做了什么

- **纯 AP**：所有网口桥接，不拨号、不 NAT、不发 DHCP，只留静态管理 IP。
- **极简网页**：访问路由器 IP 就是单页，只有「无线设置 / LAN 地址 / 一键工具」，没挂 LuCI。
- **一键改 MAC + 同 SSID**：点一下重新生成两个频段无线 MAC、把 2.4G/5G 设成同一 SSID/密码。

## 怎么用

1. 读 [`docs/01-硬件识别与现状.md`](docs/01-硬件识别与现状.md)。
2. 按 [`docs/02-TTL刷机流程.md`](docs/02-TTL刷机流程.md) 接线、**先 dd 备份整片 NAND**。
3. 编译：本地 `build/build-econet.sh`，或推到 GitHub 用 Actions。
4. 刷完访问 `http://192.168.8.1`。

## 默认值

- 管理 IP：`192.168.8.1`（网页里改）
- 默认 SSID：`HA030WC`，密码：`12345678`（首启后改）

## 注意

- 所有 `.sh` / CGI 必须是 **LF 换行**（本仓库已是 LF）。
- DTS 里网口 label（lan1/lan2/wan）要和 TTL `ls /sys/class/net/` 实际名一致，不通就改。
