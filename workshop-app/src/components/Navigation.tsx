import { cn } from '@/lib/utils'
import { useLanguage } from '@/contexts/LanguageContext'

interface NavigationProps {
  guides: string[]
  currentGuide: string
  onSelectGuide: (guide: string) => void
  className?: string
}

export function Navigation({ guides, currentGuide, onSelectGuide, className }: NavigationProps) {
  const { t } = useLanguage()
  
  return (
    <div className={cn('flex flex-col h-full bg-[var(--sidebar-bg)] border-r border-border/50', className)}>
      <div className="flex-1 overflow-y-auto">
        <nav className="nav-menu">
          <h3 className="text-[var(--sidebar-fg)] font-medium text-sm mb-2 px-1">
            {t.workshop}
          </h3>
          {guides.length === 0 ? (
            <div className="px-3 py-8 text-sm text-[var(--sidebar-fg)]/60 text-center">
              {t.noGuides}
            </div>
          ) : (
            <ul className="nav-list ml-0">
              {guides.map((guide) => {
                const isActive = guide === currentGuide
                const displayName = guide.replace(/\.md$/, '').replace(/^\d+-/, '').replace(/-/g, ' ')
                
                return (
                  <li key={guide} className="nav-item">
                    <button
                      onClick={() => onSelectGuide(guide)}
                      className={cn(
                        'nav-link w-full text-left text-sm transition-colors',
                        isActive && 'is-active'
                      )}
                    >
                      <span className="capitalize">{displayName}</span>
                    </button>
                  </li>
                )
              })}
            </ul>
          )}
        </nav>
      </div>
    </div>
  )
}
