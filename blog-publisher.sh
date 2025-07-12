#!/bin/bash

# 新的简化博客发布系统 - 稳定可靠版本
# 核心原则：
# 1. 简单的英文文件名，避免中文和特殊字符
# 2. 明确的目录结构，避免混乱
# 3. 步骤检查，确保每步成功再继续
# 4. 保守的错误处理，出错就停止

BLOG_DIR="/Users/shannonwang/Documents/blog"
OBSIDIAN_VAULT="/Users/shannonwang/Library/Mobile Documents/iCloud~md~obsidian/Documents/Shannon"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️ $1${NC}"; }

# 检查前置条件
check_prerequisites() {
    print_info "检查前置条件..."
    
    if [ ! -d "$OBSIDIAN_VAULT" ]; then
        print_error "Obsidian 目录不存在: $OBSIDIAN_VAULT"
        exit 1
    fi
    
    if [ ! -d "$BLOG_DIR" ]; then
        print_error "博客目录不存在: $BLOG_DIR"
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "npm 未安装"
        exit 1
    fi
    
    print_success "前置条件检查通过"
}

# 生成安全的文件名 - 只允许英文、数字、连字符
generate_safe_filename() {
    local title="$1"
    local date="$2"
    
    # 提取英文和数字，替换空格为连字符
    local safe_name=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | tr ' ' '-' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    
    # 如果处理后为空或太短，使用日期
    if [ -z "$safe_name" ] || [ ${#safe_name} -lt 3 ]; then
        safe_name="post-$(date +%Y%m%d%H%M%S)"
    fi
    
    echo "$safe_name"
}

# 处理单个文章
process_article() {
    local source_file="$1"
    local filename=$(basename "$source_file" .md)
    
    print_info "处理文章: $filename"
    
    # 读取 frontmatter 获取 title
    local title=$(grep "^title:" "$source_file" | head -1 | sed 's/title: *//g' | tr -d '"')
    local date=$(grep "^date:" "$source_file" | head -1 | sed 's/date: *//g')
    
    if [ -z "$title" ]; then
        print_warning "文章缺少 title，跳过: $filename"
        return 1
    fi
    
    # 生成安全的文件名
    local safe_filename=$(generate_safe_filename "$title" "$date")
    local target_file="$BLOG_DIR/posts/dev/${safe_filename}.mdx"
    
    print_info "转换为: ${safe_filename}.mdx"
    
    # 复制文件并转换为 mdx
    cp "$source_file" "$target_file"
    
    # 修复 frontmatter 格式
    fix_frontmatter "$target_file"
    
    # 修复图片引用
    fix_image_references "$target_file"
    
    print_success "文章处理完成: ${safe_filename}.mdx"
}

# 修复 frontmatter 格式
fix_frontmatter() {
    local file="$1"
    
    # 确保 title 和 description 有引号
    sed -i '' 's/^title: \([^"]\)/title: "\1/g' "$file"
    sed -i '' 's/^description: \([^"]\)/description: "\1/g' "$file"
    
    # 确保引号闭合
    sed -i '' 's/^title: "\([^"]*\)$/title: "\1"/g' "$file"
    sed -i '' 's/^description: "\([^"]*\)$/description: "\1"/g' "$file"
    
    # 转换 YAML 数组格式的 tags
    if grep -q "^  - " "$file"; then
        python3 -c "
import re

with open('$file', 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
new_lines = []
in_tags = False
tags_values = []

for line in lines:
    if line.startswith('tags:') and not line.strip().endswith(','):
        in_tags = True
        continue
    elif in_tags and line.startswith('  - '):
        tags_values.append(line.replace('  - ', '').strip())
        continue
    elif in_tags and not line.startswith('  '):
        if tags_values:
            new_lines.append('tags: ' + ', '.join(tags_values))
        new_lines.append(line)
        in_tags = False
        tags_values = []
    else:
        if not in_tags:
            new_lines.append(line)

if in_tags and tags_values:
    new_lines.append('tags: ' + ', '.join(tags_values))

with open('$file', 'w', encoding='utf-8') as f:
    f.write('\n'.join(new_lines))
"
    fi
    
    # 确保有 cover 字段
    if ! grep -q "^cover:" "$file"; then
        sed -i '' '/^tags:/a\
cover: /covers/default.jpg
' "$file"
    fi
}

# 修复图片引用
fix_image_references() {
    local file="$1"
    
    # 转换 Obsidian 格式 ![[image.png]] 为 ![图片](/images/image.png)
    sed -i '' 's/!\[\[\([^]]*\)\]\]/![图片](\/images\/\1)/g' "$file"
    
    # 修复图片路径中的空格
    sed -i '' 's|/images/\([^)]*\) \([^)]*\)|/images/\1_\2|g' "$file"
}

# 同步图片文件
sync_images() {
    print_info "同步图片文件..."
    
    # 同步图片
    if [ -d "$OBSIDIAN_VAULT/博客图片/images" ]; then
        rsync -av --delete "$OBSIDIAN_VAULT/博客图片/images/" "$BLOG_DIR/public/images/" --exclude="*.DS_Store" > /dev/null
        
        # 重命名图片文件中的空格
        find "$BLOG_DIR/public/images/" -name "* *" -type f | while read file; do
            newname=$(echo "$file" | tr ' ' '_')
            if [ "$file" != "$newname" ]; then
                mv "$file" "$newname"
                print_info "重命名图片: $(basename "$file") -> $(basename "$newname")"
            fi
        done
        
        print_success "内容图片同步完成"
    fi
    
    # 同步封面
    if [ -d "$OBSIDIAN_VAULT/博客图片/covers" ]; then
        rsync -av --delete "$OBSIDIAN_VAULT/博客图片/covers/" "$BLOG_DIR/public/covers/" --exclude="*.DS_Store" > /dev/null
        
        # 重命名封面文件中的空格
        find "$BLOG_DIR/public/covers/" -name "* *" -type f | while read file; do
            newname=$(echo "$file" | tr ' ' '_')
            if [ "$file" != "$newname" ]; then
                mv "$file" "$newname"
                print_info "重命名封面: $(basename "$file") -> $(basename "$newname")"
            fi
        done
        
        print_success "封面图片同步完成"
    fi
    
    # 确保默认封面存在
    if [ ! -f "$BLOG_DIR/public/covers/default.jpg" ]; then
        first_cover=$(ls "$BLOG_DIR/public/covers/"*.{jpg,jpeg,png} 2>/dev/null | head -1)
        if [ -n "$first_cover" ]; then
            cp "$first_cover" "$BLOG_DIR/public/covers/default.jpg"
            print_info "创建默认封面"
        fi
    fi
}

# 验证构建
verify_build() {
    print_info "验证博客构建..."
    
    cd "$BLOG_DIR"
    
    if npm run build > /tmp/blog-build.log 2>&1; then
        print_success "构建验证通过"
        rm -f /tmp/blog-build.log
        return 0
    else
        print_error "构建失败，详细信息:"
        echo "=================="
        cat /tmp/blog-build.log | tail -20
        echo "=================="
        return 1
    fi
}

# 发布文章
publish_articles() {
    print_info "开始发布博客..."
    
    cd "$BLOG_DIR"
    
    # 检查前置条件
    check_prerequisites
    
    # 清理旧文章
    print_info "清理旧文章..."
    rm -rf "$BLOG_DIR/posts/dev/"*.mdx
    
    # 同步图片
    sync_images
    
    # 处理所有文章
    print_info "处理文章文件..."
    local article_count=0
    
    if [ -d "$OBSIDIAN_VAULT/博客文章/dev" ]; then
        for article in "$OBSIDIAN_VAULT/博客文章/dev/"*.md; do
            if [ -f "$article" ]; then
                if process_article "$article"; then
                    article_count=$((article_count + 1))
                fi
            fi
        done
    fi
    
    if [ $article_count -eq 0 ]; then
        print_warning "没有找到文章文件"
        return 1
    fi
    
    print_success "处理了 $article_count 篇文章"
    
    # 验证构建
    if ! verify_build; then
        print_error "构建验证失败，停止发布"
        return 1
    fi
    
    # 提交到 Git
    if git diff --quiet && git diff --cached --quiet; then
        print_info "没有更改需要提交"
    else
        print_info "提交更改到 Git..."
        git add .
        git commit -m "博客更新: $(date '+%Y-%m-%d %H:%M:%S') - 发布 $article_count 篇文章

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
        
        print_success "本地提交完成"
        
        # 推送到 GitHub
        if git push origin main; then
            print_success "推送到 GitHub 成功"
        else
            print_error "推送失败"
            return 1
        fi
    fi
    
    print_success "博客发布完成！"
    print_info "访问: https://shannonwang.top"
}

# 主函数
main() {
    case "$1" in
        "publish")
            publish_articles
            ;;
        "sync-images")
            sync_images
            ;;
        "verify")
            verify_build
            ;;
        *)
            echo "用法: $0 {publish|sync-images|verify}"
            echo ""
            echo "命令说明:"
            echo "  publish     - 完整发布流程"
            echo "  sync-images - 仅同步图片"
            echo "  verify      - 仅验证构建"
            exit 1
            ;;
    esac
}

main "$@"