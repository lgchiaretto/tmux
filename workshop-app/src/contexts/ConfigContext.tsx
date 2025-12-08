import { createContext, useContext, useState, useEffect, ReactNode } from 'react'

export interface WorkshopConfig {
  branding: {
    name: string
    title: string
    subtitle: string
    logo: 'tmux' | 'redhat' | 'openshift' | 'custom'
    navTitle: string
    customLogoUrl?: string
  }
  features: {
    i18n: boolean
    defaultLanguage: string
    useTmux: boolean
    showOcpTools: boolean
    showVirtTools: boolean
  }
  terminal: {
    connectedMessage: Record<string, string>
    disconnectedMessage: Record<string, string>
  }
  theme: {
    primary: string
    accent: string
  }
}

const defaultConfig: WorkshopConfig = {
  branding: {
    name: 'Workshop',
    title: 'Workshop',
    subtitle: '',
    logo: 'openshift',
    navTitle: 'Workshop'
  },
  features: {
    i18n: false,
    defaultLanguage: 'en',
    useTmux: true,
    showOcpTools: true,
    showVirtTools: false
  },
  terminal: {
    connectedMessage: {
      en: 'Connected to terminal',
      pt: 'Conectado ao terminal'
    },
    disconnectedMessage: {
      en: 'Connection lost to terminal',
      pt: 'Conexao perdida com o terminal'
    }
  },
  theme: {
    primary: '#ee0000',
    accent: '#ee0000'
  }
}

interface ConfigContextType {
  config: WorkshopConfig
  loading: boolean
}

const ConfigContext = createContext<ConfigContextType | undefined>(undefined)

export function ConfigProvider({ children }: { children: ReactNode }) {
  const [config, setConfig] = useState<WorkshopConfig>(defaultConfig)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch('/config.json')
      .then(res => {
        if (!res.ok) throw new Error('Config not found')
        return res.json()
      })
      .then((data: Partial<WorkshopConfig>) => {
        // Deep merge with defaults
        setConfig({
          branding: { ...defaultConfig.branding, ...data.branding },
          features: { ...defaultConfig.features, ...data.features },
          terminal: { 
            connectedMessage: { ...defaultConfig.terminal.connectedMessage, ...data.terminal?.connectedMessage },
            disconnectedMessage: { ...defaultConfig.terminal.disconnectedMessage, ...data.terminal?.disconnectedMessage }
          },
          theme: { ...defaultConfig.theme, ...data.theme }
        })
        setLoading(false)
      })
      .catch(err => {
        console.warn('Could not load config.json, using defaults:', err)
        setLoading(false)
      })
  }, [])

  // Apply theme CSS variables
  useEffect(() => {
    if (!loading) {
      document.documentElement.style.setProperty('--config-primary', config.theme.primary)
      document.documentElement.style.setProperty('--config-accent', config.theme.accent)
    }
  }, [config.theme, loading])

  return (
    <ConfigContext.Provider value={{ config, loading }}>
      {children}
    </ConfigContext.Provider>
  )
}

export function useConfig() {
  const context = useContext(ConfigContext)
  if (!context) {
    throw new Error('useConfig must be used within a ConfigProvider')
  }
  return context
}
