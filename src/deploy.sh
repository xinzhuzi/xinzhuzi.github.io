#!/bin/bash

# Hexo博客部署脚本
# 功能：从hexo-source生成静态文件并部署到上级目录
# 绝对不会删除src目录及其内容

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  Hexo博客部署脚本${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# ===== 第一步：切换到脚本所在目录 =====
# 获取脚本所在目录（无论从哪里执行都能正确找到）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${YELLOW}📍 第1步：在src目录中生成静态文件${NC}"
echo "脚本位置: $SCRIPT_DIR"
echo "当前目录: $(pwd)"
echo ""

# 检查hexo-source
if [ ! -d "hexo-source" ]; then
    echo -e "${RED}❌ 错误：hexo-source目录不存在${NC}"
    echo "当前目录: $(pwd)"
    exit 1
fi

# 进入hexo-source生成文件
cd hexo-source
echo "清理旧文件..."
npx hexo clean > /dev/null 2>&1

echo "生成静态文件..."
npx hexo generate

if [ ! -d "public" ]; then
    echo -e "${RED}❌ 错误：public目录生成失败${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 静态文件生成完成${NC}"
echo ""

# 回到src目录
cd "$SCRIPT_DIR"

# ===== 第二步：进入上级目录部署 =====
echo -e "${YELLOW}📍 第2步：部署到上级目录${NC}"
echo ""

cd ..

# 显示当前目录
echo "当前目录: $(pwd)"
echo ""

# 创建临时备份目录
BACKUP_DIR=$(mktemp -d)

# 备份src目录（完整备份，包括所有内容）
if [ -d "src" ]; then
    echo "💾 备份src目录..."
    cp -r src "$BACKUP_DIR/"
    echo -e "${GREEN}  ✅ src已备份到临时目录${NC}"
fi

# 备份.git
if [ -d ".git" ]; then
    echo "💾 备份.git目录..."
    cp -r .git "$BACKUP_DIR/.git"
fi

# 备份其他文件
for file in .gitignore README.md CNAME LICENSE; do
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/"
    fi
done

echo ""
echo -e "${YELLOW}🗑️  清理旧的静态文件（保留src）${NC}"

# 定义要保留的目录
KEEP=("src" ".git" ".github" ".gitignore" "README.md" "CNAME" "LICENSE")

# 删除文件和目录（保留指定的）
for item in *; do
    should_keep=false
    for keep in "${KEEP[@]}"; do
        if [ "$item" = "$keep" ]; then
            should_keep=true
            echo "  ✓ 保留: $item"
            break
        fi
    done

    if [ "$should_keep" = false ] && [ -e "$item" ]; then
        echo "  ✗ 删除: $item"
        rm -rf "$item"
    fi
done

# 删除隐藏文件（除了.git、.gitignore 和 .github）
for item in .*; do
    if [ "$item" = "." ] || [ "$item" = ".." ] || [ "$item" = ".git" ] || [ "$item" = ".gitignore" ] || [ "$item" = ".github" ]; then
        continue
    fi
    if [ -e "$item" ]; then
        echo "  ✗ 删除: $item"
        rm -rf "$item"
    fi
done

echo -e "${GREEN}✅ 清理完成${NC}"
echo ""

# 从备份恢复src（确保完整恢复）
if [ -d "$BACKUP_DIR/src" ]; then
    echo "♻️  恢复src目录..."
    rm -rf src 2>/dev/null || true
    cp -r "$BACKUP_DIR/src" ./src
    echo -e "${GREEN}  ✅ src已完整恢复${NC}"
fi

# 恢复.git
if [ -d "$BACKUP_DIR/.git" ]; then
    rm -rf .git 2>/dev/null || true
    cp -r "$BACKUP_DIR/.git" ./.git
fi

# 恢复其他文件
for file in .gitignore README.md CNAME LICENSE; do
    if [ -f "$BACKUP_DIR/$file" ]; then
        cp "$BACKUP_DIR/$file" "./$file"
    fi
done

echo ""
echo -e "${YELLOW}📦 复制新的静态文件...${NC}"

# 从src/hexo-source/public复制文件
cp -r src/hexo-source/public/* ./

echo -e "${GREEN}✅ 部署完成！${NC}"
echo ""

# 清理备份
rm -rf "$BACKUP_DIR"

# 显示统计
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  部署统计${NC}"
echo -e "${GREEN}======================================${NC}"
echo "HTML: $(find . -name '*.html' 2>/dev/null | wc -l | tr -d ' ')"
echo "CSS:  $(find . -name '*.css' 2>/dev/null | wc -l | tr -d ' ')"
echo "JS:   $(find . -name '*.js' 2>/dev/null | wc -l | tr -d ' ')"
echo ""

echo -e "${GREEN}✅ src目录已完整保留${NC}"
echo -e "${GREEN}✅ hexo-source已保留${NC}"
echo -e "${GREEN}✅ deploy脚本已保留${NC}"
echo ""

echo -e "${YELLOW}下一步操作：${NC}"
echo "  git add ."
echo "  git commit -m 'Update site'"
echo "  git push"
echo ""
