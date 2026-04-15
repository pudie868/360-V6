# OpenWrt for 360 V6 (IPQ6010)


---

 
 360 V6 这款四核 CPU 的整体表现相当不错。起初我只是用它运行基础的homeproxy代理插件，后来陆续开启 U 盘挂载、文件共享等功能，可玩性大幅提升。即便现在功能叠加丰富，单纯作为代理使用时，依旧流畅稳定、响应迅速。
最让我满意的还是它的无线性能：信号强度明显优于我之前三台原厂路由器组的 Mesh 网络，穿墙能力尤其突出，覆盖体验提升非常明显。

---


## 📋 功能特性

| 模块 | 组件 | 说明 |
|------|------|------|
| 🔐 代理 | HomeProxy + sing-box | 多核优化，自动分流 |
| 🛡️ DNS | AdGuardHome | 广告过滤 + DNS-over-HTTPS |
| ⚡ 加速 | TurboAcc + BBR + ZRAM | SFE 硬件加速 + 内存优化 |
| 🌐 防火墙 | firewall4 + nftables | 硬件卸载支持 |
| 🐳 容器 | Docker + dockerman | 完整容器运行时 |
| 🔗 穿透 | Lucky | 内网穿透 / DDNS |
| 📁 文件 | FileBrowser | Web 文件管理器 |
| 🖥️ 界面 | Argon + 中文 | 简洁美观 |
| 📶 无线 | ath11k-ahb + ipq6010 | 360V6 原生驱动 |
| 🚀 超频 | cpufreq-dt + performance | 释放最大 CPU 频率 |
| 💾 U盘 | ext4/exFAT/NTFS/UAS | 全格式高速支持 |

## 📁 项目结构

 ``` 
 openwrt-builder/
 ├── .github/
 │   └── workflows/
 │       └── openwrt-builder.yml    # GitHub Actions 工作流
 ├── files/                          # 自定义配置（可选）
 │   └── etc/
 │       ├── sysctl.d/
 │       │   └── 99-bbr.conf         # BBR + 网络优化
 │       └── uci-defaults/
 │           └── 99-firstboot-setup.sh  # 首次启动脚本
 └── README.md
 ```

## 🚀 使用方法

### 方式一：手动触发

1. 进入 GitHub 仓库页面
2. 点击 **Actions** → **Build OpenWrt for 360 V6**
3. 点击 **Run workflow** → 选择分支 → 点击绿色按钮

### 方式二：自动触发

推送到 `main` 或 `master` 分支时会自动执行编译。

### 方式三：本地编译

```bash
# 安装依赖（Ubuntu/Debian）
sudo apt-get update
sudo apt-get install -y build-essential clang flex bison g++ gawk gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev python3 python3-pip rsync swig unzip zlib1g-dev wget curl ca-certificates file golang-go libelf-dev libncurses-dev zstd pkg-config ccache libzstd-dev

# 克隆本仓库
git clone --depth 1 -b main https://github.com/你的用户名/openwrt-builder.git
cd openwrt-builder

# 创建 files 目录（可选）
mkdir -p files/etc/uci-defaults/ files/etc/sysctl.d/

# 触发编译
make -f .github/workflows/openwrt-builder.yml
```

## ⚙️ 自定义配置

### 添加自定义文件

将文件放入 `files/` 目录，编译时会自动注入到固件：

 ```bash
 files/
 └── etc/
     ├── sysctl.d/
     │   └── 99-bbr.conf       # 网络优化配置
     └── uci-defaults/
         └── 99-firstboot-setup.sh  # 首次启动脚本
 ```

### 修改插件版本

编辑 `.github/workflows/openwrt-builder.yml` 中的环境变量：

 ```yaml
 env:
   REPO_URL: https://github.com/openwrt/openwrt
   REPO_BRANCH: main          # OpenWrt 分支
   ARGON_TAG: "v2.3.1"       # Argon 主题版本
 ```

### 修改内置插件

编辑 `📦 安装第三方插件` 步骤中的 git clone 命令。

## 📦 固件说明

### 文件类型

| 文件 | 用途 |
|------|------|
| `squashfs-factory.ubi` | 首次刷入 |
| `squashfs-sysupgrade.bin` | 在线升级 |
| `initramfs-uImage.itb` | 救砖/测试 |

### 默认配置

- **默认 IP**: `192.168.2.1`
- **首次登录**: 无需密码，设置新密码即可
- **主题**: Argon
- **语言**: 中文

## 🔧 首次配置

1. 访问 `http://192.168.2.1` 设置管理员密码
2. 系统 → CPU 频率 → 设为 `performance` 模式（可选超频）
3. LuCI → 服务 → AdGuardHome → 启用并配置上游 DNS
4. LuCI → 系统 → ZRAM → 点击启用
5. Docker 数据目录建议挂载到 U 盘：`/mnt/sda1/docker`

## 📊 编译时间

- 首次编译：约 2-4 小时
- 增量编译：约 30-60 分钟（使用 ccache）

## ⚠️ 注意事项

1. **磁盘空间**：需要至少 40GB 可用空间
2. **网络环境**：部分插件需要访问 GitHub，建议配置代理
3. **超频风险**：IPQ6010 默认 1.2GHz，超频至 1.5GHz 可能有发热问题
4. **Docker 内存**：360 V6 仅 512MB RAM，建议将 Docker 数据目录挂载到 U 盘

## 🔄 自动更新

固件内置清华镜像源，首次启动后自动切换：

 ``` 
 src/gz openwrt_core https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/targets/qualcommax/ipq60xx/packages
 src/gz openwrt_base https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/packages/aarch64_cortex-a53/base
 src/gz openwrt_luci https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/packages/aarch64_cortex-a53/luci
 ```

## 📝 License

本项目仅供学习交流使用，请遵守相关开源协议。
 ```
