#!/bin/bash

echo "Starting the setup for kubectl aliases and custom function..."

# 检查用户的 shell 类型
shell_type=$(basename $SHELL)

# 下载适当的 .kubectl_aliases 文件
if [ "$shell_type" = "fish" ]; then
    echo "Detected Fish shell. Downloading .kubectl_aliases.fish..."
    curl -Lo ~/.kubectl_aliases.fish https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases.fish
    
    if [ $? -eq 0 ]; then
        echo "Download completed successfully."
    else
        echo "Error: Failed to download .kubectl_aliases.fish file."
        exit 1
    fi
    
    echo "Please add the following line to your ~/.config/fish/config.fish:"
    echo "    source ~/.kubectl_aliases.fish"
else
    echo "Detected Bash/Zsh shell. Downloading .kubectl_aliases..."
    curl -Lo ~/.kubectl_aliases https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases
    
    if [ $? -eq 0 ]; then
        echo "Download completed successfully."
    else
        echo "Error: Failed to download .kubectl_aliases file."
        exit 1
    fi
    
    echo "Updating your shell configuration file..."
    
    # 将必要的配置添加到 .bashrc 或 .zshrc 文件中
    if [ "$shell_type" = "bash" ]; then
        rc_file="$HOME/.bashrc"
    elif [ "$shell_type" = "zsh" ]; then
        rc_file="$HOME/.zshrc"
    else
        echo "Unsupported shell. Please manually configure your shell."
        exit 1
    fi
    
    # 添加 source 命令到 .bashrc 或 .zshrc
    grep -qxF '[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases' "$rc_file" || echo '[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases' >> "$rc_file"
    
    # 添加使用 watch 的推荐配置
    grep -qxF '[ -f ~/.kubectl_aliases ] && source <(cat ~/.kubectl_aliases | sed -r '"'"'s/(kubectl.*) --watch/watch \1/g'"'"')' "$rc_file" || echo '[ -f ~/.kubectl_aliases ] && source <(cat ~/.kubectl_aliases | sed -r '"'"'s/(kubectl.*) --watch/watch \1/g'"'"')' >> "$rc_file"
    
    # 添加 kubectl 函数
    grep -qxF 'function kubectl() { echo "+ kubectl $@">&2; command kubectl $@; }' "$rc_file" || echo 'function kubectl() { echo "+ kubectl $@">&2; command kubectl $@; }' >> "$rc_file"
    
    echo "Shell configuration updated successfully."
    
    # 立即加载新的配置文件
    echo "Applying the new configuration..."
    source "$rc_file"
    echo "Configuration applied. Your terminal is now ready."
fi

echo "kubectl aliases and function setup completed."
