# ShannonNotes 博客项目文档

这是一个基于 Next.js 14 + Tailwind CSS + contentlayer 构建的个人博客项目。

## 1. 技术栈

- **框架**: Next.js 14 (App Router)
- **样式**: Tailwind CSS
- **内容管理**: contentlayer
- **语言**: TypeScript
- **包管理**: pnpm

## 2. 项目结构

```
src/
├── app/                    # Next.js App Router 目录
│   ├── page.tsx           # 首页
│   ├── global.css         # 全局样式
│   ├── layout.tsx         # 根布局
│   ├── posts/             # 文章页面
│   └── categories/        # 分类页面
├── components/            # 可复用组件
│   ├── Navigation.tsx     # 导航组件
│   ├── ArticleLayout.tsx  # 文章布局
│   ├── CategoryLayout.tsx # 分类布局
│   └── TableOfContents.tsx# 文章目录
├── lib/                   # 工具函数
│   ├── utils.ts          # 通用工具
│   └── images.ts         # 图片处理
└── content/              # 文章内容
    └── posts/            # MDX 文章
```

## 3. 主要功能实现

### 3.1 导航系统
- 响应式左侧导航
- 移动端抽屉式菜单
- 文章分类导航
- 搜索功能（Command+K 快捷键）

### 3.2 文章系统

```typescript
// 文章结构
interface Post {
  title: string
  date: string
  category: string
  tags?: string[]
  description?: string
  cover?: string
  featured?: boolean
  url: string
  body: {
    raw: string
    code: string
  }
}
```

### 3.3 样式系统

```css
/* Tailwind CSS 层级组织 */
@layer base {
  /* 基础样式：颜色、排版等 */
}

@layer components {
  /* 组件样式：导航、卡片等 */
}

@layer utilities {
  /* 工具类：自定义工具类 */
}
```

## 4. 开发规范

### 4.1 文章编写规范
- 文件命名：`YYYYMMDD_title.mdx`
- 必填字段：title, date, category
- 图片路径：使用相对路径，存放在 public/images
- 代码块：使用 rehype-pretty-code 语法

### 4.2 样式规范
- 优先使用 Tailwind CSS 类
- 遵循移动优先的响应式设计
- 响应式断点：
  ```css
  sm: 640px  - 小屏手机
  md: 768px  - 大屏手机/平板
  lg: 1024px - 桌面
  xl: 1280px - 大屏桌面
  ```

### 4.3 组件开发规范
- 使用 TypeScript 类型定义
- 组件文件使用 PascalCase 命名
- 客户端组件添加 "use client" 指令
- 提取可复用逻辑到 hooks

### 4.4 性能优化
- 使用 Next.js Image 组件优化图片
- 实现组件懒加载
- 优化字体加载
- 合理使用缓存策略

## 5. 注意事项

### 5.1 类型安全
```typescript
// 总是定义明确的类型
interface Props {
  post: Post
  prevPost?: Post
  nextPost?: Post
}
```

### 5.2 路由处理
```typescript
// 使用正确的路由类型
href={post.url as `/posts/${string}/${string}`}
```

### 5.3 暗色模式
- 使用 Tailwind 的 dark: 前缀
- 遵循系统主题设置

### 5.4 可访问性
- 添加适当的 ARIA 标签
- 确保键盘导航可用
- 保持足够的颜色对比度

## 6. 后续开发建议

### 6.1 新功能开发
- 评论系统集成
- 文章统计和分析
- 社交分享功能
- 订阅系统

### 6.2 性能优化
- 实现增量静态再生成 (ISR)
- 优化大型文章的加载
- 添加预加载策略

### 6.3 用户体验
- 添加加载状态反馈
- 优化移动端交互
- 改进搜索体验

### 6.4 维护建议
- 定期更新依赖
- 监控性能指标
- 备份文章内容
- 保持代码风格一致

## 7. 开发流程

1. 克隆项目后，首先安装依赖：
```bash
pnpm install
```

2. 启动开发服务器：
```bash
pnpm dev
```

3. 构建生产版本：
```bash
pnpm build
```

4. 运行生产版本：
```bash
pnpm start
```

## 8. 写作指南

### 8.1 创建新文章
1. 在 `content/posts` 目录下创建新的 MDX 文件
2. 文件名格式：`YYYYMMDD_title.mdx`
3. 添加必要的 frontmatter：
```mdx
---
title: 文章标题
date: 2024-01-01
category: dev
tags: Next.js,React,TypeScript
description: 文章描述
cover: /images/cover.jpg
---
```

### 8.2 文章格式
- 使用 Markdown 语法
- 代码块指定语言
- 图片使用相对路径
- 保持段落间距

### 8.3 图片处理
- 图片存放在 `public/images` 目录
- 使用 Next.js Image 组件
- 提供合适的图片尺寸
- 添加 alt 文本

## 9. 部署

### 9.1 部署前检查
- 运行所有测试
- 检查构建输出
- 验证页面性能
- 确认环境变量

### 9.2 部署流程
1. 提交代码到 GitHub
2. 触发自动部署
3. 验证部署结果
4. 监控性能指标

## 10. 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 发起 Pull Request

## 11. 问题反馈

如果发现问题或有改进建议，请：
1. 检查是否是已知问题
2. 创建详细的 Issue
3. 提供复现步骤
4. 附上相关日志或截图

---

**注意**：本文档会随项目发展持续更新，请定期查看最新版本。 