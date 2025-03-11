/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    // 允许自动优化图片
    formats: ['image/webp', 'image/avif'],
    // 如果需要外部图片源，在这里添加域名
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'media.ginonotes.com',
      },
    ],
  },
}

export default nextConfig 