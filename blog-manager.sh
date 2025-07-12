#!/bin/bash

# 博客管理脚本 - 包含发布、修复文章和图片的完整功能
# 使用方法：
#   ./blog-manager.sh publish     # 发布博客
#   ./blog-manager.sh fix-posts   # 修复现有文章格式
#   ./blog-manager.sh fix-images  # 修复图片问题
#   ./blog-manager.sh help        # 显示帮助

BLOG_DIR="/Users/shannonwang/Documents/blog"
OBSIDIAN_VAULT="/Users/shannonwang/Library/Mobile Documents/iCloud~md~obsidian/Documents/Shannon"

# 显示帮助信息
show_help() {
    echo "🚀 博客管理脚本"
    echo "=================="
    echo ""
    echo "使用方法："
    echo "  ./blog-manager.sh publish     # 完整发布流程"
    echo "  ./blog-manager.sh fix-posts   # 修复现有文章格式问题"
    echo "  ./blog-manager.sh fix-images  # 修复图片显示问题"
    echo "  ./blog-manager.sh help        # 显示此帮助信息"
    echo ""
    echo "功能说明："
    echo "  publish    - 从 Obsidian 同步文章和图片，修复格式，构建验证，提交发布"
    echo "  fix-posts  - 修复现有文章的 frontmatter 格式和文件名问题"
    echo "  fix-images - 同步和修复图片文件，解决图片显示问题"
}

# 规范化文件名函数
normalize_filenames() {
    local target_dir="$1"
    find "$target_dir" -name "*.mdx" -type f | while read file; do
        dir=$(dirname "$file")
        basename=$(basename "$file" .mdx)
        
        # 规范化文件名：空格替换为连字符，移除特殊字符，保留中文
        new_basename=$(echo "$basename" | sed 's/ /-/g' | sed 's/[^a-zA-Z0-9\u4e00-\u9fff_-]//g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')
        
        # 如果处理后为空，使用时间戳
        if [ -z "$new_basename" ]; then
            new_basename="article-$(date +%Y%m%d%H%M%S)"
        fi
        
        if [ "$basename" != "$new_basename" ]; then
            new_file="$dir/$new_basename.mdx"
            echo "  重命名文件: $basename.mdx -> $new_basename.mdx"
            mv "$file" "$new_file"
        fi
    done
}

# 修复 frontmatter 格式
fix_frontmatter() {
    local file="$1"
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
}

# 同步图片文件
sync_images() {
    echo "🖼️ 同步图片文件..."
    
    # 同步内容图片
    if [ -d "$OBSIDIAN_VAULT/博客图片/images" ]; then
        rsync -av "$OBSIDIAN_VAULT/博客图片/images/" "$BLOG_DIR/public/images/" --exclude="*.DS_Store"
        echo "✅ 内容图片同步完成"
    fi

    # 同步封面图片
    if [ -d "$OBSIDIAN_VAULT/博客图片/covers" ]; then
        rsync -av "$OBSIDIAN_VAULT/博客图片/covers/" "$BLOG_DIR/public/covers/" --exclude="*.DS_Store"
        echo "✅ 封面图片同步完成"
    fi
    
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
        first_cover=$(ls "$BLOG_DIR/public/covers/"*.{jpg,jpeg,png} 2>/dev/null | head -1)
        if [ -n "$first_cover" ]; then
            cp "$first_cover" "$BLOG_DIR/public/covers/default.jpg"
            echo "  创建默认封面: default.jpg"
        fi
    fi
}

# 修复现有文章格式
fix_posts() {
    echo "🔧 修复现有文章格式..."
    echo "=================="
    
    cd "$BLOG_DIR"
    
    echo "📁 规范化文件名..."
    normalize_filenames "$BLOG_DIR/posts/"
    
    echo ""
    echo "📝 修复文章格式..."
    
    # 修复现有的 MDX 文件
    find "$BLOG_DIR/posts/" -name "*.mdx" -type f | while read file; do
        echo "🔍 检查文件: $(basename "$file")"
        fix_frontmatter "$file"
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
    echo "🎉 文章格式修复完成！"
}

# 修复图片问题
fix_images() {
    echo "🖼️ 修复图片显示问题..."
    echo "=================="
    
    cd "$BLOG_DIR"
    
    sync_images
    
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
}

# 完整发布流程
publish_blog() {
    echo "🚀 开始发布博客..."
    echo "=================="
    
    cd "$BLOG_DIR"
    
    # 第1步: 同步文章
    echo ""
    echo "📁 第1步: 同步文章..."
    
    if [ -d "$OBSIDIAN_VAULT/博客文章" ]; then
        rsync -av --delete "$OBSIDIAN_VAULT/博客文章/" "$BLOG_DIR/posts/" \
            --exclude="*.DS_Store" \
            --exclude="📝 文章模板.md"
        
        # 转换 .md 为 .mdx
        find "$BLOG_DIR/posts/" -name "*.md" -type f | while read file; do
            mv "$file" "${file%.md}.mdx"
        done
        
        # 规范化文件名
        normalize_filenames "$BLOG_DIR/posts/"
        
        # 修复 Obsidian 格式问题
        find "$BLOG_DIR/posts/" -name "*.mdx" -type f | while read file; do
            echo "  修复格式: $(basename "$file")"
            
            # 转换 Obsidian 图片格式
            sed -i '' 's/!\[\[\([^]]*\)\]\]/![图片](\/images\/\1)/g' "$file"
            
            # 修复图片路径中的空格问题
            sed -i '' 's|/images/\([^)]*\) \([^)]*\)|/images/\1_\2|g' "$file"
            
            # 修复 frontmatter 格式问题
            fix_frontmatter "$file"
            
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
                sed -i '' '/^tags:/a\
cover: /covers/default.jpg
' "$file"
            fi
        done
        
        echo "✅ 文章同步完成"
    else
        echo "⚠️ 博客文章文件夹不存在"
    fi
    
    # 第2步: 同步图片
    echo ""
    echo "🖼️ 第2步: 同步图片..."
    sync_images
    
    # 第3步: 上传图片到 R2
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
    
    # 第4步: 验证文章格式
    echo ""
    echo "✅ 第4步: 验证文章格式..."
    
    if npm run build > /tmp/build.log 2>&1; then
        echo "✅ 文章格式验证通过"
        rm -f /tmp/build.log
    else
        echo "❌ 文章格式验证失败，请检查以下错误:"
        echo "=================="
        cat /tmp/build.log | grep -A 5 -B 5 "Error\|Failed\|问题"
        echo "=================="
        echo "ℹ️ 完整日志已保存到 /tmp/build.log"
        exit 1
    fi
    
    # 第5步: 提交到 Git
    echo ""
    echo "📦 第5步: 提交到 Git..."
    
    if git diff --quiet && git diff --cached --quiet; then
        echo "📝 没有检测到更改，无需提交"
    else
        git add .
        
        commit_msg="博客更新: $(date '+%Y-%m-%d %H:%M:%S')

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

        git commit -m "$commit_msg"
        echo "✅ 本地提交完成"
    fi
    
    # 第6步: 推送到 GitHub
    echo ""
    echo "🚀 第6步: 推送到 GitHub..."
    
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
}

# 主函数
main() {
    case "$1" in
        "publish")
            publish_blog
            ;;
        "fix-posts")
            fix_posts
            ;;
        "fix-images")
            fix_images
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            echo "❌ 未知命令: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"