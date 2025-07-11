#!/bin/bash

echo "🔧 修复 Obsidian 到 MDX 格式转换"
echo "================================"

# 处理所有 MDX 文件
find "/Users/shannonwang/Documents/blog/posts" -name "*.mdx" | while read -r file; do
    echo "处理文件: $file"
    
    # 备份原文件
    cp "$file" "$file.backup"
    
    # 1. 转换 Obsidian 图片格式 ![[image.png]] 为标准 Markdown 格式
    sed -i '' 's/!\[\[\([^]]*\)\]\]/![图片](\/images\/\1)/g' "$file"
    
    # 2. 修复 frontmatter 中的 title 加引号
    sed -i '' 's/^title: \([^"]\)/title: "\1/g' "$file"
    sed -i '' 's/^title: "\(.*\)$/title: "\1"/g' "$file"
    
    # 3. 修复 description 加引号  
    sed -i '' 's/^description: \([^"]\)/description: "\1/g' "$file"
    sed -i '' 's/^description: "\(.*\)$/description: "\1"/g' "$file"
    
    # 4. 转换 YAML 数组格式的 tags 为逗号分隔格式
    # 检查是否有 YAML 数组格式的 tags
    if grep -q "^tags:" "$file" && grep -q "^  - " "$file"; then
        echo "  转换 tags 格式..."
        
        # 提取所有 tag 行并转换为逗号分隔格式
        tags_content=$(awk '
        BEGIN { in_tags = 0; tags = "" }
        /^tags:/ { in_tags = 1; next }
        /^  - / && in_tags { 
            gsub(/^  - /, ""); 
            if (tags == "") tags = $0; 
            else tags = tags ", " $0; 
            next 
        }
        /^[a-zA-Z]/ && in_tags { in_tags = 0 }
        !in_tags { print }
        END { if (tags != "") print "tags: " tags }
        ' "$file" > "$file.tmp")
        
        mv "$file.tmp" "$file"
    fi
    
    echo "  ✅ 格式转换完成"
done

echo ""
echo "🧪 验证修复后的文件..."

# 检查是否还有格式问题
problematic_files=()

find "/Users/shannonwang/Documents/blog/posts" -name "*.mdx" | while read -r file; do
    # 检查 Obsidian 图片格式
    if grep -q "!\[\[.*\]\]" "$file"; then
        echo "⚠️ $file 仍包含 Obsidian 图片格式"
        problematic_files+=("$file")
    fi
    
    # 检查未引用的 title
    if grep -q "^title: [^\"']" "$file"; then
        echo "⚠️ $file 的 title 未加引号"
        problematic_files+=("$file")
    fi
    
    # 检查 YAML 数组格式
    if grep -q "^  - " "$file"; then
        echo "⚠️ $file 仍包含 YAML 数组格式"
        problematic_files+=("$file")
    fi
done

echo ""
echo "✅ 格式修复完成"
echo ""

# 测试本地开发服务器
echo "🚀 启动本地开发服务器测试..."
cd "/Users/shannonwang/Documents/blog"

if npm run dev & then
    DEV_PID=$!
    echo "✅ 开发服务器已启动 (PID: $DEV_PID)"
    echo "🌐 请访问 http://localhost:3000 检查文章是否正常显示"
    echo ""
    echo "按回车键停止开发服务器..."
    read
    kill $DEV_PID
else
    echo "❌ 开发服务器启动失败"
fi