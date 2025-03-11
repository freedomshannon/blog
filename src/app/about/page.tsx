    import { WEBSITE_HOST_URL } from '@/lib/constants'
    import type { Metadata } from 'next'
    import { 
        FaBasketballBall, 
        FaBook, 
        FaRobot, 
        FaJava, 
        FaGithub, 
        FaTwitter, 
        FaWeixin,
        FaPlane,
        FaMountain,
        FaCode
    } from 'react-icons/fa'
    import { 
        SiSpring, 
        SiNextdotjs, 
        SiMongodb,
        SiOpenai
    } from 'react-icons/si'
    import { GiPokerHand } from 'react-icons/gi'
    import { HiMail } from 'react-icons/hi'
    import { BsRobot, BsGear } from 'react-icons/bs'
    import { Container } from '@/components/common/Container'

    const meta = {
        title: '关于我 - Watch flowers bloom',
        description: '开发工程师，AI 马拉松，爬山，旅行。',
        url: `${WEBSITE_HOST_URL}/about`,
    }

    export const metadata: Metadata = {
        metadataBase: new URL(WEBSITE_HOST_URL),
        title: meta.title,
        description: meta.description,
        openGraph: {
            title: meta.title,
            description: meta.description,
            url: meta.url,
            type: 'website',
        },
        twitter: {
            title: meta.title,
            description: meta.description,
            card: 'summary_large_image',
        },
        alternates: {
            canonical: meta.url,
        },
    }

    const skills = [
        { icon: FaCode, name: '全栈开发', color: 'text-blue-500' },
        { icon: FaJava, name: 'Java', color: 'text-red-500' },
        { icon: SiSpring, name: 'Spring', color: 'text-green-500' },
        { icon: SiMongodb, name: 'MongoDB', color: 'text-green-600' },
        { icon: SiNextdotjs, name: 'Next.js', color: 'text-gray-800 dark:text-gray-200' },
        { icon: SiOpenai, name: 'AI', color: 'text-purple-500' },
        { icon: FaRobot, name: 'Agent', color: 'text-emerald-500' },
    ]

    const interests = [
        {
            icon: FaBasketballBall,
            title: '马拉松',
            description: '热爱马拉松运动'
        },
        {
            icon: FaMountain,
            title: '爬山',
            description: '享受登高望远的乐趣'
        },
        {
            icon: FaPlane,
            title: '旅行',
            description: '享受旅行带来的乐趣'
        },
        {
            icon: FaBook,
            title: '阅读',
            description: '保持学习的习惯，探索不同领域的知识'
        },
    ]

    const contacts = [
        {
            icon: FaWeixin,
            name: '微信',
            value: 'Freedom-Shannon',
            color: 'text-green-500',
        },
        {
            icon: FaGithub,
            name: 'GitHub',
            value: 'ginobefun',
            link: 'https://github.com/freedomshannon',
            color: 'text-gray-800 dark:text-gray-200',
        },
        {
            icon: FaTwitter,
            name: 'Twitter',
            value: '@Bright199678363',
            link: 'https://x.com/Bright199678363',
            color: 'text-blue-400',
        },
        {
            icon: HiMail,
            name: '邮件',
            value: 'guba396@gmail.com',
            link: 'mailto:guba396@gmail.com',
            color: 'text-red-500',
        },
    ]

    export default function About() {
        return (
            <Container size="md">
                <div className="py-12 sm:py-16 lg:py-20">
                    {/* 头部介绍 */}
                    <div>
                        <h1 className="bg-gradient-to-r from-blue-600 to-emerald-600 bg-clip-text text-4xl font-bold tracking-tight text-transparent sm:text-5xl">
                            Watch flowers bloom~
                        </h1>
                        <p className="mt-6 text-lg leading-8 text-gray-600 dark:text-gray-400">
                            👋 你好！我是一名开发工程师，也是 AI 爱好者，喜欢爬山，旅行，喜欢看花开花落。
                        </p>
                    </div>

                    {/* 技术栈 */}
                    <div className="mt-16">
                        <h2 className="text-2xl font-bold tracking-tight text-gray-900 dark:text-gray-100">技术栈</h2>
                        <p className="mt-4 text-gray-600 dark:text-gray-400">
                            我专注于构建高性能、高并发、高稳定性的系统。同时具备全栈开发能力，能够独立完成项目开发。
                        </p>
                        <div className="mt-8 flex flex-wrap gap-6">
                            {skills.map((skill) => (
                                <div key={skill.name} className="flex items-center gap-2">
                                    <skill.icon className={`h-6 w-6 ${skill.color}`} />
                                    <span className="text-gray-800 dark:text-gray-200">{skill.name}</span>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* 兴趣爱好 */}
                    <div className="mt-16">
                        <h2 className="text-2xl font-bold tracking-tight text-gray-900 dark:text-gray-100">兴趣爱好</h2>
                        <div className="mt-8 grid gap-6 sm:grid-cols-2">
                            {interests.map((interest) => (
                                <div
                                    key={interest.title}
                                    className="group rounded-2xl bg-white/50 p-6 shadow-md transition-all hover:shadow-xl dark:bg-gray-800/50"
                                >
                                    <interest.icon className="h-8 w-8 text-blue-500" />
                                    <h3 className="mt-4 text-lg font-semibold text-gray-900 dark:text-gray-100">
                                        {interest.title}
                                    </h3>
                                    <p className="mt-2 text-gray-600 dark:text-gray-400">
                                        {interest.description}
                                    </p>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* 博客目的 */}
                    <div className="mt-16">
                        <h2 className="text-2xl font-bold tracking-tight text-gray-900 dark:text-gray-100">关于博客</h2>
                        <p className="mt-4 text-gray-600 dark:text-gray-400">
                            记录日常学习和思考的过程，分享生活点滴。
                        </p>
                    </div>

                    {/* 联系方式 */}
                    <div className="mt-16">
                        <h2 className="text-2xl font-bold tracking-tight text-gray-900 dark:text-gray-100">联系方式</h2>
                        <div className="mt-8 grid gap-6 sm:grid-cols-2">
                            {contacts.map((contact) => (
                                <div key={contact.name} className="flex items-center gap-4">
                                    <contact.icon className={`h-6 w-6 ${contact.color}`} />
                                    <div className="flex flex-col">
                                        <span className="text-sm text-gray-500 dark:text-gray-400">{contact.name}</span>
                                        {contact.link ? (
                                            <a
                                                href={contact.link}
                                                target="_blank"
                                                rel="noopener noreferrer"
                                                className="text-gray-900 hover:text-blue-600 dark:text-gray-100 dark:hover:text-blue-400"
                                            >
                                                {contact.value}
                                            </a>
                                        ) : (
                                            <span className="text-gray-900 dark:text-gray-100">{contact.value}</span>
                                        )}
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>

                </div>
            </Container>
        )
    }
