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

### 方式一：修改博客内容（推荐）

1. **在本地编辑文章**：
   ```bash
   cd /Users/zhengbingjin/Documents/Obsidian\ Vault/hexo-source
   # 编辑你的 markdown 文章
   ```

2. **推送到 GitHub**：
   ```bash
   git add .
   git commit -m "Update article: xxx"
   git push origin master
   ```

3. **等待自动部署** 🎉
   - GitHub Actions 自动开始构建（约 1-2 分钟）
   - 访问 https://xinzhuzi.github.io 查看更新

---

### 方式二：快速预览本地效果

如果想先本地预览再发布：

```bash
# 1. 进入 Hexo 源码目录
cd /Users/zhengbingjin/Documents/Obsidian\ Vault/hexo-source

# 2. 启动本地服务器
npm run server

# 3. 浏览器访问 http://localhost:4000 预览

# 4. 确认无误后推送
git add .
git commit -m "Update article"
git push origin master
```

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
1. 确认推送到了 `master` 分支（不是 main）
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
./deploy.command

# 然后推送
cd ..
git add .
git commit -m "Manual deploy"
git push origin master
```

---

## 📌 重要提醒

1. **不要手动编辑根目录的静态文件**
   - 根目录的 HTML/CSS/JS 文件是自动生成的
   - 下次部署会被覆盖

2. **源文件位置**：
   - 文章：`src/hexo-source/source/_posts/`
   - 配置：`src/hexo-source/_config.yml`
   - 主题：`src/hexo-source/themes/solitude/`

3. **Git 提交建议**：
   ```bash
   # 只提交源码文件，不要提交生成的静态文件
   cd /Users/zhengbingjin/Documents/Obsidian\ Vault/hexo-source
   git add source/_posts/your-article.md
   git commit -m "Add new article: xxx"
   git push origin master
   ```

---

## 🎉 完成！

现在你的博客已经配置了自动部署，只需要：
1. 修改文章
2. git push
3. 等待 1-2 分钟
4. 自动更新 ✨
