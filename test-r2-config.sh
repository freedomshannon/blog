#!/bin/bash

echo "🔧 测试 Cloudflare R2 配置..."
echo ""

# 检查 .env 文件是否存在
if [ ! -f .env ]; then
    echo "❌ .env 文件不存在，请先创建"
    exit 1
fi

echo "✅ .env 文件存在"

# 检查必需的环境变量
source .env

missing_vars=()

if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
    missing_vars+=("CLOUDFLARE_ACCOUNT_ID")
fi

if [ -z "$R2_ACCESS_KEY_ID" ]; then
    missing_vars+=("R2_ACCESS_KEY_ID")
fi

if [ -z "$R2_SECRET_ACCESS_KEY" ]; then
    missing_vars+=("R2_SECRET_ACCESS_KEY")
fi

if [ -z "$R2_BUCKET_NAME" ]; then
    missing_vars+=("R2_BUCKET_NAME")
fi

if [ -z "$R2_PUBLIC_URL" ]; then
    missing_vars+=("R2_PUBLIC_URL")
fi

if [ ${#missing_vars[@]} -gt 0 ]; then
    echo "❌ 缺少以下环境变量："
    for var in "${missing_vars[@]}"; do
        echo "   - $var"
    done
    echo ""
    echo "请在 .env 文件中设置这些变量"
    exit 1
fi

echo "✅ 所有必需的环境变量都已设置"
echo ""

# 测试上传脚本
echo "🧪 测试媒体上传脚本..."
echo ""

if pnpm upload-media --dry-run; then
    echo ""
    echo "🎉 配置测试成功！"
    echo ""
    echo "下一步："
    echo "1. 创建测试文章：touch posts/test/test.mdx"
    echo "2. 添加测试图片到 public/images/"
    echo "3. 运行 pnpm upload-media 正式上传"
else
    echo ""
    echo "❌ 配置测试失败，请检查："
    echo "1. Cloudflare 账户 ID 是否正确"
    echo "2. R2 API 密钥是否有效"
    echo "3. 存储桶名称是否正确"
    echo "4. 网络连接是否正常"
fi