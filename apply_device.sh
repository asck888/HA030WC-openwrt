#!/bin/bash
set -e
cd openwrt
# Insert device definition before the BuildImage eval line
awk '/\$\(eval \$\(call BuildImage\)\)/{while((getline line < "../dts/en7528-ha030wc.mk") > 0) print line}1' target/linux/econet/image/en7528.mk > /tmp/en7528_new.mk
cp /tmp/en7528_new.mk target/linux/econet/image/en7528.mk
echo "=== Check ==="
grep -c "nokia_ha030wc" target/linux/econet/image/en7528.mk
