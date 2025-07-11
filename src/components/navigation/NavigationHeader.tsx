import Image from 'next/image'
import { FaBars, FaSearch } from 'react-icons/fa'
import { ThemeSwitch } from '../common/ThemeSwitch'

interface NavigationHeaderProps {
  onMenuClick: () => void
  onSearchClick: () => void
}

export function NavigationHeader({ onMenuClick, onSearchClick }: NavigationHeaderProps) {
  return (
    <header className="lg:hidden fixed top-0 left-0 right-0 h-16 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 z-30">
      <div className="flex items-center justify-between px-4 h-full">
        <button
          className="p-2 -ml-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100"
          onClick={onMenuClick}
        >
          <FaBars className="w-5 h-5" />
        </button>
        <div className="flex items-center gap-3">
          <Image
            src="/avatar.jpg"
            alt="Shannon"
            width={32}
            height={32}
            className="rounded-full"
          />
          <span className="font-medium text-gray-900 dark:text-gray-100">
            Shannon
          </span>
        </div>
        <div className="flex items-center gap-2">
          <ThemeSwitch className="lg:hidden" />
          <button
            className="p-2 -mr-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100"
            onClick={onSearchClick}
          >
            <FaSearch className="w-5 h-5" />
          </button>
        </div>
      </div>
    </header>
  )
} 