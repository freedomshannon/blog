#!/bin/bash

echo "🔧 修复现有文章格式..."
echo "=================="

BLOG_DIR="/Users/shannonwang/Documents/blog"
cd "$BLOG_DIR"

# 修复现有的 MDX 文件
find "$BLOG_DIR/posts/" -name "*.mdx" -type f | while read file; do
    echo "🔍 检查文件: $(basename "$file")"
    
    # 修复 frontmatter 格式问题
    python3 -c "
import re
import sys

with open('$file', 'r', encoding='utf-8') as f:
    content = f.read()

# 分离 frontmatter 和内容
parts = content.split('---', 2)
if len(parts) >= 3:
    frontmatter = parts[1]
    main_content = parts[2]
    
    # 修复 title 字段
    old_frontmatter = frontmatter
    frontmatter = re.sub(r'^title:\s*\"?([^\"]*?)\"?\s*$', r'title: \"\1\"', frontmatter, flags=re.MULTILINE)
    
    # 修复 description 字段  
    frontmatter = re.sub(r'^description:\s*\"?([^\"]*?)\"?\s*$', r'description: \"\1\"', frontmatter, flags=re.MULTILINE)
    
    # 检查是否有修改
    if frontmatter != old_frontmatter:
        print('  ✅ 修复了引号问题')
    
    # 重新组合内容
    content = '---' + frontmatter + '---' + main_content

with open('$file', 'w', encoding='utf-8') as f:
    f.write(content)
"
done

echo ""
echo "🧪 验证修复结果..."

# 验证构建是否成功
if npm run build > /tmp/fix-build.log 2>&1; then
    echo "✅ 所有文章格式正确！"
    rm -f /tmp/fix-build.log
else
    echo "❌ 仍有文章格式问题:"
    echo "=================="
    cat /tmp/fix-build.log | grep -A 5 -B 5 "Error\|Failed\|问题"
    echo "=================="
    echo "ℹ️ 完整日志: /tmp/fix-build.log"
    exit 1
fi

echo ""
echo "🎉 修复完成！现在可以正常发布博客了。"