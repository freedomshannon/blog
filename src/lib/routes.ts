import { Route } from 'next'

// 定义所有可能的路由路径类型
export type PostRoute = Route<`/posts/${string}`>
export type CategoryRoute = Route<`/categories/${string}`>
export type TagRoute = Route<`/tags/${string}`>

// 定义外部链接类型
export type ExternalRoute = `https://${string}`

// 定义所有可能的路由类型
export type AppRoute = 
  | Route<'/'>
  | Route<'/about'>
  | PostRoute
  | CategoryRoute
  | TagRoute
  | ExternalRoute

// 类型守卫函数
export const isExternalRoute = (route: string): route is ExternalRoute => {
  return route.startsWith('https://')
}

// URL友好的slug生成函数
export const createUrlFriendlySlug = (slug: string): string => {
  return slug
    .toLowerCase()
    // 替换路径分隔符为连字符
    .replace(/\//g, '/')
    // 替换空格为连字符
    .replace(/\s+/g, '-')
    // 替换下划线为连字符
    .replace(/_/g, '-')
    // 移除特殊字符，保留中文、字母、数字、连字符和路径分隔符
    .replace(/[^\u4e00-\u9fa5\w\/-]/g, '')
    // 移除多余的连字符
    .replace(/-+/g, '-')
    // 移除开头和结尾的连字符
    .replace(/^-+|-+$/g, '')
}

// 路由生成函数
export const createPostRoute = (slug: string): PostRoute => `/posts/${createUrlFriendlySlug(slug)}` as PostRoute
export const createCategoryRoute = (category: string): CategoryRoute => `/categories/${category}` as CategoryRoute
export const createTagRoute = (tag: string): TagRoute => `/tags/${tag}` as TagRoute 