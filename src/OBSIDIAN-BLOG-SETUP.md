f# Obsidian + Hexo 博客配置指南

## 📁 目录结构

```
Obsidian Vault/
├── hexo-source/           # Hexo 源文件（博客源码）
│   ├── source/
│   │   └── _posts/        # 博客文章（用 Obsidian 编辑）
│   ├── themes/
│   │   └── solitude/      # Solitude 主题
│   ├── _config.yml        # Hexo 配置
│   └── package.json
├── 笔记/                  # 你的个人笔记（不发布）
└── OBSIDIAN-BLOG-SETUP.md # 本文件
```

## 🔧 Obsidian 配置

### 1. 安装 Obsidian Git 插件

1. 打开 Obsidian
2. 进入 `设置` → `第三方插件` → `浏览`
3. 搜索并安装 **Obsidian Git**
4. 启用插件

### 2. 配置 Obsidian Git

在 `设置` → `Obsidian Git` 中配置：

```yaml
自动保存间隔: 15 分钟
自动拉取间隔: 10 分钟
提交消息: "update: %date%"
提交方式: 自动提交
```

### 3. 创建 `.gitignore`

在 Obsidian Vault 根目录创建 `.gitignore`：

```
.obsidian/
私人笔记/
.hexo-source/
```

## 📝 写作流程

### 新建文章

1. 在 Obsidian 中打开 `hexo-source/source/_posts/`
2. 创建新的 Markdown 文件
3. 使用 Front Matter 格式：

```markdown
---
title: 文章标题
date: 2025-01-13
categories: [Unity]
tags: [UGUI, UI]
---

文章正文内容...
```

### 发布文章

1. 用 Obsidian Git 插件提交到 GitHub
2. GitHub Actions 自动构建并部署
3. 几分钟后访问 https://xinzhuzi.github.io

## 🚀 GitHub Actions 配置

### 第一次需要手动操作

1. 在 GitHub 上创建新仓库（如 `blog-source`）
2. 推送 hexo-source 到这个仓库
3. 在仓库设置中启用 GitHub Pages
4. 配置 Actions 权限：`Settings` → `Actions` → `General` → `Workflow permissions`

### 本地初始化 Git

```bash
cd ~/Documents/Obsidian\ Vault/hexo-source
git init
git add .
git commit -m "init: Hexo blog with Solitude theme"
git remote add origin https://github.com/xinzhuzi/blog-source.git
git push -u origin main
```

## 🎨 Solitude 主题配置

主题安装后，复制主题配置：

```bash
cp themes/solitude/_config.yml _config.solitude.yml
```

然后编辑 `_config.solitude.yml` 自定义样式。

## 📌 常用命令

```bash
# 本地预览
cd ~/Documents/Obsidian\ Vault/hexo-source
hexo server

# 生成静态文件
hexo generate

# 清理缓存
hexo clean
```
