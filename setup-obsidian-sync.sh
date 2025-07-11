#!/bin/bash

echo "📁 Obsidian 文件夹同步方案设置"
echo "=============================="
echo ""

echo "🎯 工作流程："
echo "1. 在 Obsidian 指定文件夹写文章"
echo "2. 运行一键发布脚本"
echo "3. 自动同步 + 上传图片 + 推送 + 部署"
echo ""

echo "📂 请告诉我您的 Obsidian 文库路径："
echo "示例: /Users/shannonwang/Documents/我的Obsidian文库"
echo ""
read -p "Obsidian 文库路径: " OBSIDIAN_VAULT

if [ ! -d "$OBSIDIAN_VAULT" ]; then
    echo "❌ 路径不存在，请确认路径是否正确"
    exit 1
fi

echo ""
echo "✅ 找到 Obsidian 文库: $OBSIDIAN_VAULT"
echo ""

echo "🔧 创建博客专用文件夹..."

# 在 Obsidian 中创建博客文件夹
mkdir -p "$OBSIDIAN_VAULT/博客文章/dev"
mkdir -p "$OBSIDIAN_VAULT/博客文章/ai" 
mkdir -p "$OBSIDIAN_VAULT/博客文章/life"
mkdir -p "$OBSIDIAN_VAULT/博客图片/images"
mkdir -p "$OBSIDIAN_VAULT/博客图片/covers"

echo "✅ 已创建文件夹结构:"
echo "  $OBSIDIAN_VAULT/博客文章/"
echo "  $OBSIDIAN_VAULT/博客图片/"
echo ""

echo "🔗 创建一键发布脚本..."

# 创建一键发布脚本
cat > /Users/shannonwang/Documents/blog/一键发布博客.sh << EOF
#!/bin/bash

echo "🚀 博客一键发布开始..."
echo "===================="

BLOG_DIR="/Users/shannonwang/Documents/blog"
OBSIDIAN_VAULT="$OBSIDIAN_VAULT"

cd "\$BLOG_DIR"

echo ""
echo "📁 第1步: 同步文章文件..."
# 同步文章（保持 MDX 扩展名）
rsync -av --delete "\$OBSIDIAN_VAULT/博客文章/" "\$BLOG_DIR/posts/" --exclude=".DS_Store"

# 将 .md 文件重命名为 .mdx
find "\$BLOG_DIR/posts/" -name "*.md" -exec sh -c 'mv "\$1" "\${1%.md}.mdx"' _ {} \\;

echo "✅ 文章同步完成"

echo ""
echo "🖼️ 第2步: 同步图片文件..."
# 同步图片
rsync -av --delete "\$OBSIDIAN_VAULT/博客图片/images/" "\$BLOG_DIR/public/images/" --exclude=".DS_Store"
rsync -av --delete "\$OBSIDIAN_VAULT/博客图片/covers/" "\$BLOG_DIR/public/covers/" --exclude=".DS_Store"

echo "✅ 图片同步完成"

echo ""
echo "☁️ 第3步: 上传图片到 Cloudflare R2..."
if npm run upload-media; then
    echo "✅ 图片上传完成"
else
    echo "⚠️ 图片上传失败，但继续发布..."
fi

echo ""
echo "📦 第4步: 推送到 GitHub..."
git add .
git commit -m "博客更新: \$(date '+%Y-%m-%d %H:%M:%S')

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

if git push origin main; then
    echo "✅ 推送成功"
else
    echo "❌ 推送失败"
    exit 1
fi

echo ""
echo "🎉 发布完成！"
echo "您的博客将在几分钟内更新"
echo "访问: https://shannonwang.top"
EOF

chmod +x /Users/shannonwang/Documents/blog/一键发布博客.sh

echo "✅ 一键发布脚本已创建"
echo ""

echo "📝 创建文章模板..."

# 创建文章模板
cat > "$OBSIDIAN_VAULT/博客文章/文章模板.md" << 'EOF'
---
title: "文章标题"
description: "文章简介描述"
date: 2024-07-11
category: dev
tags: 标签1, 标签2
cover: /covers/封面图片.jpg
featured: false
---

# 文章标题

## 介绍

在这里写文章内容...

## 小标题

更多内容...

### 插入图片示例

![图片描述](/images/图片文件名.jpg)

## 总结

总结内容...
EOF

echo "✅ 文章模板已创建: $OBSIDIAN_VAULT/博客文章/文章模板.md"
echo ""

echo "🎯 设置完成！使用方法："
echo ""
echo "1. 📝 在 Obsidian 中打开: 博客文章/文章模板.md"
echo "2. ✏️ 复制模板，创建新文章"
echo "3. 🖼️ 图片放到: 博客图片/images/ 或 博客图片/covers/"
echo "4. 🚀 运行: /Users/shannonwang/Documents/blog/一键发布博客.sh"
echo ""

echo "要现在测试一下吗？(y/n)"
read -p "测试: " test_choice

if [[ $test_choice == "y" || $test_choice == "Y" ]]; then
    echo ""
    echo "🧪 创建测试文章..."
    
    cat > "$OBSIDIAN_VAULT/博客文章/dev/obsidian同步测试.md" << 'EOF'
---
title: "Obsidian 同步测试"
description: "测试 Obsidian 文件夹同步功能"
date: 2024-07-11
category: dev
tags: Obsidian, 测试, 同步
featured: false
---

# Obsidian 同步测试

这是一篇测试文章，用于验证 Obsidian 文件夹同步功能。

## 功能特点

✅ 在 Obsidian 中正常写作  
✅ 自动同步到博客项目  
✅ 一键发布到网站  

## 总结

如果您看到这篇文章，说明同步功能正常工作！
EOF

    echo "✅ 测试文章已创建"
    echo ""
    echo "🚀 运行发布测试..."
    /Users/shannonwang/Documents/blog/一键发布博客.sh
fi

echo ""
echo "🎉 Obsidian 文件夹同步设置完成！"