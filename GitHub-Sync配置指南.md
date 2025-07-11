# 🚀 使用 GitHub Sync 插件发布博客

## ✅ 更简单的方案：GitHub Sync

您选择的 **GitHub Sync** 插件实际上更适合博客发布！它能直接同步整个文件夹到 GitHub。

## 🔧 配置步骤

### 1. 插件配置

在 Obsidian 的 GitHub Sync 插件设置中填写：

```
Repository: freedomshannon/blog
Branch: main
GitHub Token: [您的_GitHub_Token]
```

### 2. 文件夹结构设置

在您的 Obsidian 文库中创建这样的结构：

```
您的 Obsidian 文库/
├── 博客文章/
│   ├── dev/
│   ├── ai/
│   └── product/
├── 博客图片/
│   ├── images/
│   └── covers/
└── 其他笔记...
```

### 3. 同步配置

在插件设置中配置同步路径：

```yaml
Sync Rules:
  博客文章/ -> posts/
  博客图片/images/ -> public/images/
  博客图片/covers/ -> public/covers/
```

## 🎯 使用流程

### 发布新文章：

1. **在 Obsidian 中写文章**
   ```markdown
   # 博客文章/dev/我的新文章.md
   
   ---
   title: 我的新文章
   date: 2024-07-11
   category: dev
   cover: /covers/my-cover.jpg
   ---
   
   ## 内容开始
   
   ![图片](/images/my-image.jpg)
   ```

2. **添加图片**
   - 将图片放到 `博客图片/images/` 或 `博客图片/covers/`
   - 在文章中正常引用

3. **一键同步**
   - 打开命令面板（Cmd/Ctrl + P）
   - 搜索 "GitHub Sync: Sync to GitHub"
   - 点击执行

4. **自动完成**
   - ✅ 文章和图片自动推送到 GitHub
   - ✅ Vercel 自动检测更新并部署
   - ✅ 博客网站自动更新

## 🚀 高级配置

### 自动图片处理

您仍然可以使用我们之前配置的 R2 上传脚本：

1. **同步到 GitHub 后**
2. **在终端运行**：`npm run upload-media`
3. **图片自动上传到 R2 并更新链接**

### 完全自动化流程

我可以为您创建一个 GitHub Action，每次推送后自动：

1. 运行图片上传脚本
2. 自动部署到 Vercel
3. 发送部署通知

## 💡 优势对比

| 特性 | GitHub Sync | GitHub Publisher |
|------|-------------|------------------|
| 设置复杂度 | 🟢 简单 | 🟡 中等 |
| 文件夹同步 | ✅ | ❌ |
| 批量操作 | ✅ | ✅ |
| 图片处理 | 🟡 需配置 | ✅ |
| 移动端 | ✅ | ✅ |

## 🎯 推荐配置

由于您已经有了 GitHub Token，我建议：

1. **使用 GitHub Sync** 进行文件同步
2. **保留 R2 上传脚本** 处理图片优化
3. **设置自动化** 完全无需手动操作

这样既简单又功能完整！

---

## 🔧 需要我帮您配置吗？

请告诉我：
1. 您是否已经安装了 GitHub Sync 插件？
2. 您希望在 Obsidian 中如何组织博客文件？
3. 是否需要我创建自动化脚本？