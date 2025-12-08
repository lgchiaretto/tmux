import { useLanguage } from '@/contexts/LanguageContext'
import { Button } from './ui/button'
import { GlobeSimple } from '@phosphor-icons/react'

export function LanguageSelector() {
  const { language, setLanguage, availableLanguages } = useLanguage()

  const toggleLanguage = () => {
    const currentIndex = availableLanguages.indexOf(language)
    const nextIndex = (currentIndex + 1) % availableLanguages.length
    setLanguage(availableLanguages[nextIndex])
  }

  const languageLabels: Record<string, string> = {
    pt: 'PT',
    en: 'EN',
  }

  return (
    <Button
      size="sm"
      variant="ghost"
      onClick={toggleLanguage}
      className="h-8 px-2 text-[var(--navbar-fg)] hover:bg-white/10 gap-1"
      title={language === 'pt' ? 'Mudar para Ingles' : 'Switch to Portuguese'}
    >
      <GlobeSimple size={16} weight="bold" />
      <span className="text-xs font-medium">{languageLabels[language]}</span>
    </Button>
  )
}
