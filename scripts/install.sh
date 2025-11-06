#!/bin/bash

set -e

# 检测系统架构和平台
detect_platform() {
    local platform="unknown"
    local arch="unknown"
    
    # 检测操作系统
    case "$(uname -s)" in
        Darwin*)
            platform="darwin"
            ;;
        Linux*)
            platform="linux"
            ;;
        *)
            echo "不支持的操作系统: $(uname -s)"
            exit 1
            ;;
    esac
    
    # 检测架构
    case "$(uname -m)" in
        x86_64*)
            arch="amd64"
            ;;
        arm64|aarch64)
            # macOS 上的 M1/M2 芯片会显示为 arm64
            arch="arm64"
            ;;
        *)
            echo "不支持的架构: $(uname -m)"
            exit 1
            ;;
    esac
    
    echo "${platform}-${arch}"
}

# 获取最新的 release 版本
get_latest_version() {
    curl --silent "https://github.com/Roc-zhou/rust-delete-folder/releases/latest" | # 请替换为你的仓库地址
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

main() {
    # 检测平台
    local platform_arch=$(detect_platform)
    echo "检测到平台: ${platform_arch}"
    
    # 获取最新版本
    local version=$(get_latest_version)
    if [ -z "$version" ]; then
        echo "无法获取最新版本"
        exit 1
    fi
    echo "最新版本: ${version}"
    
    # 构造下载 URL
    local asset_name="rust-delete-folder-${platform_arch}"
    local download_url="https://github.com/Roc-zhou/rust-delete-folder/releases/download/${version}/${asset_name}.tar.gz" # 请替换为你的仓库地址
    
    # 创建临时目录
    local tmp_dir=$(mktemp -d)
    trap 'rm -rf ${tmp_dir}' EXIT
    
    echo "下载发布包..."
    curl -L "${download_url}" -o "${tmp_dir}/${asset_name}.tar.gz"
    
    echo "解压文件..."
    tar xzf "${tmp_dir}/${asset_name}.tar.gz" -C "${tmp_dir}"
    
    # 安装到 /usr/local/bin（需要 sudo）
    echo "安装到 /usr/local/bin..."
    sudo mv "${tmp_dir}/rust-delete-folder" /usr/local/bin/
    sudo chmod +x /usr/local/bin/rust-delete-folder
    
    echo "安装完成！你可以通过运行 'rust-delete-folder --help' 来验证安装。"
}

main "$@"