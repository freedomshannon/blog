#!/bin/bash

# 博客发布系统 - 最终稳定版
# 设计原则：简单、可靠、可预测

BLOG_DIR="/Users/shannonwang/Documents/blog"
OBSIDIAN_VAULT="/Users/shannonwang/Library/Mobile Documents/iCloud~md~obsidian/Documents/Shannon"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_error() { echo -e "${RED}❌ $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️ $1${NC}"; }

# 生成简单安全的文件名
generate_filename() {
    local source_file="$1"
    local original_name=$(basename "$source_file" .md)
    
    # 如果是英文文件名，直接使用
    if [[ "$original_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "$original_name"
        return
    fi
    
    # 从文件内容提取 title
    local title=$(grep "^title:" "$source_file" | head -1 | sed 's/title: *"*//g' | sed 's/"*$//g')
    
    # 提取英文单词生成文件名
    local clean_name=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | tr ' ' '-' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    
    # 如果提取不到合适的名称，使用时间戳
    if [ -z "$clean_name" ] || [ ${#clean_name} -lt 3 ]; then
        clean_name="article-$(date +%Y%m%d-%H%M%S)"
    fi
    
    echo "$clean_name"
}

# 处理 frontmatter 标准化
standardize_frontmatter() {
    local file="$1"
    
    # 使用更可靠的 Python 脚本处理
    python3 << EOF
import re

with open('$file', 'r', encoding='utf-8') as f:
    content = f.read()

# 分离 frontmatter 和正文
parts = content.split('---')
if len(parts) >= 3:
    frontmatter = parts[1]
    body = '---'.join(parts[2:])
    
    # 标准化 title 字段
    frontmatter = re.sub(r'^title:\s*(.+?)$', lambda m: f'title: "{m.group(1).strip().strip(\\"\\')}"', frontmatter, flags=re.MULTILINE)
    
    # 标准化 description 字段
    frontmatter = re.sub(r'^description:\s*(.+?)$', lambda m: f'description: "{m.group(1).strip().strip(\\"\\')}"', frontmatter, flags=re.MULTILINE)
    
    # 处理 YAML 数组格式的 tags
    lines = frontmatter.split('\n')
    new_lines = []
    in_tags = False
    tag_values = []
    
    for line in lines:
        if line.strip().startswith('tags:') and ':' in line:
            if line.strip().endswith(':'):
                in_tags = True
                continue
            else:
                new_lines.append(line)
                continue
        elif in_tags and line.strip().startswith('- '):
            tag_values.append(line.strip()[2:].strip())
            continue
        elif in_tags and not line.strip().startswith('- ') and line.strip():
            if tag_values:
                new_lines.append(f'tags: {", ".join(tag_values)}')
                tag_values = []
            new_lines.append(line)
            in_tags = False
        else:
            if not in_tags:
                new_lines.append(line)
    
    # 如果文件末尾还有未处理的 tags
    if in_tags and tag_values:
        new_lines.append(f'tags: {", ".join(tag_values)}')
    
    frontmatter = '\n'.join(new_lines)
    
    # 确保有 cover 字段
    if 'cover:' not in frontmatter:
        frontmatter += '\ncover: /covers/default.jpg'
    
    # 重新组合
    content = '---' + frontmatter + '---' + body

with open('$file', 'w', encoding='utf-8') as f:
    f.write(content)
EOF
}

# 修复图片引用
fix_images() {
    local file="$1"
    
    # 转换 Obsidian 格式
    sed -i '' 's/!\[\[\([^]]*\)\]\]/![图片](\/images\/\1)/g' "$file"
    
    # 修复空格
    sed -i '' 's|/images/\([^)]*\) \([^)]*\)|/images/\1_\2|g' "$file"
}

# 同步图片
sync_images() {
    print_info "同步图片..."
    
    # 内容图片
    if [ -d "$OBSIDIAN_VAULT/博客图片/images" ]; then
        rsync -av "$OBSIDIAN_VAULT/博客图片/images/" "$BLOG_DIR/public/images/" --exclude="*.DS_Store" --quiet
        
        # 处理空格
        find "$BLOG_DIR/public/images/" -name "* *" -type f | while read -r file; do
            mv "$file" "$(echo "$file" | tr ' ' '_')"
        done
    fi
    
    # 封面图片
    if [ -d "$OBSIDIAN_VAULT/博客图片/covers" ]; then
        rsync -av "$OBSIDIAN_VAULT/博客图片/covers/" "$BLOG_DIR/public/covers/" --exclude="*.DS_Store" --quiet
        
        # 处理空格
        find "$BLOG_DIR/public/covers/" -name "* *" -type f | while read -r file; do
            mv "$file" "$(echo "$file" | tr ' ' '_')"
        done
    fi
    
    # 确保默认封面
    if [ ! -f "$BLOG_DIR/public/covers/default.jpg" ]; then
        first_image=$(find "$BLOG_DIR/public/covers/" -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" | head -1)
        if [ -n "$first_image" ]; then
            cp "$first_image" "$BLOG_DIR/public/covers/default.jpg"
        fi
    fi
    
    print_success "图片同步完成"
}

# 发布主函数
publish() {
    print_info "开始发布博客..."
    
    cd "$BLOG_DIR" || exit 1
    
    # 备份现有文章
    if [ -d "posts/dev" ] && [ "$(ls -A posts/dev)" ]; then
        backup_dir="backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r posts/dev/* "$backup_dir/" 2>/dev/null || true
        print_info "已备份现有文章到: $backup_dir"
    fi
    
    # 清空目标目录
    rm -rf posts/dev/*.mdx 2>/dev/null || true
    
    # 同步图片
    sync_images
    
    # 处理所有文章
    local count=0
    local processed_files=()
    
    if [ -d "$OBSIDIAN_VAULT/博客文章/dev" ]; then
        for article in "$OBSIDIAN_VAULT/博客文章/dev"/*.md; do
            if [ -f "$article" ]; then
                filename=$(generate_filename "$article")
                
                # 避免重复文件名
                original_filename="$filename"
                counter=1
                while [[ " ${processed_files[*]} " =~ " ${filename} " ]]; do
                    filename="${original_filename}-${counter}"
                    counter=$((counter + 1))
                done
                processed_files+=("$filename")
                
                target="posts/dev/${filename}.mdx"
                
                print_info "处理: $(basename "$article") -> ${filename}.mdx"
                
                cp "$article" "$target"
                standardize_frontmatter "$target"
                fix_images "$target"
                
                count=$((count + 1))
            fi
        done
    fi
    
    if [ $count -eq 0 ]; then
        print_error "没有找到文章文件"
        return 1
    fi
    
    print_success "成功处理 $count 篇文章"
    
    # 验证构建
    print_info "验证构建..."
    if npm run build > /tmp/build.log 2>&1; then
        print_success "构建成功"
        rm -f /tmp/build.log
    else
        print_error "构建失败："
        tail -10 /tmp/build.log
        return 1
    fi
    
    # Git 提交
    if ! git diff --quiet || ! git diff --cached --quiet; then
        git add .
        git commit -m "博客更新: $(date '+%Y-%m-%d %H:%M:%S') - 发布 $count 篇文章

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
        
        if git push origin main; then
            print_success "发布完成！"
            print_info "访问: https://shannonwang.top"
        else
            print_error "推送失败"
            return 1
        fi
    else
        print_info "没有更改需要提交"
    fi
}

# 主入口
case "${1:-publish}" in
    "publish") publish ;;
    "sync") sync_images ;;
    *) echo "用法: $0 [publish|sync]"; exit 1 ;;
esac