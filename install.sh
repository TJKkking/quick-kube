#!/bin/bash

# 下载 .kubectl_aliases 文件
curl -Lo ~/.kubectl_aliases https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases

# 如果文件存在，替换并执行命令
if [ -f ~/.kubectl_aliases ]; then
  source <(cat ~/.kubectl_aliases | sed -r 's/(kubectl.*) --watch/watch \1/g')
fi

# 定义 kubectl 函数以打印命令并执行
function kubectl() {
  echo "+ kubectl $@" >&2
  command kubectl "$@"
}

echo "kubectl aliases and function are set up successfully."
