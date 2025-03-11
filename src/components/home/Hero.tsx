'use client'

import { motion } from 'framer-motion'

export function Hero() {
    return (
        <section className="relative overflow-hidden py-12 sm:py-16">
            {/* 科技感网格背景 */}
            <div className="absolute inset-0 -z-10">
                <div className="absolute inset-0 bg-[linear-gradient(to_right,#8080800a_1px,transparent_1px),linear-gradient(to_bottom,#8080800a_1px,transparent_1px)] bg-[size:14px_24px] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_0%,#000_70%,transparent_100%)]" />
            </div>

            {/* 装饰性元素 - 调整大小和位置 */}
            <div className="absolute -left-4 top-0 h-56 w-56 animate-blob rounded-full bg-purple-300 opacity-30 mix-blend-multiply blur-xl filter dark:mix-blend-overlay" />
            <div className="animation-delay-2000 absolute -right-4 top-0 h-56 w-56 animate-blob rounded-full bg-yellow-300 opacity-30 mix-blend-multiply blur-xl filter dark:mix-blend-overlay" />
            <div className="animation-delay-4000 absolute -bottom-8 left-20 h-56 w-56 animate-blob rounded-full bg-pink-300 opacity-30 mix-blend-multiply blur-xl filter dark:mix-blend-overlay" />

            <motion.div
                initial="hidden"
                animate="show"
                variants={{
                    hidden: { opacity: 0, y: -20 },
                    show: { opacity: 1, y: 0 }
                }}
                transition={{ duration: 0.5, ease: "easeOut" }}
                className="relative mx-auto max-w-6xl px-4 text-center"
            >
                <h1 className="relative mx-auto max-w-4xl bg-gradient-to-br from-gray-900 via-gray-800 to-gray-600 bg-clip-text pb-3 text-3xl font-bold text-transparent dark:from-gray-100 dark:via-gray-200 dark:to-gray-400 md:text-4xl lg:text-5xl">
                    经验事物和个人遐想
                    <motion.span
                        className="absolute -right-4 top-0 text-blue-500 dark:text-blue-400"
                        animate={{
                            opacity: [0, 1, 0],
                            scale: [0.8, 1.2, 0.8],
                        }}
                        transition={{
                            duration: 2,
                            repeat: Infinity,
                            repeatType: "reverse",
                        }}
                    >
                        ✨
                    </motion.span>
                </h1>
                <p className="mt-4 text-base text-gray-600 dark:text-gray-400">
                    分享开发、产品和生活的思考，虽很局限，但仍保持好奇心
                </p>

                {/* 技能标签 */}
                <div className="mt-6 flex flex-wrap justify-center gap-2">
                    {['Java', 'Spring', 'MongoDB', 'Next.js', 'Tailwind CSS', 'LLM', 'Workflow', 'Agent'].map((skill) => (
                        <motion.span
                            key={skill}
                            initial={{ opacity: 0, scale: 0.8 }}
                            animate={{ opacity: 1, scale: 1 }}
                            whileHover={{ scale: 1.05 }}
                            className="inline-flex items-center rounded-full bg-blue-100 px-3 py-0.5 text-sm font-medium text-blue-800 dark:bg-blue-900/70 dark:text-blue-200"
                        >
                            {skill}
                        </motion.span>
                    ))}
                </div>
            </motion.div>
        </section>
    )
} 