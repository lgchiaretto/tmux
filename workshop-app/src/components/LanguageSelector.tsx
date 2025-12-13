import { useState } from 'react'
import {
  Dropdown,
  DropdownItem,
  DropdownList,
  MenuToggle,
  MenuToggleElement,
} from '@patternfly/react-core'
import { GlobeIcon } from '@patternfly/react-icons'
import { useLanguage } from '@/contexts/LanguageContext'

export function LanguageSelector() {
  const { language, setLanguage, availableLanguages } = useLanguage()
  const [isOpen, setIsOpen] = useState(false)

  const languageLabels: Record<string, string> = {
    pt: 'Português',
    en: 'English',
  }

  const onToggle = () => {
    setIsOpen(!isOpen)
  }

  const onSelect = (lang: string) => {
    setLanguage(lang)
    setIsOpen(false)
  }

  return (
    <Dropdown
      isOpen={isOpen}
      onOpenChange={setIsOpen}
      toggle={(toggleRef: React.Ref<MenuToggleElement>) => (
        <MenuToggle
          ref={toggleRef}
          onClick={onToggle}
          isExpanded={isOpen}
          variant="plain"
          style={{ color: 'var(--workshop-white)' }}
        >
          <GlobeIcon style={{ marginRight: '0.5rem' }} />
          {languageLabels[language] || language.toUpperCase()}
        </MenuToggle>
      )}
    >
      <DropdownList>
        {availableLanguages.map((lang) => (
          <DropdownItem
            key={lang}
            onClick={() => onSelect(lang)}
            isSelected={lang === language}
          >
            {languageLabels[lang] || lang.toUpperCase()}
          </DropdownItem>
        ))}
      </DropdownList>
    </Dropdown>
  )
}
