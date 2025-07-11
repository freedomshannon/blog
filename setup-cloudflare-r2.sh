#!/bin/bash

echo "🚀 Cloudflare R2 自动配置脚本"
echo "================================"
echo ""

# 检查是否已登录 Cloudflare
echo "📋 检查 Cloudflare 登录状态..."
if ! wrangler whoami > /dev/null 2>&1; then
    echo "❌ 您需要先登录 Cloudflare"
    echo "请运行以下命令登录："
    echo "wrangler login"
    echo ""
    echo "登录后重新运行此脚本"
    exit 1
fi

echo "✅ 已登录 Cloudflare"
echo ""

# 获取账户信息
echo "📋 获取账户信息..."
ACCOUNT_INFO=$(wrangler whoami)
echo "$ACCOUNT_INFO"
echo ""

# 设置存储桶名称
BUCKET_NAME="blog-media-shannon"
echo "📦 准备创建存储桶: $BUCKET_NAME"

# 创建 R2 存储桶
echo "🔧 创建 R2 存储桶..."
if wrangler r2 bucket create "$BUCKET_NAME"; then
    echo "✅ 存储桶创建成功: $BUCKET_NAME"
else
    echo "⚠️  存储桶可能已存在或创建失败"
fi
echo ""

# 获取账户 ID
echo "🔍 获取账户 ID..."
ACCOUNT_ID=$(wrangler whoami | grep "Account ID" | awk '{print $3}' | tr -d '│' | xargs)
if [ -z "$ACCOUNT_ID" ]; then
    echo "❌ 无法获取账户 ID，请手动获取"
    echo "访问 https://dash.cloudflare.com/ 在右侧边栏查看"
else
    echo "✅ 账户 ID: $ACCOUNT_ID"
fi
echo ""

# 创建 .env 文件
echo "📝 创建环境配置文件..."
cat > .env << EOF
# Cloudflare 账户配置
CLOUDFLARE_ACCOUNT_ID=$ACCOUNT_ID

# R2 存储桶配置  
R2_BUCKET_NAME=$BUCKET_NAME

# 公共访问 URL (需要手动配置自定义域名后更新)
R2_PUBLIC_URL=https://pub-$(openssl rand -hex 8).r2.dev

# 网站配置
NEXT_PUBLIC_WEBSITE_URL=https://shannonwang.top

# TODO: 需要手动添加 API 密钥
# R2_ACCESS_KEY_ID=your_access_key_here
# R2_SECRET_ACCESS_KEY=your_secret_access_key_here
EOF

echo "✅ .env 文件已创建"
echo ""

echo "🔑 接下来需要手动操作："
echo "1. 创建 R2 API Token:"
echo "   访问: https://dash.cloudflare.com/profile/api-tokens"
echo "   点击 'Create Token'"
echo "   选择 'Custom Token'"
echo "   权限设置为: Cloudflare R2:Edit"
echo ""
echo "2. 将获取的 API 密钥添加到 .env 文件:"
echo "   R2_ACCESS_KEY_ID=获取的Access Key"
echo "   R2_SECRET_ACCESS_KEY=获取的Secret Key"
echo ""
echo "3. (可选) 配置自定义域名:"
echo "   在存储桶设置中添加: media.shannonwang.top"
echo "   然后更新 .env 中的 R2_PUBLIC_URL"
echo ""

# 显示存储桶列表确认
echo "📋 当前 R2 存储桶列表:"
wrangler r2 bucket list
echo ""

echo "🎉 基础配置完成！"
echo "完成上述手动步骤后，运行 ./test-r2-config.sh 进行测试"