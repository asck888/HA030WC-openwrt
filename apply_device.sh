#!/bin/bash
set -e
cd openwrt
# Insert device definition BEFORE BuildImage eval
python3 -c "
content = open('target/linux/econet/image/en7528.mk').read()
dev = open('../dts/en7528-ha030wc.mk').read()
content = content.replace('\$(eval \$(call BuildImage))', dev + '\n\$(eval \$(call BuildImage))')
open('target/linux/econet/image/en7528.mk','w').write(content)
"
