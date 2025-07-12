#!/bin/bash

echo "🖼️ 修复图片显示问题..."
echo "=================="

BLOG_DIR="/Users/shannonwang/Documents/blog"
OBSIDIAN_VAULT="/Users/shannonwang/Library/Mobile Documents/iCloud~md~obsidian/Documents/Shannon"

cd "$BLOG_DIR"

echo "📁 同步图片文件..."

# 同步图片文件
if [ -d "$OBSIDIAN_VAULT/博客图片/images" ]; then
    rsync -av "$OBSIDIAN_VAULT/博客图片/images/" "$BLOG_DIR/public/images/" --exclude="*.DS_Store"
    echo "✅ 内容图片同步完成"
fi

if [ -d "$OBSIDIAN_VAULT/博客图片/covers" ]; then
    rsync -av "$OBSIDIAN_VAULT/博客图片/covers/" "$BLOG_DIR/public/covers/" --exclude="*.DS_Store"
    echo "✅ 封面图片同步完成"
fi

echo ""
echo "🔧 处理图片文件名..."

# 重命名图片文件，将空格替换为下划线
find "$BLOG_DIR/public/images/" -name "* *" -type f | while read file; do
    newname=$(echo "$file" | tr ' ' '_')
    if [ "$file" != "$newname" ]; then
        mv "$file" "$newname"
        echo "  重命名图片: $(basename "$file") -> $(basename "$newname")"
    fi
done

find "$BLOG_DIR/public/covers/" -name "* *" -type f | while read file; do
    newname=$(echo "$file" | tr ' ' '_')
    if [ "$file" != "$newname" ]; then
        mv "$file" "$newname"
        echo "  重命名封面: $(basename "$file") -> $(basename "$newname")"
    fi
done

# 创建默认封面（如果不存在）
if [ ! -f "$BLOG_DIR/public/covers/default.jpg" ]; then
    # 使用第一个可用的图片作为默认封面
    first_cover=$(ls "$BLOG_DIR/public/covers/"*.{jpg,jpeg,png} 2>/dev/null | head -1)
    if [ -n "$first_cover" ]; then
        cp "$first_cover" "$BLOG_DIR/public/covers/default.jpg"
        echo "  创建默认封面: default.jpg"
    fi
fi

echo ""
echo "📝 修复文章中的图片路径..."

# 修复文章中的图片路径
find "$BLOG_DIR/posts/" -name "*.mdx" -type f | while read file; do
    echo "  检查文件: $(basename "$file")"
    
    # 修复图片路径中的空格问题
    sed -i '' 's|/images/\([^)]*\) \([^)]*\)|/images/\1_\2|g' "$file"
    sed -i '' 's|/covers/\([^)]*\) \([^)]*\)|/covers/\1_\2|g' "$file"
done

echo ""
echo "🧪 验证修复结果..."

# 验证构建是否成功
if npm run build > /tmp/image-fix-build.log 2>&1; then
    echo "✅ 图片显示问题已修复！"
    rm -f /tmp/image-fix-build.log
else
    echo "❌ 仍有问题，请检查构建日志："
    echo "=================="
    cat /tmp/image-fix-build.log | tail -20
    echo "=================="
    exit 1
fi

echo ""
echo "🎉 图片修复完成！现在图片应该能正常显示了。"