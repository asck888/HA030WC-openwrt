#!/bin/sh
# ============================================================
# HA030WC 一键脚本：重新生成无线 MAC + 把 2.4G/5G 设成同一 SSID/密码
# 用法：
#   ap-mac-sync.sh                 # 沿用当前 SSID/密码，只换 MAC
#   ap-mac-sync.sh "我的WiFi" "密码123"   # 同时改 SSID/密码 + 换 MAC
# 用途：多台 AP 做无缝漫游时，统一 SSID、各自不同 MAC，避免客户端粘死旧 AP。
# ============================================================
. /lib/functions.sh

# 生成一个“本地管理位”随机 MAC（第二字节为 2/6/A/E，合法且不冲突厂商 OUI）
rand_mac() {
	m=$(od -An -N6 -tx1 /dev/urandom | tr -d ' \n')
	b1=$(printf '%02x' $(( 0x$(printf '%s' "$m" | cut -c1-2) | 0x02 )))
	rest=$(printf '%s' "$m" | cut -c3-12)
	printf '%s:%s\n' "$b1" "$(printf '%s' "$rest" | sed 's/\(..\)/\1:/g; s/:$//')"
}

SSID="$1"
KEY="$2"

# 没传 SSID 就沿用当前 2.4G 的
[ -z "$SSID" ] && SSID=$(uci -q get wireless.@wifi-iface[0].ssid)
[ -z "$KEY" ]  && KEY=$(uci -q get wireless.@wifi-iface[0].key)

MAC0=$(rand_mac)
MAC1=$(rand_mac)

# 两个频段分别用不同 MAC（同 SSID）
uci -q set wireless.@wifi-iface[0].macaddr="$MAC0"
uci -q set wireless.@wifi-iface[1].macaddr="$MAC1"

# 统一 SSID/密码
[ -n "$SSID" ] && {
	uci -q set wireless.@wifi-iface[0].ssid="$SSID"
	uci -q set wireless.@wifi-iface[1].ssid="$SSID"
}
[ -n "$KEY" ] && {
	uci -q set wireless.@wifi-iface[0].key="$KEY"
	uci -q set wireless.@wifi-iface[1].key="$KEY"
}

uci commit wireless
wifi reload >/dev/null 2>&1

echo "SSID=$SSID  MAC_2G=$MAC0  MAC_5G=$MAC1"
