#!/bin/bash

# 定义 Go 语言版本和安装路径
GO_VERSION=${1:-"1.22.6"}  # 默认版本为 1.22.6
GO_ROOT="/usr/local/go"
GO_WORKSPACE="/usr/local/go_workspace"
GO_URL="https://dl.google.com/go"

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$NAME
else
    echo "不支持当前系统，请使用 Ubuntu CentOS Debian 系统。"
    exit 1
fi

# 安装必要的依赖
if [[ "$OS_NAME" == *"Ubuntu"* ]]; then
    echo "Detected Ubuntu."
    sudo apt update
    sudo apt install -y wget tar
elif [[ "$OS_NAME" == *"CentOS"* ]]; then
    echo "Detected CentOS."
    sudo yum install -y wget tar
elif [[ "$OS_NAME" == *"Debian"* ]]; then
    echo "Detected Debian."
    sudo apt update
    sudo apt install -y wget tar
else
    echo "不支持当前系统，请使用 Ubuntu CentOS Debian 系统。"
    exit 1
fi

# 下载并安装 Go 语言
echo "正在下载 Go version $GO_VERSION 从 $GO_URL..."
wget "$GO_URL/go$GO_VERSION.linux-amd64.tar.gz" -P /tmp


# 解压缩并安装
echo "正在安装 Go..."
sudo tar -C /usr/local -xzf "/tmp/go$GO_VERSION.linux-amd64.tar.gz"

# 创建工作空间
if [ ! -d "$GO_WORKSPACE" ]; then
    sudo mkdir -p "$GO_WORKSPACE"
    sudo chmod -R 777 "$GO_WORKSPACE"
fi

# 备份 /etc/profile
echo "备份 /etc/profile 到 /etc/profile.bak..."
sudo cp /etc/profile /etc/profile.bak


# 添加 Go 和工作空间到环境变量，先检查是否已经添加
if ! grep -q 'export GOROOT' /etc/profile; then
    echo "export GOROOT=$GO_ROOT" | sudo tee -a /etc/profile
fi

if ! grep -q 'export GOPATH' /etc/profile; then
    echo "export GOPATH=$GO_WORKSPACE" | sudo tee -a /etc/profile
fi

if ! grep -q 'export PATH=' /etc/profile; then
    echo "export PATH=\$PATH:\$GOROOT/bin:\$GOPATH" | sudo tee -a /etc/profile
fi

# 清理下载的文件
echo "正在清理下载的文件..."
rm "/tmp/go$GO_VERSION.linux-amd64.tar.gz"

echo "Go 安装完成"

echo "==============================================="
echo "为了确保环境配置正确，请执行以下命令："
echo "------------------------------"
echo "1. 加载系统环境变量(必须):"
echo "   source /etc/profile"
echo
echo "2. 将 Go 模块设置为启用(参考)："
echo "   go env -w GO111MODULE=on"
echo
echo "3. 设置 Go 代理(参考)："
echo "   go env -w GOPROXY=https://goproxy.cn,direct"
echo "==============================================="

