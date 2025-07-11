# 📝 Obsidian 一键发布博客指南

## 🎯 目标效果
在 Obsidian 中写完文章后，点击一个按钮就能直接发布到您的博客网站！

## 🔧 插件推荐：GitHub Publisher

### 步骤1：安装插件

1. **打开 Obsidian**
2. **进入设置** → **社区插件**
3. **关闭安全模式**（如果还没关闭）
4. **点击浏览** → 搜索 **"GitHub Publisher"**
5. **安装并启用插件**

### 步骤2：配置 GitHub Token

1. **创建 GitHub Personal Access Token**：
   - 访问：https://github.com/settings/tokens
   - 点击 "Generate new token (classic)"
   - Token name: `obsidian-blog-publisher`
   - 勾选权限：
     - ✅ `repo` (完整仓库权限)
     - ✅ `workflow` (工作流权限)
   - 点击 "Generate token"
   - **复制生成的 token**
   [您的_GitHub_Token]

2. **在 Obsidian 中配置**：
   - 打开 GitHub Publisher 插件设置
   - GitHub Token: 粘贴您的 token
   - Repository: `freedomshannon/blog`
   - Branch: `main`

### 步骤3：配置文件路径映射

```yaml
# 在插件设置中配置路径映射
File tree in repository:
  Root folder: posts/
  
# 图片路径配置
Attachments:
  Folder: public/images/
  
# 文件名配置
File name format: {{date}}_{{title}}
```

### 步骤4：配置文章模板

在 Obsidian 中创建模板文件 `博客文章模板.md`：

```markdown
---
title: "{{title}}"
description: "文章描述"
date: {{date}}
category: dev
tags: 
cover: 
featured: false
---

# {{title}}

在这里写您的文章内容...

## 小标题

内容...

![图片描述](图片路径)
```

### 步骤5：发布流程

1. **在 Obsidian 中写文章**
   - 使用博客模板创建新文章
   - 正常编写内容
   - 添加图片（直接拖拽到 Obsidian）

2. **发布文章**
   - 打开命令面板 (`Cmd/Ctrl + P`)
   - 搜索 "GitHub Publisher: Upload single current active note"
   - 点击执行

3. **自动完成**
   - ✅ 文章自动推送到 GitHub
   - ✅ 图片自动上传
   - ✅ Vercel 自动部署
   - ✅ 博客网站更新

## 🎨 进阶配置

### 自动化图片处理

在插件设置中配置：
```yaml
# 图片自动重命名
Image name: {{date}}-{{uuid}}

# 图片路径转换
Convert image links: true
```

### 批量发布

- 选择多个文件
- 使用 "Upload multiple files" 命令
- 批量发布多篇文章

### 定时发布

在文章 frontmatter 中设置：
```yaml
---
publish: false  # 先设为 false
scheduled: 2024-07-15 10:00  # 定时发布
---
```

## 🚀 一键发布命令

为了更方便，您可以设置快捷键：

1. **进入 Obsidian 设置** → **快捷键**
2. **搜索 "GitHub Publisher"**
3. **为 "Upload single current active note" 设置快捷键**
   - 建议：`Cmd/Ctrl + Shift + P`

现在写完文章直接按快捷键就能发布！

## 📱 移动端支持

GitHub Publisher 插件也支持移动端：
- 在手机/平板上的 Obsidian 中也能一键发布
- 真正做到随时随地写博客

## 🔧 故障排除

### 常见问题：

1. **Token 权限不足**
   - 确保勾选了 `repo` 权限
   - 重新生成 token

2. **路径配置错误**
   - 检查仓库名称是否正确
   - 确认分支名称为 `main`

3. **图片上传失败**
   - 检查图片路径配置
   - 确保图片文件不超过 25MB

---

## 🎉 配置完成后的体验

1. **在 Obsidian 中写文章** 📝
2. **按快捷键发布** ⌨️  
3. **几分钟后访问博客** 🌐
4. **文章已经在线了** ✨

就是这么简单！