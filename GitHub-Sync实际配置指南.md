# 🔧 GitHub Sync 插件正确配置方法

## 📋 当前插件界面分析

您看到的界面说明这个 GitHub Sync 插件是基于 Git 的，需要先在本地配置 Git 仓库。

## 🚀 配置步骤

### 第1步：配置 Remote URL

在 Remote URL 字段填写：
```
https://[YOUR_TOKEN]@github.com/freedomshannon/blog.git
```

### 第2步：Git Binary Location (可选)

如果您的系统能找到 git 命令，这个可以留空。
如果需要，通常是：
- macOS: `/usr/bin/git` 或 `/opt/homebrew/bin/git`
- Windows: `C:\Program Files\Git\bin\git.exe`

### 第3步：同步选项配置

建议设置：
- ✅ **Check status on startup**: 开启
- ❌ **Auto sync on startup**: 关闭（避免意外同步）
- ❌ **Auto sync at interval**: 留空（手动控制）

## ⚠️ 重要前提条件

这个插件需要您的 Obsidian 文库本身就是一个 Git 仓库。我们需要先设置：

### 方案A：将整个 Obsidian 文库设为博客仓库

1. **将博客文件移动到您的 Obsidian 文库**
2. **在 Obsidian 文库中初始化 Git**
3. **配置远程仓库**

### 方案B：在 Obsidian 中创建博客子文件夹

1. **在 Obsidian 文库中创建博客专用文件夹**
2. **将该文件夹初始化为 Git 仓库**
3. **配置同步**

## 🎯 推荐配置流程

让我为您创建一个设置脚本：

```bash
# 在您的 Obsidian 文库根目录运行
git init
git remote add origin https://[YOUR_TOKEN]@github.com/freedomshannon/blog.git
git branch -M main
```

## 📂 文件夹结构

在您的 Obsidian 文库中创建：

```
您的Obsidian文库/
├── posts/              # 博客文章目录
│   ├── dev/
│   ├── ai/
│   └── life/
├── public/             # 静态资源
│   ├── images/
│   └── covers/
├── src/               # 博客源码（从现有项目复制）
├── 其他Obsidian笔记/   # 您的私人笔记
└── .gitignore         # 忽略私人笔记
```

## 🔧 .gitignore 配置

创建 `.gitignore` 文件，只同步博客相关内容：

```gitignore
# 忽略 Obsidian 配置
.obsidian/
.trash/

# 忽略私人笔记文件夹
其他笔记/
日记/
私人想法/

# 只同步博客相关内容
!posts/
!public/
!src/
!package.json
!next.config.js
!tailwind.config.js
!tsconfig.json
!.env.example
```

---

## 💡 更简单的替代方案

如果觉得配置复杂，我推荐两个更简单的方案：

### 方案1：Obsidian Git 插件
这是专门为 Obsidian 设计的 Git 插件，配置更简单。

### 方案2：文件夹同步
直接将 Obsidian 的某个文件夹链接到博客项目，然后用我们之前的脚本发布。

## ❓ 您觉得如何？

1. **继续配置当前的 GitHub Sync 插件**？
2. **换用 Obsidian Git 插件**？
3. **使用文件夹同步方案**？

请告诉我您的选择，我帮您完成配置！