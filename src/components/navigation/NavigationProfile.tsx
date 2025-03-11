import Image from 'next/image'
import { FaEnvelope } from 'react-icons/fa'

export function NavigationProfile() {
    return (
        <div className="px-2 mb-6 mt-2 lg:mt-0">
            <div className="relative group">
                <div className="relative w-20 h-20 mx-auto mb-3 rounded-full overflow-hidden ring-2 ring-gray-200 dark:ring-gray-700">
                    <Image
                        src="/avatar.jpg"
                        alt="Shannon"
                        fill
                        className="object-cover transition-transform group-hover:scale-105"
                        sizes="(max-width: 80px) 80px"
                        priority
                    />
                </div>
                <div className="text-center space-y-2">
                    <h2 className="text-xl font-bold bg-gradient-to-r from-gray-900 to-gray-600 dark:from-gray-100 dark:to-gray-400 bg-clip-text text-transparent">
                        Shannon
                    </h2>
                    <div className="flex items-center justify-center gap-1.5 text-gray-600 dark:text-gray-400">
                        <FaEnvelope className="w-3.5 h-3.5" />
                        <a
                            href="mailto:guba396@gmail.com"
                            className="text-sm hover:text-gray-900 dark:hover:text-gray-200 transition-colors"
                        >
                            guba396@gmail.com
                        </a>
                    </div>
                    <p className="text-sm text-gray-500 dark:text-gray-400 font-medium italic">
                        Happy to meet you.
                    </p>
                </div>
            </div>
        </div>
    )
} 