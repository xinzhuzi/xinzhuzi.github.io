#!/bin/bash

# Hexo博客部署预览脚本 - 测试版本（只显示不执行）
# 位置：src 目录

echo "========================================"
echo "  部署预览 - 测试模式"
echo "========================================"
echo ""

# 检查hexo-source目录
if [ ! -d "./hexo-source" ]; then
    echo "❌ 错误：hexo-source目录不存在"
    echo "   路径：./hexo-source"
    exit 1
fi

echo "📂 当前脚本位置：src/"
echo "📂 Hexo源码目录：./hexo-source"
echo "📂 部署目标目录：../ (上级目录)"
echo ""

# 切换到hexo-source目录
cd ./hexo-source

# 生成静态文件
echo "🔨 生成静态文件..."
npx hexo clean > /dev/null 2>&1
npx hexo generate > /dev/null 2>&1

if [ ! -d "public" ]; then
    echo "❌ public目录生成失败"
    exit 1
fi

echo "✅ 静态文件生成完成"
echo ""

# 回到src目录
cd ..

# 切换到上级目录
cd ..

# 显示将要保留的文件和目录
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  以下文件和目录将被【保留】（不会删除）："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

KEEP_FILES=("src" ".git" ".gitignore" "README.md" "CNAME" "LICENSE")

for item in "${KEEP_FILES[@]}"; do
    if [ -e "$item" ]; then
        if [ "$item" = "src" ]; then
            echo "  ✅ $item/ (当前脚本所在目录，完整保留)"
            echo "     └─ hexo-source/"
            echo "     └─ deploy.sh"
            echo "     └─ ..."
        else
            echo "  ✅ $item"
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  以下文件和目录将被【删除】："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 显示将要删除的文件
for item in *; do
    should_keep=false
    for keep in "${KEEP_FILES[@]}"; do
        if [ "$item" = "$keep" ]; then
            should_keep=true
            break
        fi
    done

    if [ "$should_keep" = false ] && [ -e "$item" ]; then
        echo "  ❌ $item"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  将要添加的新文件（预览前20个）："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "./hexo-source/public" ]; then
    find ./hexo-source/public -type f | head -20
    echo "  ..."
fi

echo ""
echo "========================================"
echo "  预览完成"
echo "========================================"
echo ""
echo -e "\033[1;33m⚠️  确认事项：\033[0m"
echo "  • src 目录将被完整保留（包括hexo-source、deploy.sh等）"
echo "  • .git 目录将被保留"
echo "  • 只删除和更新旧的静态文件（html, css, js等）"
echo ""
echo "如果确认无误，请运行："
echo "  ./deploy.sh"
echo ""
