#!/bin/bash

echo "📁 Obsidian 文件夹同步 - 一键发布博客"
echo "===================================="
echo ""

# 博客项目路径
BLOG_DIR="/Users/shannonwang/Documents/blog"
cd "$BLOG_DIR"

echo "🔍 正在查找 Obsidian 文库..."

# 常见的 Obsidian 文库位置
POSSIBLE_VAULTS=(
    "$HOME/Documents/Obsidian"
    "$HOME/Documents/我的文库"
    "$HOME/Documents/Notes"
    "$HOME/Obsidian"
    "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
)

OBSIDIAN_VAULT=""

# 自动检测 Obsidian 文库
for vault in "${POSSIBLE_VAULTS[@]}"; do
    if [ -d "$vault" ]; then
        echo "✅ 找到可能的 Obsidian 文库: $vault"
        OBSIDIAN_VAULT="$vault"
        break
    fi
done

if [ -z "$OBSIDIAN_VAULT" ]; then
    echo "❓ 未自动找到 Obsidian 文库，请手动输入路径:"
    read -p "Obsidian 文库完整路径: " OBSIDIAN_VAULT
fi

if [ ! -d "$OBSIDIAN_VAULT" ]; then
    echo "❌ 路径不存在: $OBSIDIAN_VAULT"
    echo "请确认路径是否正确"
    exit 1
fi

echo ""
echo "✅ 使用 Obsidian 文库: $OBSIDIAN_VAULT"
echo ""

echo "🔧 创建博客专用文件夹结构..."

# 创建博客文件夹
mkdir -p "$OBSIDIAN_VAULT/博客文章/dev"
mkdir -p "$OBSIDIAN_VAULT/博客文章/ai"
mkdir -p "$OBSIDIAN_VAULT/博客文章/life"
mkdir -p "$OBSIDIAN_VAULT/博客图片/images"
mkdir -p "$OBSIDIAN_VAULT/博客图片/covers"

echo "✅ 文件夹创建完成"

echo ""
echo "📝 创建文章模板..."

cat > "$OBSIDIAN_VAULT/博客文章/📝 文章模板.md" << 'EOF'
---
title: "文章标题"
description: "文章简介，用于 SEO 和社交分享"
date: 2024-07-11
category: dev
tags: 标签1, 标签2, 标签3
cover: /covers/封面图片名.jpg
featured: false
---

# 文章标题

## 简介

在这里写文章的开头介绍...

## 主要内容

### 小标题1

内容1...

### 小标题2

内容2...

#### 插入图片示例

![图片描述文字](/images/图片文件名.jpg)

#### 插入代码示例

```javascript
const example = "代码示例";
console.log(example);
```

## 总结

总结文章内容...

---

> 💡 **使用提示**: 
> 1. 复制此模板创建新文章
> 2. 修改 frontmatter 中的信息
> 3. 图片放到 "博客图片" 文件夹对应位置
> 4. 完成后运行一键发布脚本
EOF

echo "✅ 文章模板已创建"

echo ""
echo "🚀 创建一键发布脚本..."

# 创建一键发布脚本
cat > "$BLOG_DIR/一键发布博客.sh" << EOF
#!/bin/bash

echo "🚀 开始发布博客..."
echo "=================="

BLOG_DIR="$BLOG_DIR"
OBSIDIAN_VAULT="$OBSIDIAN_VAULT"

cd "\$BLOG_DIR"

# 检查是否有更改
echo ""
echo "📁 第1步: 同步文章..."

# 同步文章文件
if [ -d "\$OBSIDIAN_VAULT/博客文章" ]; then
    rsync -av --delete "\$OBSIDIAN_VAULT/博客文章/" "\$BLOG_DIR/posts/" \
        --exclude="*.DS_Store" \
        --exclude="📝 文章模板.md"
    
    # 转换 .md 为 .mdx
    find "\$BLOG_DIR/posts/" -name "*.md" -type f | while read file; do
        mv "\$file" "\${file%.md}.mdx"
    done
    
    echo "✅ 文章同步完成"
else
    echo "⚠️ 博客文章文件夹不存在"
fi

echo ""
echo "🖼️ 第2步: 同步图片..."

# 同步图片文件
if [ -d "\$OBSIDIAN_VAULT/博客图片/images" ]; then
    rsync -av --delete "\$OBSIDIAN_VAULT/博客图片/images/" "\$BLOG_DIR/public/images/" --exclude="*.DS_Store"
    echo "✅ 内容图片同步完成"
