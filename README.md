# OpenWrt for 360 V6 (IPQ6010)


 360 V6 的四核CPU表现相当不错。开始我只是用它运行基础的 homeproxy 代理插件，后来逐渐加入 U 盘支持，可玩性也越来越高。如今功能虽然丰富了不少，但若只用于代理，运行仍然流畅迅速。更让我满意的是它的无线性能——信号强度明显超过我之前用原厂三个路由器组的 Mesh 网络，穿墙表现尤其出色。

---

## 📦 固件说明

| 文件 | 用途 |
|---|---|
| `squashfs-factory.ubi` | 首次刷入，从 breed 或原厂固件刷入 |
| `squashfs-sysupgrade.bin` | 日常升级，LuCI → 系统 → 备份/升级 上传 |
| `initramfs-uImage.itb` | 救砖/临时测试，内存运行，断电消失 |
| `.manifest` | 固件内置软件包清单 |

---

## 🛠️ 内置功能

| 模块 | 组件 |
|---|---|
| 🔐 代理 | HomeProxy + sing-box |
| 🛡️ 去广告 | DNSFilter |
| ⚡ 网络加速 | BBR + ZRAM |
| 🌐 防火墙 | firewall4 + nftables（支持硬件卸载） |
| 🖥️ 界面 | Argon 主题 + 中文 |
| 📶 无线驱动 | ath11k-ahb + IPQ6010 固件 |
| 🖥️ 终端 | ttyd 网页终端 |
| 💾 存储挂载 | block-mount + ext4 + vfat |

---

## 📌 首次刷机步骤

### 从 breed 刷入

1. 断电，按住 reset 键后上电，等待 LED 闪烁后松开
2. 浏览器访问 `192.168.1.1` 进入 breed 控制台
3. 固件更新 → 勾选「固件」→ 选择 `squashfs-factory.ubi`
4. 点击上传，等待自动重启（约 2 分钟）

### 刷入后首次访问

1. 网线连接路由器任意 LAN 口
2. 电脑设置固定 IP：
   - IP：`192.168.2.100`
   - 子网掩码：`255.255.255.0`
   - 网关：`192.168.2.1`
3. 浏览器访问 `http://192.168.2.1`
4. 首次登录无需密码，进入后立即设置密码

### 日常升级

1. 下载 `squashfs-sysupgrade.bin`
2. LuCI → 系统 → 备份/升级 → 刷写新的固件
3. 上传文件，等待重启完成

---

## ⚙️ 首次配置建议

```
1. 系统 → 管理权 → 设置登录密码
2. 网络 → 接口 → WAN 口配置上网方式（PPPoE / DHCP）
3. 网络 → DNSFilter → 启用广告过滤规则
4. 系统 → ZRAM → 点击启用内存压缩
5. 服务 → HomeProxy → 配置代理节点
```

---

## 📋 默认参数

| 项目 | 值 |
|---|---|
| 管理地址 | `192.168.2.1` |
| 默认密码 | 无（首次登录直接进入） |
| 时区 | Asia/Shanghai (UTC+8) |
| NTP 服务器 | ntp.aliyun.com / ntp.tencent.com |
| 主机名 | OpenWrt |

---

## 🔧 编译信息

| 项目 | 值 |
|---|---|
| 源码 | openwrt/openwrt `main` 分支 |
| 目标平台 | qualcommax / IPQ60xx |
| 设备 | qihoo_360v6 |
| 编译环境 | Ubuntu 22.04 / GitHub Actions |

---

## ⚠️ 注意事项

- `initramfs-uImage.itb` 为内存固件，**断电后恢复原固件**，仅用于测试或救砖
- 升级固件建议先在 LuCI 备份当前配置，升级后可选择恢复
- HomeProxy 需自行配置订阅或节点，固件不内置任何代理配置
- DNSFilter 首次启用后需要下载规则，需要路由器能正常联网

---

## 📁 仓库结构

```
.
├── .github/
│   └── workflows/
│       └── openwrt-builder.yml   # 自动编译 workflow
└── files/
    └── etc/
        ├── uci-defaults/
        │   └── 99-firstboot-setup.sh   # 首次启动初始化脚本
        └── sysctl.d/
            └── 99-bbr.conf             # BBR + TCP 优化参数
```

---

## 🙏 致谢

- [OpenWrt](https://github.com/openwrt/openwrt)
- [jerrykuku/luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon)
- [immortalwrt/homeproxy](https://github.com/immortalwrt/homeproxy)
- [kiddin9/luci-app-dnsfilter](https://github.com/kiddin9/luci-app-dnsfilter)
```
