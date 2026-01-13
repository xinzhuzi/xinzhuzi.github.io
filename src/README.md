# Hexo博客部署脚本

## 📁 位置

脚本位于 `src/` 目录下，与 `hexo-source/` 同级。

```
xinzhuzi.github.io/
├── src/
│   ├── deploy.sh          ⭐ 部署脚本
│   ├── deploy-test.sh     📋 测试脚本
│   ├── hexo-source/       ← Hexo源码
│   └── README.md          ← 本说明
├── index.html             ← 生成的静态文件
└── ...
```

## 🚀 快速开始

### 1. 测试部署（推荐先运行）

```bash
cd /Users/zhengbingjin/Project/Github/xinzhuzi.github.io/src
./deploy-test.sh
```

这会显示：
- ✅ 哪些文件会被**保留**（src、.git等）
- ❌ 哪些文件会被**删除**（旧的静态文件）
- 📦 将要**添加**的新文件

**不会真正删除或修改任何文件！**

### 2. 执行部署

```bash
./deploy.sh
```

### 3. 提交到GitHub

```bash
cd ..  # 回到xinzhuzi.github.io根目录
git add .
git commit -m "Update blog"
git push
```

## ⚙️ 脚本说明

### deploy.sh（部署脚本）

**功能：**
1. 清理旧的生成文件（`hexo clean`）
2. 生成静态文件（`hexo generate`）
3. 备份重要文件（.git、src目录）
4. 删除旧的静态文件（html、css、js等）
5. 复制新的静态文件到上级目录
6. 恢复备份的文件（src完整恢复）

**绝对不删除：**
- ✅ `src/` 目录（包括hexo-source、deploy.sh等所有内容）
- ✅ `.git/` 目录
- ✅ `.gitignore`, `README.md`, `CNAME`, `LICENSE`

**只删除和更新：**
- ❌ `index.html`, `css/`, `js/`, `2020/`, `2021/` 等静态文件

### deploy-test.sh（测试脚本）

只显示预览，不执行任何删除或复制操作。

## 📊 路径说明

脚本使用**相对路径**，所有路径都是相对于 `src/` 目录：

- 源码目录：`./hexo-source`
- 部署目标：`./..` （上级目录，即xinzhuzi.github.io根目录）

## 🔧 首次使用

如果是首次使用，需要先安装依赖：

```bash
cd hexo-source
npm install
```

## 📝 文章分类

文章已按主题分类存放：

```
hexo-source/source/_posts/
├── Unity/           63篇
├── 网络编程/         6篇
├── 编程基础/         6篇
├── 工具使用/         5篇
├── Lua热更新/        5篇
├── AI游戏设计/       1篇
├── 其他/            3篇
└── 根目录            2篇
```

## ⚠️ 注意事项

1. **src目录永远不会被删除**
   - 脚本在删除文件前会备份src目录
   - 复制完成后会完整恢复src目录
   - hexo-source、deploy.sh等文件都在src目录中，完全安全

2. **使用相对路径**
   - 脚本可以在任何机器上使用
   - 不依赖绝对路径

3. **先测试再部署**
   - 推荐先运行 `deploy-test.sh` 查看预览
   - 确认无误后再运行 `deploy.sh`

## 🆘 常见问题

### Q: src目录会被删除吗？
**A: 不会！** src目录在保留列表的第一位，脚本会完整备份并恢复它。

### Q: hexo-source会被影响吗？
**A: 不会！** hexo-source在src目录下，src目录被完整保留。

### Q: 如何查看会删除什么文件？
**A:** 运行 `./deploy-test.sh` 查看预览。

### Q: 部署失败了怎么办？
**A:** 检查：
1. hexo-source目录是否存在
2. 是否已安装依赖（`npm install`）
3. 查看错误信息
