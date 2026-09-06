#!/bin/bash
set -e
cd openwrt
# Insert device definition before last line (BuildImage eval)
total=$(wc -l < target/linux/econet/image/en7528.mk)
head -n $((total - 1)) target/linux/econet/image/en7528.mk > /tmp/part1.mk
cat ../dts/en7528-ha030wc.mk >> /tmp/part1.mk
tail -n 1 target/linux/econet/image/en7528.mk >> /tmp/part1.mk
cp /tmp/part1.mk target/linux/econet/image/en7528.mk
echo "=== Check ==="
grep -c "nokia_ha030wc" target/linux/econet/image/en7528.mk
