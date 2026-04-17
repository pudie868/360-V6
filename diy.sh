#!/bin/bash
# ============================================================
# 适配 ImmortalWrt Master + 360 V6 的最佳软件源配置
# ============================================================

# 1. 核心操作：引入 ImmortalWrt 官方额外的软件源
# 这个源包含了: docker, sing-box, lucky, smartdns 等大量主流插件
# 且完美适配最新内核和 aarch64 架构
sed -i '1i src-git-full extra_packages https://github.com/immortalwrt/packages.git' feeds.conf.default

# 2. 确保卢西 (Luci) 界面是官方最新的，包含 HomeProxy 等新插件
sed -i '2i src-git-full extra_luci https://github.com/immortalwrt/luci.git' feeds.conf.default

# 3. 引入 routing 源 (包含代理相关组件)
sed -i '3i src-git-full extra_routing https://github.com/immortalwrt/routing.git' feeds.conf.default

# 4. 执行更新 (这一步会把上面定义的源下载下来)
./scripts/feeds update -a
./scripts/feeds install -a

# 5. 针对 360 V6 的特殊补丁（如果遇到插件冲突，可在此处手动强制覆盖）
# 比如强制使用最新的 Lucky
# rm -rf feeds/extra_packages/net/lucky
# git clone https://github.com/sirpdboy/luci-app-lucky.git feeds/extra_packages/net/lucky
