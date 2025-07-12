#!/bin/bash

# 博客完整发布系统 - 终极版本
# 这次一定要成功！！！

set -e  # 任何错误都立即退出

BLOG_DIR="/Users/shannonwang/Documents/blog"
OBSIDIAN_VAULT="/Users/shannonwang/Library/Mobile Documents/iCloud~md~obsidian/Documents/Shannon"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

error() { echo -e "${RED}❌ ERROR: $1${NC}" >&2; exit 1; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }

# 第0步：检查环境
check_environment() {
    info "检查发布环境..."
    
    [ ! -d "$BLOG_DIR" ] && error "博客目录不存在: $BLOG_DIR"
    [ ! -d "$OBSIDIAN_VAULT" ] && error "Obsidian目录不存在: $OBSIDIAN_VAULT"
    command -v npm >/dev/null || error "npm未安装"
    
    cd "$BLOG_DIR" || error "无法进入博客目录"
    success "环境检查通过"
}

# 第1步：清理并准备
clean_and_prepare() {
    info "清理旧文件并准备..."
    
    # 创建时间戳备份
    local backup_dir="backup-$(date +%Y%m%d-%H%M%S)"
    if [ -d "posts/dev" ] && [ "$(ls -A posts/dev 2>/dev/null)" ]; then
        mkdir -p "$backup_dir"
        cp -r posts/dev/* "$backup_dir/" 2>/dev/null || true
        info "已备份到: $backup_dir"
    fi
    
    # 彻底清理
    rm -rf posts/dev/*.mdx 2>/dev/null || true
    rm -rf public/images/* 2>/dev/null || true
    rm -rf public/covers/* 2>/dev/null || true
    
    # 确保目录存在
    mkdir -p posts/dev public/images public/covers
    
    success "清理完成"
}

# 第2步：同步图片文件
sync_all_images() {
    info "同步所有图片文件..."
    
    # 同步内容图片
    if [ -d "$OBSIDIAN_VAULT/博客图片/images" ]; then
        cp -r "$OBSIDIAN_VAULT/博客图片/images/"* "$BLOG_DIR/public/images/" 2>/dev/null || true
        info "内容图片同步完成"
    fi
    
    # 同步封面图片
    if [ -d "$OBSIDIAN_VAULT/博客图片/covers" ]; then
        cp -r "$OBSIDIAN_VAULT/博客图片/covers/"* "$BLOG_DIR/public/covers/" 2>/dev/null || true
        info "封面图片同步完成"
    fi
    
    # 处理文件名中的空格 - 统一为下划线
    find "$BLOG_DIR/public/images/" -name "* *" -type f 2>/dev/null | while read -r file; do
        if [ -f "$file" ]; then
            newname=$(echo "$file" | tr ' ' '_')
            mv "$file" "$newname"
            info "重命名图片: $(basename "$file") -> $(basename "$newname")"
        fi
    done
    
    find "$BLOG_DIR/public/covers/" -name "* *" -type f 2>/dev/null | while read -r file; do
        if [ -f "$file" ]; then
            newname=$(echo "$file" | tr ' ' '_')
            mv "$file" "$newname"
            info "重命名封面: $(basename "$file") -> $(basename "$newname")"
        fi
    done
    
    # 确保有默认封面
    if [ ! -f "$BLOG_DIR/public/covers/default.jpg" ]; then
        first_cover=$(find "$BLOG_DIR/public/covers/" -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" 2>/dev/null | head -1)
        if [ -n "$first_cover" ] && [ -f "$first_cover" ]; then
            cp "$first_cover" "$BLOG_DIR/public/covers/default.jpg"
            info "创建默认封面"
        else
            # 创建一个简单的默认封面
            touch "$BLOG_DIR/public/covers/default.jpg"
            warning "没有找到封面图片，创建了空的默认封面"
        fi
    fi
    
    success "图片同步完成"
    
    # 显示图片统计
    local img_count=$(find "$BLOG_DIR/public/images/" -type f 2>/dev/null | wc -l)
    local cover_count=$(find "$BLOG_DIR/public/covers/" -type f 2>/dev/null | wc -l)
    info "图片统计: images($img_count个), covers($cover_count个)"
}

# 第3步：处理文章文件
process_articles() {
    info "处理文章文件..."
    
    local article_count=0
    local processed_names=()
    
    if [ ! -d "$OBSIDIAN_VAULT/博客文章/dev" ]; then
        error "没有找到Obsidian文章目录"
    fi
    
    # 处理每个文章
    for source_file in "$OBSIDIAN_VAULT/博客文章/dev/"*.md; do
        [ ! -f "$source_file" ] && continue
        
        local filename=$(basename "$source_file" .md)
        info "处理文章: $filename"
        
        # 生成安全的文件名
        local safe_name=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
        
        # 如果文件名太短或为空，使用时间戳
        if [ -z "$safe_name" ] || [ ${#safe_name} -lt 3 ]; then
            safe_name="post-$(date +%Y%m%d%H%M%S)-$article_count"
        fi
        
        # 确保文件名唯一
        local final_name="$safe_name"
        local counter=1
        while [[ " ${processed_names[*]} " =~ " $final_name " ]]; do
            final_name="${safe_name}-${counter}"
            counter=$((counter + 1))
        done
        processed_names+=("$final_name")
        
        local target_file="$BLOG_DIR/posts/dev/${final_name}.mdx"
        
        # 复制文件
        cp "$source_file" "$target_file"
        
        # 修复文件内容
        fix_article_content "$target_file"
        
        article_count=$((article_count + 1))
        info "完成: $filename -> ${final_name}.mdx"
    done
    
    [ $article_count -eq 0 ] && error "没有找到任何文章文件"
    
    success "处理了 $article_count 篇文章"
}

# 修复文章内容
fix_article_content() {
    local file="$1"
    
    # 使用Python进行可靠的格式修复
    python3 << EOF
import re

try:
    with open('$file', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 分离frontmatter和正文
    parts = content.split('---')
    if len(parts) >= 3:
        frontmatter = parts[1]
        body = '---'.join(parts[2:])
        
        # 修复title字段
        if 'title:' in frontmatter:
            lines = frontmatter.split('\n')
            for i, line in enumerate(lines):
                if line.strip().startswith('title:'):
                    title_content = line.split('title:', 1)[1].strip()
                    if not title_content.startswith('"'):
                        title_content = f'"{title_content}"'
                    if not title_content.endswith('"'):
                        title_content = f'{title_content}"'
                    title_content = title_content.replace('""', '"')
                    lines[i] = f'title: {title_content}'
            frontmatter = '\n'.join(lines)
        
        # 修复description字段
        if 'description:' in frontmatter:
            lines = frontmatter.split('\n')
            for i, line in enumerate(lines):
                if line.strip().startswith('description:'):
                    desc_content = line.split('description:', 1)[1].strip()
                    if not desc_content.startswith('"'):
                        desc_content = f'"{desc_content}"'
                    if not desc_content.endswith('"'):
                        desc_content = f'{desc_content}"'
                    desc_content = desc_content.replace('""', '"')
                    lines[i] = f'description: {desc_content}'
            frontmatter = '\n'.join(lines)
        
        # 处理tags - 转换YAML数组为逗号分隔
        lines = frontmatter.split('\n')
        new_lines = []
        in_tags = False
        tag_values = []
        
        for line in lines:
            if line.strip().startswith('tags:'):
                if ':' in line and line.strip() != 'tags:':
                    new_lines.append(line)
                else:
                    in_tags = True
            elif in_tags and line.strip().startswith('- '):
                tag_values.append(line.strip()[2:].strip())
            elif in_tags and line.strip() and not line.startswith('  '):
                if tag_values:
                    new_lines.append(f'tags: {", ".join(tag_values)}')
                    tag_values = []
                new_lines.append(line)
                in_tags = False
            else:
                if not in_tags:
                    new_lines.append(line)
        
        if in_tags and tag_values:
            new_lines.append(f'tags: {", ".join(tag_values)}')
        
        frontmatter = '\n'.join(new_lines)
        
        # 确保有cover字段
        if 'cover:' not in frontmatter:
            frontmatter += '\ncover: /covers/default.jpg'
        
        # 修复正文中的图片引用
        # 1. Obsidian格式 ![[image.png]] -> ![图片](/images/image.png)
        body = re.sub(r'!\[\[([^]]+)\]\]', r'![图片](/images/\1)', body)
        
        # 2. 修复图片路径中的空格
        body = re.sub(r'/images/([^)]*) ([^)]*)', r'/images/\1_\2', body)
        
        # 重新组合
        content = '---' + frontmatter + '---' + body
        
        with open('$file', 'w', encoding='utf-8') as f:
            f.write(content)
            
except Exception as e:
    print(f"Error processing file: {e}")
    exit(1)
EOF
}

# 第4步：构建验证
verify_build() {
    info "验证网站构建..."
    
    if npm run build > /tmp/blog-build.log 2>&1; then
        success "构建验证成功"
        rm -f /tmp/blog-build.log
    else
        error "构建失败！错误详情:\n$(tail -20 /tmp/blog-build.log)"
    fi
}

# 第5步：Git提交和推送
commit_and_push() {
    info "提交到Git并推送..."
    
    # 检查是否有更改
    if git diff --quiet && git diff --cached --quiet; then
        info "没有更改需要提交"
        return 0
    fi
    
    # 添加所有更改
    git add .
    
    # 提交
    local commit_msg="博客发布: $(date '+%Y-%m-%d %H:%M:%S')

✨ 完整发布流程
- 同步所有文章和图片
- 修复格式和图片路径
- 验证构建成功

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    git commit -m "$commit_msg"
    success "本地提交完成"
    
    # 推送到远程
    if git push origin main; then
        success "推送到GitHub成功"
    else
        error "推送失败"
    fi
}

# 第6步：上传图片到R2 CDN
upload_to_r2() {
    info "上传图片到 Cloudflare R2..."
    
    if npm run upload-media > /tmp/r2-upload.log 2>&1; then
        success "图片上传到R2成功"
        rm -f /tmp/r2-upload.log
    else
        warning "R2上传失败，但不影响网站运行"
        info "本地图片仍然可用"
    fi
}

# 第7步：最终验证
final_verification() {
    info "进行最终验证..."
    
    # 再次构建确保一切正常
    if npm run build > /dev/null 2>&1; then
        success "最终构建验证通过"
    else
        error "最终验证失败"
    fi
    
    # 统计信息
    local article_count=$(find posts/dev/ -name "*.mdx" 2>/dev/null | wc -l)
    local image_count=$(find public/images/ -type f 2>/dev/null | wc -l)
    local cover_count=$(find public/covers/ -type f 2>/dev/null | wc -l)
    
    echo ""
    echo -e "${BOLD}🎉 发布完成！${NC}"
    echo -e "${GREEN}📊 统计信息:${NC}"
    echo -e "   文章: $article_count 篇"
    echo -e "   图片: $image_count 个"
    echo -e "   封面: $cover_count 个"
    echo ""
    echo -e "${BLUE}🌐 访问链接:${NC}"
    echo -e "   https://shannonwang.top"
    echo ""
    echo -e "${YELLOW}📝 文章链接:${NC}"
    for mdx_file in posts/dev/*.mdx; do
        if [ -f "$mdx_file" ]; then
            local slug=$(basename "$mdx_file" .mdx)
            echo -e "   https://shannonwang.top/posts/dev/$slug"
        fi
    done
}

# 主函数 - 完整发布流程
main() {
    echo -e "${BOLD}🚀 开始博客完整发布流程${NC}"
    echo "=================================="
    
    check_environment
    clean_and_prepare
    sync_all_images
    process_articles
    verify_build
    commit_and_push
    upload_to_r2
    final_verification
    
    echo -e "${BOLD}${GREEN}✨ 所有步骤完成！博客已成功发布！${NC}"
}

# 运行主函数
main "$@"