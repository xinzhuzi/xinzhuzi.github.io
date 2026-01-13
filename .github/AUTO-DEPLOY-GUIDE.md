# GitHub Pages 自动部署指南

## 🚀 自动部署已配置完成！

### 工作原理

当你推送代码到 `master` 分支时，GitHub Actions 会自动：
1. 检出代码
2. 安装 Node.js 和 Hexo 依赖
3. 进入 `src/hexo-source` 目录
4. 生成静态文件（`hexo generate`）
5. 将生成的文件复制到仓库根目录
6. 自动提交并推送到 `master` 分支
7. GitHub Pages 自动更新网站

---

## 📝 使用方法

### 工作目录结构

```
xinzhuzi.github.io/
├── src/
│   └── hexo-source/          ← Hexo 源码目录
│       ├── source/
│       │   └── _posts/       ← 在这里创建文章
│       ├── _config.yml       ← Hexo 配置
│       ├── themes/           ← 主题
│       └── package.json
│
├── .github/                   ← GitHub Actions 配置
├── deploy.sh                  ← 手动部署脚本
└── [生成的静态文件]          ← 自动生成，不要手动编辑
```

### 发布新文章的流程

**步骤 1：创建新文章**

在 `src/hexo-source/source/_posts/` 目录下创建 Markdown 文件：

```bash
cd /Users/zhengbingjin/Project/Github/xinzhuzi.github.io/src/hexo-source/source/_posts/
# 创建或编辑文章
```

**步骤 2：生成静态文件**

```bash
cd /Users/zhengbingjin/Project/Github/xinzhuzi.github.io/src
./deploy.sh
```

**步骤 3：提交并推送**

```bash
cd /Users/zhengbingjin/Project/Github/xinzhuzi.github.io
git add .
git commit -m "Add new article: xxx"
git push origin master
```

**步骤 4：等待自动部署** 🎉

- GitHub Actions 自动开始构建（约 1-2 分钟）
- 访问 https://xinzhuzi.github.io 查看更新

---

## ⚙️ GitHub Actions 工作流配置

文件位置：`.github/workflows/deploy.yml`

**触发条件**：
- ✅ 推送到 `master` 分支
- ✅ 手动触发（在 GitHub 网页上点击按钮）

**构建环境**：
- Ubuntu 最新版本
- Node.js 20

**部署流程**：
1. 检出代码
2. 安装依赖
3. 生成静态文件
4. 部署到 GitHub Pages

**循环防护**：
- 只在非 bot 提交时触发
- Actions 提交包含 `[skip ci]` 标记

---

## 📊 监控部署状态

### 查看部署进度

1. 访问：https://github.com/xinzhuzi/xinzhuzi.github.io/actions
2. 点击最新的 "Hexo Blog Auto Deploy" 工作流
3. 查看实时日志和状态

### 状态标识
- ⚪ 蓝色：正在运行
- ✅ 绿色：部署成功
- ❌ 红色：部署失败

---

## 🔧 常见问题

### Q1: 推送后没有自动部署？
**A**: 检查以下几点：
1. 确认推送到了 `master` 分支
2. 检查 GitHub Actions 是否已启用
3. 查看工作流日志是否有错误

### Q2: 部署失败怎么办？
**A**:
1. 访问 Actions 页面查看错误日志
2. 常见原因：
   - Node.js 版本不匹配
   - 依赖安装失败
   - Hexo 配置错误

### Q3: 如何回滚到之前的版本？
**A**:
```bash
# 查看提交历史
git log --oneline

# 回滚到指定版本
git revert <commit-id>
git push origin master
```

---

## 🛠️ 手动部署（备用方案）

如果自动部署失败，可以使用手动部署脚本：

```bash
cd /Users/zhengbingjin/Project/Github/xinzhuzi.github.io/src
./deploy.sh

# 然后推送
cd ..
git add .
git commit -m "Manual deploy"
git push origin master
```

---

## 📌 重要提醒

1. **文章源文件位置**：
   - ✅ `src/hexo-source/source/_posts/` - 在这里编辑文章
   - ❌ 根目录的 HTML 文件是自动生成的，不要手动编辑

2. **Git 提交策略**：
   ```bash
   # 在项目根目录提交
   cd /Users/zhengbingjin/Project/Github/xinzhuzi.github.io
   git add .
   git commit -m "Update article"
   git push origin master
   ```

3. **本地预览**（可选）：
   ```bash
   cd /Users/zhengbingjin/Project/Github/xinzhuzi.github.io/src/hexo-source
   npm run server
   # 浏览器访问 http://localhost:4000
   ```

---

## 🎉 完成！

现在你的博客已经配置了自动部署，只需要：
1. 在 `src/hexo-source/source/_posts/` 修改文章
2. 运行 `deploy.sh` 生成静态文件
3. git push
4. 等待 1-2 分钟
5. 自动更新 ✨
