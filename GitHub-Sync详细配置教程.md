# 🔧 GitHub Sync 插件配置详细步骤

## 📱 在 Obsidian 中的具体操作

### 1. 打开插件设置

```
Obsidian → 设置 (⚙️) → 社区插件 → GitHub Sync → 选项
```

### 2. 基础配置填写

在插件设置界面中，您会看到以下字段：

#### Repository Configuration:
```
Repository Owner: freedomshannon
Repository Name: blog
Branch: main
```

#### Authentication:
```
GitHub Token: [您的_GitHub_Token]
```

#### Sync Configuration:
```
Root Path: / (保持默认)
Auto Sync: ❌ (关闭，手动控制)
Sync on Startup: ❌ (关闭)
```

### 3. 路径映射 (Path Mapping)

如果插件支持路径映射，添加以下规则：

```json
{
  "博客文章": "posts",
  "博客图片/images": "public/images", 
  "博客图片/covers": "public/covers"
}
```

### 4. 忽略文件 (Ignore Patterns)

添加以下忽略模式：

```
.obsidian/
.trash/
.DS_Store
Thumbs.db
*.tmp
*~
其他笔记/
```

## 🎯 关键配置说明

### Repository URL 格式
如果插件要求完整 URL，使用：
```
https://github.com/freedomshannon/blog.git
```

### Commit Message 模板
设置自动提交信息：
```
博客更新: {{date}} {{time}}
```

### Sync Behavior
- **Manual Sync**: 推荐，避免意外同步
- **Selective Sync**: 只同步指定文件夹
- **Conflict Resolution**: 选择 "Local Wins" 或 "Prompt"

## 📂 Obsidian 文件夹结构创建

在您的 Obsidian 文库根目录创建：

```
mkdir -p "博客文章/dev"
mkdir -p "博客文章/ai" 
mkdir -p "博客文章/life"
mkdir -p "博客图片/images"
mkdir -p "博客图片/covers"
```

## 🧪 测试配置

### 创建测试文章

在 `博客文章/dev/` 下创建 `测试文章.md`：

```markdown
---
title: 测试 GitHub Sync
date: 2024-07-11
category: dev
cover: /covers/test.jpg
---

# 测试文章

这是测试 GitHub Sync 插件的文章。

![测试图片](/images/test.jpg)
```

### 添加测试图片

将任意图片复制到：
- `博客图片/covers/test.jpg`
- `博客图片/images/test.jpg`

### 执行同步

1. **打开命令面板**: `Cmd/Ctrl + P`
2. **搜索**: `GitHub Sync`
3. **选择**: `GitHub Sync: Push to GitHub`
4. **确认**: 检查 GitHub 仓库是否收到文件

## ⚠️ 常见问题解决

### Token 权限错误
确保 GitHub Token 有以下权限：
- ✅ `repo` (完整仓库访问)
- ✅ `contents` (读写仓库内容)

### 路径映射不生效
某些版本的插件可能不支持路径映射，此时：
1. 直接在 Obsidian 根目录创建 `posts/` 文件夹
2. 或使用符号链接连接到博客项目

### 同步失败
检查：
1. 网络连接
2. Token 是否过期
3. 仓库名称是否正确
4. 分支是否存在

## 🚀 高级技巧

### 设置快捷键
为同步命令设置快捷键：
```
设置 → 快捷键 → 搜索 "GitHub Sync" → 设置为 Cmd+Shift+S
```

### 自动提交信息
使用动态变量：
```
{{date:YYYY-MM-DD HH:mm}} 博客更新
```

### 批量同步
选择多个文件夹，一次性同步所有更改。

---

## ✅ 配置完成检查清单

- [ ] GitHub Token 已配置
- [ ] 仓库信息已填写
- [ ] 路径映射已设置
- [ ] 忽略规则已添加
- [ ] 测试文章已创建
- [ ] 测试同步已成功
- [ ] GitHub 仓库已收到文件

完成这些步骤后，您就可以享受在 Obsidian 中一键发布博客的便利了！