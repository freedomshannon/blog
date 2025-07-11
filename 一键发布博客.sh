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
    rsync -av --delete "$OBSIDIAN_VAULT/博客文章/" "$BLOG_DIR/posts/" \
        --exclude="*.DS_Store" \
        --exclude="📝 文章模板.md"
    
    # 转换 .md 为 .mdx 并修复格式
    find "$BLOG_DIR/posts/" -name "*.md" -type f | while read file; do
        mv "$file" "${file%.md}.mdx"
    done
    
    # 修复 Obsidian 格式问题
    find "$BLOG_DIR/posts/" -name "*.mdx" -type f | while read file; do
        echo "  修复格式: $(basename "$file")"
        
        # 转换 Obsidian 图片格式 ![[image.png]] 为 ![图片](/images/image.png)
        sed -i '' 's/!\[\[\([^]]*\)\]\]/![图片](\/images\/\1)/g' "$file"
        
        # 确保 title 和 description 有引号
        sed -i '' 's/^title: \([^"]\)/title: "\1/g' "$file"
        sed -i '' 's/^description: \([^"]\)/description: "\1/g' "$file"
        
        # 转换 YAML 数组格式的 tags 为逗号分隔格式
        if grep -q "^  - " "$file"; then
            echo "    转换 tags 格式"
            python3 -c "
import re
import sys

with open('$file', 'r') as f:
    content = f.read()

# 转换 YAML 数组格式的 tags
lines = content.split('\n')
new_lines = []
in_tags = False
tags_values = []

for line in lines:
    if line.startswith('tags:'):
        in_tags = True
        continue
    elif in_tags and line.startswith('  - '):
        tags_values.append(line.replace('  - ', '').strip())
        continue
    elif in_tags and not line.startswith('  '):
        # tags 结束
        if tags_values:
            new_lines.append('tags: ' + ', '.join(tags_values))
        new_lines.append(line)
        in_tags = False
        tags_values = []
    else:
        if not in_tags:
            new_lines.append(line)

# 如果文件末尾还有 tags
if in_tags and tags_values:
    new_lines.append('tags: ' + ', '.join(tags_values))

with open('$file', 'w') as f:
    f.write('\n'.join(new_lines))
"
        fi
        
        # 检查是否缺少 cover 字段
        if ! grep -q "^cover:" "$file"; then
            echo "    添加默认封面"
            # 在 tags 行后添加默认 cover
            sed -i '' '/^tags:/a\
cover: /covers/default.jpg
' "$file"
        fi
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
    
    # 重命名图片文件，将空格替换为下划线
    find "$BLOG_DIR/public/images/" -name "* *" -type f | while read file; do
        newname=$(echo "$file" | tr ' ' '_')
        if [ "$file" != "$newname" ]; then
            mv "$file" "$newname"
            echo "  重命名图片: $(basename "$file") -> $(basename "$newname")"
        fi
    done
    
    echo "✅ 内容图片同步完成"
fi

if [ -d "$OBSIDIAN_VAULT/博客图片/covers" ]; then
    rsync -av --delete "$OBSIDIAN_VAULT/博客图片/covers/" "$BLOG_DIR/public/covers/" --exclude="*.DS_Store"
    
    # 重命名封面文件，将空格替换为下划线
    find "$BLOG_DIR/public/covers/" -name "* *" -type f | while read file; do
        newname=$(echo "$file" | tr ' ' '_')
        if [ "$file" != "$newname" ]; then
            mv "$file" "$newname"
            echo "  重命名封面: $(basename "$file") -> $(basename "$newname")"
        fi
    done
    
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
