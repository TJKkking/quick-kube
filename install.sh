#!/bin/bash

# 检查是否需要安装 Helm 和 kubectx
install_helm=false
install_kubectx=false

for arg in "$@"; do
    case $arg in
        --install-helm)
            install_helm=true
            ;;
        --install-kubectx)
            install_kubectx=true
            ;;
    esac
done

echo "Starting the setup for kubectl aliases and custom function..."

# 检查用户的 shell 类型
shell_type=$(basename $SHELL)

# 定义目标 rc 文件
if [ "$shell_type" = "bash" ]; then
    rc_file="$HOME/.bashrc"
elif [ "$shell_type" = "zsh" ]; then
    rc_file="$HOME/.zshrc"
else
    echo "Unsupported shell. Please manually configure your shell."
    exit 1
fi

# 下载 .kubectl_aliases 文件
echo "Downloading .kubectl_aliases..."
if curl -Lo ~/.kubectl_aliases https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases; then
    echo "Download completed successfully."
else
    echo "Error: Failed to download .kubectl_aliases file."
    exit 1
fi

# 更新 rc 文件
echo "Updating your shell configuration file..."

add_to_rc() {
    local entry="$1"
    grep -qxF "$entry" "$rc_file" || echo "$entry" >> "$rc_file"
}

add_to_rc '[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases'
add_to_rc '[ -f ~/.kubectl_aliases ] && source <(cat ~/.kubectl_aliases | sed -r "s/(kubectl.*) --watch/watch \1/g")'
add_to_rc 'function kubectl() { echo "+ kubectl $@">&2; command kubectl "$@"; }'

echo "Shell configuration updated successfully."

# 立即加载新的配置文件
echo "Applying the new configuration..."
source "$rc_file"
echo "Configuration applied. Your terminal is now ready."

# 安装 Helm（如果用户选择了 --install-helm 参数）
if [ "$install_helm" = true ]; then
    echo "Installing Helm..."
    if curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; then
        echo "Helm installed successfully."
    else
        echo "Error: Failed to install Helm."
        exit 1
    fi
fi

# 安装 kubectx 和 kubens（如果用户选择了 --install-kubectx 参数）
if [ "$install_kubectx" = true ]; then
    echo "Installing kubectx and kubens..."
    if sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx && \
       sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && \
       sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens; then
        echo "kubectx and kubens installed successfully."
    else
        echo "Error: Failed to install kubectx and kubens."
        exit 1
    fi
fi

echo "kubectl aliases and function setup completed."