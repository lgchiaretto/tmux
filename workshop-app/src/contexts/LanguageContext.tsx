import { createContext, useContext, useState, useEffect, ReactNode } from 'react'

type Language = 'pt' | 'en'

interface Translations {
  // Navigation
  workshop: string
  selectGuide: string
  noGuides: string
  
  // Terminal
  terminal: string
  connected: string
  connecting: string
  disconnected: string
  reconnect: string
  clearTerminal: string
  connectedMessage: string
  disconnectedMessage: string
  
  // General
  loading: string
  error: string
  copied: string
  copy: string
  
  // Header
  headerTitle: string
}

const translations: Record<Language, Translations> = {
  pt: {
    workshop: 'Workshop tmux',
    selectGuide: 'Selecione um guia',
    noGuides: 'Nenhum guia disponivel',
    terminal: 'Terminal',
    connected: 'Conectado',
    connecting: 'Conectando...',
    disconnected: 'Desconectado',
    reconnect: 'Reconectar',
    clearTerminal: 'Limpar terminal',
    connectedMessage: 'Conectado ao terminal',
    disconnectedMessage: 'Conexao perdida com o terminal',
    loading: 'Carregando workshop...',
    error: 'Erro ao carregar',
    copied: 'Copiado',
    copy: 'Copiar',
    headerTitle: 'Workshop tmux - Produtividade no Terminal',
  },
  en: {
    workshop: 'tmux Workshop',
    selectGuide: 'Select a guide',
    noGuides: 'No guides available',
    terminal: 'Terminal',
    connected: 'Connected',
    connecting: 'Connecting...',
    disconnected: 'Disconnected',
    reconnect: 'Reconnect',
    clearTerminal: 'Clear terminal',
    connectedMessage: 'Connected to terminal',
    disconnectedMessage: 'Connection lost to terminal',
    loading: 'Loading workshop...',
    error: 'Error loading',
    copied: 'Copied',
    copy: 'Copy',
    headerTitle: 'tmux Workshop - Terminal Productivity',
  },
}

interface LanguageContextType {
  language: Language
  setLanguage: (lang: Language) => void
  t: Translations
  availableLanguages: Language[]
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined)

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [language, setLanguage] = useState<Language>(() => {
    const saved = localStorage.getItem('workshop-language')
    if (saved === 'pt' || saved === 'en') return saved
    // Detect browser language
    const browserLang = navigator.language.toLowerCase()
    return browserLang.startsWith('pt') ? 'pt' : 'en'
  })
  const [availableLanguages, setAvailableLanguages] = useState<Language[]>(['pt', 'en'])

  useEffect(() => {
    localStorage.setItem('workshop-language', language)
  }, [language])

  useEffect(() => {
    // Fetch available languages from server
    fetch('/api/languages')
      .then(res => res.json())
      .then((langs: string[]) => {
        const validLangs = langs.filter((l): l is Language => l === 'pt' || l === 'en')
        if (validLangs.length > 0) {
          setAvailableLanguages(validLangs)
        }
      })
      .catch(err => console.error('Error fetching languages:', err))
  }, [])

  const value: LanguageContextType = {
    language,
    setLanguage,
    t: translations[language],
    availableLanguages,
  }

  return (
    <LanguageContext.Provider value={value}>
      {children}
    </LanguageContext.Provider>
  )
}

export function useLanguage() {
  const context = useContext(LanguageContext)
  if (!context) {
    throw new Error('useLanguage must be used within a LanguageProvider')
  }
  return context
}
