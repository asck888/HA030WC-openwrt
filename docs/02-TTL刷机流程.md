# 02 · TTL 刷机流程（Econet EN7528 家族）

> 本机是 SPI NAND（W25N01G 128MB）+ free bootbase，OpenWrt 用 UBI 文件系统。
> 串口参数 115200 8N1。上电看到 `Press any key in 3 secs to enter boot command mode` 时按回车进 bootloader。

## 一、接线

USB-TTL 模块（CH340/CP2102）接主板 J431 排针：

| 路由器针脚 | USB-TTL |
|-----------|---------|
| GND | GND |
| TXD | RXD |
| RXD | TXD |
| VCC | **不接**（路由器自己供电） |

## 二、先备份（最重要）

进原厂系统后第一件事，把整片 128MB NAND 读出来备份：

```sh
cat /proc/mtd                       # 看分区
dd if=/dev/mtd0 of=/tmp/full_backup.bin   # 整片备份（按实际 mtd 设备改）
# 用 tftp / u 盘把 full_backup.bin 拷出来保存
```

## 三、进 bootloader 命令行

上电 3 秒内按任意键，进入 tcboot/free-bootbase 命令行：

```
printenv          # 看环境变量
setenv ipaddr 192.168.1.1
setenv serverip 192.168.1.2
```

## 四、先内存启动验证（不写 flash）

电脑开 tftp 服务器（IP 192.168.1.2），把编译出的 `.bin` 放进去：

```
tftpboot 0x80002000 openwrt-econet-en7528-generic-rootfsfs-squashfs-sysupgrade.bin
bootm 0x80002000
```

> 能进 OpenWrt 命令行再做下一步；起不来就换本仓库的 `nokia_ha030wc` 镜像。

## 五、正式写入

OpenWrt 跑起来后，把 sysupgrade 镜像放到 `/tmp`：

```sh
sysupgrade -n /tmp/openwrt-econet-en7528-nokia_ha030wc-squashfs-sysupgrade.bin
```

## 六、刷完后

1. 电脑网卡接 LAN 口，设成 192.168.8.x 同网段（或上级路由网段）。
2. 浏览器访问 `http://192.168.8.1`，就是极简配置页。
3. 改 SSID/密码/LAN IP，点"一键换 MAC + 统一 SSID"。

## 七、核对与排错

- `ls /sys/class/net/`：确认网口名和 DTS 里 lan1/lan2/wan 对得上。
- `lspci`：确认 MT7613BEN / MT7603 被识别。
- `wifi detect`：能生成 wireless 配置。
- 不对就改 DTS 重新编译，或回原厂固件（用第二步备份）。

## 八、救砖

- TTL 还能进 bootloader 就能 TFTP 重刷。
- bootloader 也挂了：拆 W25N01G，用 CH341A 编程器写回备份。
