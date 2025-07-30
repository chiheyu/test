# Kali NetHunter in Termux

一个改进的 Kali NetHunter 安装脚本，专为 Termux 环境优化。

## 🚀 新特性

- ✅ **跳过完整性检查** - 避免 SHA 文件不存在的问题
- ✅ **自动创建 startkali 命令** - 安装完成后可直接使用 `startkali`
- ✅ **改进的错误处理** - 更好的错误提示和恢复机制
- ✅ **优化的 proot 配置** - 修复路径和环境变量问题
- ✅ **完整的系统文件设置** - 确保 Kali 环境正常工作

## 📋 系统要求

- Android 设备
- Termux 应用
- 网络连接
- 至少 3GB 可用存储空间

## 🛠️ 安装步骤

1. **克隆或下载项目**
   ```bash
   git clone https://github.com/your-repo/Nethunter-In-Termux.git
   cd Nethunter-In-Termux
   ```

2. **运行安装脚本**
   ```bash
   chmod +x kalinethunter.sh
   ./kalinethunter.sh
   ```

3. **等待安装完成**
   - 下载 Kali NetHunter rootfs (约 2.2GB)
   - 解压文件系统
   - 配置环境
   - 创建启动脚本

## 🎯 使用方法

### 启动 Kali NetHunter

```bash
# 以 kali 用户身份启动
startkali

# 以 root 用户身份启动
startkali -r
```

### 退出 Kali 环境

```bash
exit
```

## 🔧 故障排除

### 常见问题

1. **"startkali: command not found"**
   - 确保安装脚本完全执行成功
   - 检查 `$PREFIX/bin/startkali` 是否存在

2. **"proot error"**
   - 确保已安装 proot: `pkg install proot`
   - 检查 Kali 环境是否完整

3. **"ls: command not found"**
   - 这是正常的，Kali 环境中的基本命令可能不可用
   - 使用 Termux 的包管理器安装工具

### 重新安装

如果遇到严重问题，可以重新安装：

```bash
# 删除现有环境
rm -rf $HOME/chroot/kali-arm64

# 重新运行安装脚本
./kalinethunter.sh
```

## 📁 文件结构

```
Nethunter-In-Termux/
├── kalinethunter.sh      # 主安装脚本
├── finaltouchup.sh       # 最终配置脚本
├── README.md            # 说明文档
└── LICENSE              # 许可证文件
```

## 🎨 自定义

### 修改安装路径

编辑 `kalinethunter.sh` 中的 `DESTINATION` 变量：

```bash
DESTINATION="$HOME/chroot/kali-arm64"  # 修改为你想要的路径
```

### 添加自定义工具

在 `finaltouchup.sh` 的 `install_basic_tools` 函数中添加你的工具。

## 📞 支持

如果遇到问题，请：

1. 检查本文档的故障排除部分
2. 确保你的设备满足系统要求
3. 查看安装过程中的错误信息

## 📄 许可证

本项目基于原始项目修改，请查看 LICENSE 文件了解详细信息。

## 🙏 致谢

- 原始项目作者：Hax4us
- Termux 开发团队
- Kali Linux 团队

---

**注意：** 此工具仅用于教育和合法的安全测试目的。请遵守当地法律法规。
