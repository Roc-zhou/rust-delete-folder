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
    local api_response
    # 使用 GitHub API 获取最新版本
    api_response=$(curl --silent --location \
        --header "Accept: application/vnd.github+json" \
        --header "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/Roc-zhou/rust-delete-folder/releases/latest")
    
    # 检查是否获取成功
    if [ $? -ne 0 ]; then
        echo "Error: 无法连接到 GitHub API" >&2
        return 1
    fi
    
    # 检查响应是否包含错误信息
    if echo "$api_response" | grep -q "API rate limit exceeded"; then
        echo "Error: GitHub API 速率限制，请稍后再试" >&2
        return 1
    fi
    
    if echo "$api_response" | grep -q "Not Found"; then
        echo "Error: 找不到仓库或未发布版本" >&2
        return 1
    fi
    
    # 提取版本号
    local version
    version=$(echo "$api_response" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$version" ]; then
        echo "Error: 无法解析版本号" >&2
        return 1
    fi
    
    echo "$version"
}

main() {
    # 检测平台
    local platform_arch=$(detect_platform)
    echo "检测到平台: ${platform_arch}"
    
    # 获取最新版本
    echo "正在获取最新版本信息..."
    local version
    if ! version=$(get_latest_version); then
        echo "错误: 获取版本失败"
        exit 1
    fi
    echo "找到最新版本: ${version}"
    
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