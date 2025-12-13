import { useEffect, useState } from 'react'
import {
  Page,
  Masthead,
  MastheadMain,
  MastheadBrand,
  MastheadContent,
  PageSidebar,
  PageSidebarBody,
  Breadcrumb,
  BreadcrumbItem,
  Spinner,
  Drawer,
  DrawerContent,
  DrawerContentBody,
  DrawerPanelContent,
} from '@patternfly/react-core'
import { Navigation } from './components/Navigation'
import { MarkdownViewer } from './components/MarkdownViewer'
import { Terminal } from './components/Terminal'
import { LanguageSelector } from './components/LanguageSelector'
import { Logo } from './components/Logo'
import { useLocalStorage } from './hooks/use-local-storage'
import { useLanguage } from './contexts/LanguageContext'
import { useConfig } from './contexts/ConfigContext'

function App() {
  const { language, t } = useLanguage()
  const { config } = useConfig()
  const [guides, setGuides] = useState<string[]>([])
  const [currentGuide, setCurrentGuide] = useLocalStorage<string>('current-guide', '')
  const [guideContent, setGuideContent] = useState<string>('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    setLoading(true)
    fetch(`/api/guides?lang=${language}`)
      .then((res) => res.json())
      .then((data: string[]) => {
        setGuides(data)
        if (data.length > 0) {
          if (!currentGuide || !data.includes(currentGuide)) {
            setCurrentGuide(data[0])
          }
        }
        setLoading(false)
      })
      .catch((err) => {
        console.error('Error loading guides:', err)
        setLoading(false)
      })
  }, [language])

  useEffect(() => {
    if (!currentGuide || guides.length === 0) return
    
    if (!guides.includes(currentGuide)) {
      setCurrentGuide(guides[0])
      return
    }

    setLoading(true)
    fetch(`/api/guides/${currentGuide}?lang=${language}`)
      .then((res) => {
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`)
        }
        return res.text()
      })
      .then((content) => {
        if (content === 'Guide not found' || content.startsWith('<!DOCTYPE')) {
          throw new Error('Guide not found')
        }
        setGuideContent(content)
        setLoading(false)
      })
      .catch((err) => {
        console.error('Error loading guide content:', err)
        if (guides.length > 0 && currentGuide !== guides[0]) {
          setCurrentGuide(guides[0])
        } else {
          setGuideContent('# Erro ao carregar guia\n\nNao foi possivel carregar o conteudo deste guia.')
          setLoading(false)
        }
      })
  }, [currentGuide, language, guides])

  const handleSelectGuide = (guide: string) => {
    setCurrentGuide(guide)
  }

  const displayTitle = currentGuide
    ? currentGuide.replace(/\.md$/, '').replace(/^\d+-/, '').replace(/-/g, ' ')
    : t.selectGuide

  const headerTitle = config.branding.subtitle 
    ? `${config.branding.title} - ${config.branding.subtitle}`
    : config.branding.title

  if (loading && guides.length === 0) {
    return (
      <div style={{ 
        height: '100vh', 
        width: '100vw', 
        display: 'flex', 
        alignItems: 'center', 
        justifyContent: 'center',
        flexDirection: 'column',
        gap: '1rem'
      }}>
        <Spinner size="xl" />
        <span>{t.loading}</span>
      </div>
    )
  }

  const masthead = (
    <Masthead>
      <MastheadMain>
        <MastheadBrand>
          <Logo />
          <span style={{ 
            color: 'var(--workshop-white)', 
            fontWeight: 400, 
            fontSize: '1rem',
            marginLeft: '0.5rem'
          }}>
            {headerTitle}
          </span>
        </MastheadBrand>
      </MastheadMain>
      {config.features.i18n && (
        <MastheadContent>
          <LanguageSelector />
        </MastheadContent>
      )}
    </Masthead>
  )

  const sidebar = (
    <PageSidebar>
      <PageSidebarBody>
        <Navigation
          guides={guides}
          currentGuide={currentGuide || ''}
          onSelectGuide={handleSelectGuide}
        />
      </PageSidebarBody>
    </PageSidebar>
  )

  const panelContent = (
    <DrawerPanelContent
      isResizable
      defaultSize="50%"
      minSize="300px"
    >
      <Terminal />
    </DrawerPanelContent>
  )

  return (
    <Page masthead={masthead} sidebar={sidebar}>
      <div className="workshop-breadcrumb-bar">
        <Breadcrumb>
          <BreadcrumbItem>Workshop</BreadcrumbItem>
          <BreadcrumbItem isActive style={{ textTransform: 'capitalize' }}>
            {displayTitle}
          </BreadcrumbItem>
        </Breadcrumb>
      </div>
      
      <Drawer isExpanded isInline position="end">
        <DrawerContent panelContent={panelContent}>
          <DrawerContentBody style={{ overflow: 'auto', padding: 0 }}>
            <div className="markdown-content">
              {loading ? (
                <div className="workshop-loading">
                  <Spinner size="lg" />
                </div>
              ) : guideContent ? (
                <>
                  <h1 style={{ 
                    fontSize: '1.5rem', 
                    fontWeight: 400, 
                    marginBottom: '1.5rem',
                    textTransform: 'capitalize',
                    fontFamily: "'Red Hat Display', sans-serif"
                  }}>
                    {displayTitle}
                  </h1>
                  <MarkdownViewer content={guideContent} />
                </>
              ) : (
                <div style={{ textAlign: 'center', padding: '4rem' }}>
                  <p style={{ color: 'var(--workshop-gray-500)' }}>
                    {t.selectGuide}
                  </p>
                </div>
              )}
            </div>
          </DrawerContentBody>
        </DrawerContent>
      </Drawer>
    </Page>
  )
}

export default App
