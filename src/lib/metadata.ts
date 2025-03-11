import { Metadata } from 'next'
import { WEBSITE_HOST_URL } from './constants'

const meta = {
  title: 'Shannon Blog',
  description: "Shannon Wang's personal blog. I write about product, development and life.",
  image: `${WEBSITE_HOST_URL}/logo.jpg`,
  author: 'Shannon Wang',
}

// Schema.org 结构化数据
export const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'WebSite',
  name: meta.title,
  description: meta.description,
  url: WEBSITE_HOST_URL,
  author: {
    '@type': 'Person',
    name: meta.author,
    url: WEBSITE_HOST_URL,
  },
  publisher: {
    '@type': 'Person',
    name: meta.author,
    url: WEBSITE_HOST_URL,
  },
  image: meta.image,
  inLanguage: 'zh-CN',
}

export const metadata: Metadata = {
  metadataBase: new URL(WEBSITE_HOST_URL),
  title: {
    default: meta.title,
    template: '%s | Shannon Blog',
  },
  description: meta.description,
  openGraph: {
    title: meta.title,
    description: meta.description,
    url: WEBSITE_HOST_URL,
    siteName: meta.title,
    locale: 'zh-CN',
    type: 'website',
    images: [
      {
        url: meta.image,
        width: 1200,
        height: 630,
        alt: meta.title,
      },
    ],
  },
  twitter: {
    title: meta.title,
    description: meta.description,
    images: [
      {
        url: meta.image,
        width: 1200,
        height: 630,
        alt: meta.title,
      }
    ],
    card: 'summary_large_image',
    creator: '@Bright199678363',
  },
  alternates: {
    canonical: WEBSITE_HOST_URL,
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  }
} 