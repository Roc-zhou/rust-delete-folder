# rust-delete-folder

这是一个用于递归查找并删除指定名称文件夹的命令行工具。支持在 macOS 和 Linux 系统上运行。

## 快速安装

### 方法 1：使用安装脚本（推荐）

```bash
# 下载并执行安装脚本
curl -fsSL https://raw.githubusercontent.com/Roc-zhou/rust-delete-folder/main/scripts/install.sh | bash
```

这个脚本会：
- 自动检测你的系统（macOS/Linux）和架构（x86_64/ARM64）
- 下载对应的最新版本
- 安装到 `/usr/local/bin`（需要输入 sudo 密码）

### 方法 2：手动下载安装

1. 访问 [Releases 页面](https://github.com/Roc-zhou/rust-delete-folder/releases)
2. 下载适合你系统的压缩包：
   - macOS Intel: `rust-delete-folder-darwin-amd64.tar.gz`
   - macOS Apple Silicon: `rust-delete-folder-darwin-arm64.tar.gz`
   - Linux: `rust-delete-folder-linux-amd64.tar.gz`
3. 解压并安装：
   ```bash
   tar xzf rust-delete-folder-*.tar.gz
   sudo mv rust-delete-folder /usr/local/bin/
   sudo chmod +x /usr/local/bin/rust-delete-folder
   ```

### 方法 3：从源码安装

```bash
git clone https://github.com/zhouhaipeng/rust-delete-folder.git
cd rust-delete-folder
cargo install --path .
```

## 使用方法

基本用法：
```bash
# 查找并删除所有名为 node_modules 的目录（会提示确认）
rust-delete-folder --folder node_modules

# 指定多个文件夹名称
rust-delete-folder --folder node_modules --folder target

# 不提示直接删除
rust-delete-folder --folder node_modules -y

# 仅演示不删除（dry-run）
rust-delete-folder --folder node_modules --dry-run
```

## 本地构建

```bash
# 普通构建
cargo build --release

# 交叉编译（如果需要）
rustup target add aarch64-apple-darwin  # 为 M1/M2 Mac 构建
cargo build --release --target aarch64-apple-darwin
```

## 注意事项

- 本工具会递归查找并删除指定名称的文件夹，请谨慎使用。
- 建议先使用 `--dry-run` 选项预览将要删除的文件夹。
- 如需提升权限（例如删除系统目录），请谨慎使用 `sudo`。
- 程序会检查目标路径是否在当前工作目录下，以防止意外删除其他位置的文件夹。