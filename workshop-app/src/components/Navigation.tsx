import { Nav, NavList, NavItem } from '@patternfly/react-core'
import { useLanguage } from '@/contexts/LanguageContext'

interface NavigationProps {
  guides: string[]
  currentGuide: string
  onSelectGuide: (guide: string) => void
}

export function Navigation({ guides, currentGuide, onSelectGuide }: NavigationProps) {
  const { t } = useLanguage()
  
  return (
    <Nav aria-label={t.workshop}>
      <NavList>
        {guides.length === 0 ? (
          <NavItem isActive={false}>
            <span style={{ 
              padding: '0.5rem 1rem', 
              color: 'var(--workshop-gray-500)',
              display: 'block'
            }}>
              {t.noGuides}
            </span>
          </NavItem>
        ) : (
          guides.map((guide) => {
            const isActive = guide === currentGuide
            const displayName = guide.replace(/\.md$/, '').replace(/^\d+-/, '').replace(/-/g, ' ')
            
            return (
              <NavItem
                key={guide}
                itemId={guide}
                isActive={isActive}
                onClick={() => onSelectGuide(guide)}
                style={{ textTransform: 'capitalize' }}
              >
                {displayName}
              </NavItem>
            )
          })
        )}
      </NavList>
    </Nav>
  )
}
