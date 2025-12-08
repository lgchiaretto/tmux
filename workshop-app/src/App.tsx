import { useEffect, useState } from 'react'
import { Navigation } from './components/Navigation'
import { MarkdownViewer } from './components/MarkdownViewer'
import { Terminal } from './components/Terminal'
import { LanguageSelector } from './components/LanguageSelector'
import { Sheet, SheetContent, SheetTrigger } from './components/ui/sheet'
import { Button } from './components/ui/button'
import { List } from '@phosphor-icons/react'
import { useIsMobile } from './hooks/use-mobile'
import { useLocalStorage } from './hooks/use-local-storage'
import { useLanguage } from './contexts/LanguageContext'

// Tmux Logo SVG Component
function TmuxLogo() {
  return (
    <div className="flex items-center gap-3">
      {/* Terminal Icon */}
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="h-8 w-8 text-green-500">
        <rect x="2" y="4" width="20" height="16" rx="2" ry="2"/>
        <line x1="6" y1="8" x2="6" y2="8"/>
        <line x1="10" y1="8" x2="10" y2="8"/>
        <line x1="14" y1="8" x2="14" y2="8"/>
        <path d="M6 12l4 4"/>
        <path d="M6 16l4-4"/>
        <line x1="14" y1="16" x2="18" y2="16"/>
      </svg>
      {/* tmux Text */}
      <span className="text-white font-bold text-xl whitespace-nowrap font-mono">
        tmux
      </span>
    </div>
  )
}

function App() {
  const { language, t } = useLanguage()
  const [guides, setGuides] = useState<string[]>([])
  const [currentGuide, setCurrentGuide] = useLocalStorage<string>('current-guide', '')
  const [guideContent, setGuideContent] = useState<string>('')
  const [loading, setLoading] = useState(true)
  const [sheetOpen, setSheetOpen] = useState(false)
  const isMobile = useIsMobile()

  useEffect(() => {
    setLoading(true)
    fetch(`/api/guides?lang=${language}`)
      .then((res) => res.json())
      .then((data: string[]) => {
        setGuides(data)
        if (data.length > 0) {
          // Always reset to first guide if current doesn't exist or is empty
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
    
    // Skip if guide doesn't exist in current list
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
        // Check if content is an error message
        if (content === 'Guide not found' || content.startsWith('<!DOCTYPE')) {
          throw new Error('Guide not found')
        }
        setGuideContent(content)
        setLoading(false)
      })
      .catch((err) => {
        console.error('Error loading guide content:', err)
        // Reset to first guide on error
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
    setSheetOpen(false)
  }

  if (loading && guides.length === 0) {
    return (
      <div className="h-screen w-screen flex items-center justify-center bg-background">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-accent/30 border-t-accent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-sm text-muted-foreground font-medium">{t.loading}</p>
        </div>
      </div>
    )
  }

  const navigationComponent = (
    <Navigation
      guides={guides}
      currentGuide={currentGuide || ''}
      onSelectGuide={handleSelectGuide}
      className="h-full"
    />
  )

  const displayTitle = currentGuide
    ? currentGuide.replace(/\.md$/, '').replace(/^\d+-/, '').replace(/-/g, ' ')
    : t.selectGuide

  return (
    <div className="h-screen w-screen overflow-hidden bg-background flex flex-col">
      {/* Header/Navbar */}
      <header className="h-14 bg-[var(--navbar-bg)] text-[var(--navbar-fg)] flex items-center justify-between px-4 flex-shrink-0">
        <div className="flex items-center gap-4">
          <TmuxLogo />
          <span className="text-[var(--navbar-fg)] font-normal text-base hidden sm:block">
            {t.headerTitle}
          </span>
        </div>
        <div className="flex items-center gap-2">
          <LanguageSelector />
          {isMobile && (
            <Sheet open={sheetOpen} onOpenChange={setSheetOpen}>
              <SheetTrigger asChild>
                <Button size="sm" variant="ghost" className="h-8 text-[var(--navbar-fg)] hover:bg-white/10">
                  <List size={20} weight="bold" />
                </Button>
              </SheetTrigger>
              <SheetContent side="left" className="w-[280px] p-0">
                {navigationComponent}
              </SheetContent>
            </Sheet>
          )}
        </div>
      </header>

      <div className="flex-1 flex overflow-hidden">
        {/* Sidebar Navigation */}
        {!isMobile && (
          <aside className="w-60 flex-shrink-0">
            {navigationComponent}
          </aside>
        )}

        {/* Main Content Area */}
        <div className="flex-1 flex flex-col lg:flex-row overflow-hidden">
          {/* Guide Content Panel */}
          <main className="flex-1 flex flex-col overflow-hidden">
            {/* Toolbar */}
            <div className="h-10 px-4 bg-[var(--toolbar-bg)] border-b border-border flex items-center text-sm text-[var(--toolbar-fg)]">
              <nav className="flex items-center gap-2">
                <span>Workshop</span>
                <span>/</span>
                <span className="capitalize font-medium text-foreground">{displayTitle}</span>
              </nav>
            </div>
            
            {/* Document Content */}
            <div className="flex-1 overflow-y-auto">
              <article className="max-w-4xl mx-auto px-4 sm:px-6 py-6">
                {loading ? (
                  <div className="flex items-center justify-center py-16">
                    <div className="w-8 h-8 border-4 border-accent/30 border-t-accent rounded-full animate-spin" />
                  </div>
                ) : guideContent ? (
                  <>
                    <h1 className="text-2xl font-normal text-foreground mb-6 capitalize" style={{ fontFamily: "'Red Hat Display', sans-serif" }}>
                      {displayTitle}
                    </h1>
                    <MarkdownViewer content={guideContent} />
                  </>
                ) : (
                  <div className="text-center py-16">
                    <p className="text-sm text-muted-foreground">
                      {t.selectGuide}
                    </p>
                  </div>
                )}
              </article>
            </div>
          </main>

          {/* Terminal Panel */}
          <div className="flex-1 flex flex-col overflow-hidden bg-[var(--terminal-bg)] border-l border-border">
            <Terminal className="h-full" />
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