fi

if [ -d "\$OBSIDIAN_VAULT/博客图片/covers" ]; then
    rsync -av --delete "\$OBSIDIAN_VAULT/博客图片/covers/" "\$BLOG_DIR/public/covers/" --exclude="*.DS_Store"
    echo "✅ 封面图片同步完成"
fi

echo ""
echo "☁️ 第3步: 上传图片到 Cloudflare R2..."

if command -v npm >/dev/null 2>&1; then
    if npm run upload-media; then
        echo "✅ 图片上传到 R2 完成"
    else
        echo "⚠️ 图片上传失败，继续发布流程..."
    fi
else
    echo "⚠️ npm 未找到，跳过图片上传"
fi

echo ""
echo "📦 第4步: 提交到 Git..."

# 检查是否有更改
if git diff --quiet && git diff --cached --quiet; then
    echo "📝 没有检测到更改，无需提交"
else
    git add .
    
    # 生成提交信息
    commit_msg="博客更新: \$(date '+%Y-%m-%d %H:%M:%S')

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

    git commit -m "\$commit_msg"
    echo "✅ 本地提交完成"
fi

echo ""
echo "🚀 第5步: 推送到 GitHub..."

if git push origin main; then
    echo "✅ 推送到 GitHub 成功"
    echo ""
    echo "🎉 发布完成！"
    echo "🌐 您的博客将在几分钟内更新"
    echo "🔗 访问: https://shannonwang.top"
else
    echo "❌ 推送失败，请检查网络连接或权限"
    exit 1
fi
EOF

chmod +x "$BLOG_DIR/一键发布博客.sh"

echo "✅ 一键发布脚本已创建"

echo ""
echo "🧪 创建测试文章..."

cat > "$OBSIDIAN_VAULT/博客文章/dev/obsidian-sync-test.md" << 'EOF'
---
title: "Obsidian 同步功能测试"
description: "测试从 Obsidian 到博客的自动同步功能"
date: 2024-07-11
category: dev
tags: Obsidian, 测试, 博客同步
featured: false
---

# Obsidian 同步功能测试

这是一篇测试文章，用于验证从 Obsidian 到博客的自动同步功能。

## 🎯 测试内容

### 文件同步
✅ Markdown 文件从 Obsidian 同步到博客项目  
✅ 自动转换 .md 为 .mdx 格式  

### 图片处理
✅ 图片从 Obsidian 同步到 public 目录  
✅ 自动上传到 Cloudflare R2  
✅ 更新图片链接为 CDN 地址  

### 自动发布
✅ 自动提交到 Git  
✅ 自动推送到 GitHub  
✅ Vercel 自动部署  

## 💡 使用体验

现在我可以：

1. **在 Obsidian 中舒适地写作**
2. **享受 Obsidian 的所有功能** (双链、标签、插件等)
3. **一键发布到博客** 无需复杂操作
4. **专注于内容创作** 而不是技术细节

## 🚀 总结

如果您在博客网站上看到这篇文章，说明 Obsidian 同步功能工作正常！

现在可以开始愉快地写博客了 🎉
EOF

echo "✅ 测试文章已创建"

echo ""
echo "📋 设置完成总结:"
echo ""
echo "📂 Obsidian 文库位置: $OBSIDIAN_VAULT"
echo "📝 博客文章目录: $OBSIDIAN_VAULT/博客文章/"
echo "🖼️ 博客图片目录: $OBSIDIAN_VAULT/博客图片/"
echo "🚀 发布脚本位置: $BLOG_DIR/一键发布博客.sh"
echo ""

echo "🎯 使用方法:"
echo ""
echo "1. 📖 在 Obsidian 中打开 '博客文章/📝 文章模板.md'"
echo "2. ✏️ 复制模板内容，创建新文章"
echo "3. 🖼️ 图片放到 '博客图片/' 对应文件夹"
echo "4. 🚀 运行发布脚本: $BLOG_DIR/一键发布博客.sh"
echo ""

echo "要现在测试发布吗？ (y/n)"
read -p "测试发布: " test_choice

if [[ $test_choice == "y" || $test_choice == "Y" ]]; then
    echo ""
    echo "🧪 开始测试发布..."
    "$BLOG_DIR/一键发布博客.sh"
fi

echo ""
echo "🎉 Obsidian 博客同步设置完成！"
echo "现在您可以在 Obsidian 中愉快地写博客了！"