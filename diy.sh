#!/bin/bash
# 添加 ImmortalWrt 官方额外源 (包含 docker, lucky 等)
# 注意：不要锁定到 23.05，保持与主分支一致

# 添加 extra_packages 源 (包含 sing-box, lucky 等)
echo 'src-git extra_packages https://github.com/immortalwrt/packages.git;master' >> feeds.conf.default
echo 'src-git extra_luci https://github.com/immortalwrt/luci.git;master' >> feeds.conf.default

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a
