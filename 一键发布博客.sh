#!/bin/bash

echo "🚀 开始发布博客..."
echo "=================="

BLOG_DIR="/Users/shannonwang/Documents/blog"
OBSIDIAN_VAULT="/Users/shannonwang/Library/Mobile Documents/iCloud~md~obsidian/Documents/Shannon"

cd "$BLOG_DIR"

# 检查是否有更改
echo ""
echo "📁 第1步: 同步文章..."

# 同步文章文件
if [ -d "$OBSIDIAN_VAULT/博客文章" ]; then
    rsync -av --delete "$OBSIDIAN_VAULT/博客文章/" "$BLOG_DIR/posts/"         --exclude="*.DS_Store"         --exclude="📝 文章模板.md"
    
    # 转换 .md 为 .mdx
    find "$BLOG_DIR/posts/" -name "*.md" -type f | while read file; do
        mv "$file" "${file%.md}.mdx"
    done
    
    echo "✅ 文章同步完成"
else
    echo "⚠️ 博客文章文件夹不存在"
fi

echo ""
echo "🖼️ 第2步: 同步图片..."

# 同步图片文件
if [ -d "$OBSIDIAN_VAULT/博客图片/images" ]; then
    rsync -av --delete "$OBSIDIAN_VAULT/博客图片/images/" "$BLOG_DIR/public/images/" --exclude="*.DS_Store"
    echo "✅ 内容图片同步完成"
fi

if [ -d "$OBSIDIAN_VAULT/博客图片/covers" ]; then
    rsync -av --delete "$OBSIDIAN_VAULT/博客图片/covers/" "$BLOG_DIR/public/covers/" --exclude="*.DS_Store"
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
    commit_msg="博客更新: $(date '+%Y-%m-%d %H:%M:%S')

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

    git commit -m "$commit_msg"
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
