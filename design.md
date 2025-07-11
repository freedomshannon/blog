# ShannonNotes 博客设计规范

## 布局规范

### 整体布局
- 采用响应式设计，适配桌面端和移动端
- 最大宽度限制在合理范围内，确保良好的阅读体验
- 使用 Container 组件统一内容区域的宽度和边距

### 文章列表页
- 精选文章（Featured Post）完整展示文章摘要
- 最新文章列表采用网格布局，每行显示 2 篇文章
- 文章卡片（Post Card）展示封面图、标题、3 行摘要、分类和日期

### 文章详情页
- 采用单栏布局，最大宽度限制确保阅读舒适度
- 右侧固定显示文章目录（Table of Contents）
- 底部显示相关文章推荐

## 样式规范

### 颜色系统
- 主色：使用 Tailwind 的 primary 颜色
- 文本颜色：
  - 标题：text-gray-900 (dark: text-gray-100)
  - 正文：text-gray-600 (dark: text-gray-400)
  - 次要文本：text-muted-foreground
- 背景色：
  - 主背景：white/50 (dark: gray-800/50)
  - 卡片：white/50 (dark: gray-800/50)
  - 渐变：from-blue-50 via-indigo-50 to-emerald-50

### 圆角和阴影
- 卡片圆角：rounded-2xl
- 图片圆角：rounded-xl
- 标签圆角：rounded-full
- 阴影：shadow-md (hover: shadow-lg)

## 字体规范

### 标题
- 文章标题：text-3xl md:text-4xl lg:text-5xl，font-bold
- 卡片标题：text-xl，font-semibold
- 精选文章标题：text-3xl lg:text-4xl，font-bold
- 章节标题：text-2xl lg:text-3xl，font-bold

### 正文
- 文章内容：text-base lg:text-lg，leading-7 lg:leading-8
- 卡片摘要：text-base，line-clamp-3
- 精选文章摘要：text-lg lg:text-xl
- 元信息（日期、阅读时间等）：text-sm

### 其他文本
- 分类标签：text-sm
- 标签：text-xs
- 导航链接：text-sm

## 间距规范

### 垂直间距
- 章节间距：space-y-8
- 卡片内部间距：space-y-4
- 文章段落间距：space-y-6

### 水平间距
- 容器边距：px-4 sm:px-6 lg:px-8
- 卡片内边距：p-6
- 元素间距：gap-2 或 gap-4

## 交互规范

### 悬停效果
- 链接：颜色变化，使用 hover:text-primary
- 卡片：阴影加深
- 图片：轻微放大 scale-105

### 过渡动画
- 使用 transition-all 实现平滑过渡
- 动画持续时间：duration-300
- 图片缩放：transition-transform 