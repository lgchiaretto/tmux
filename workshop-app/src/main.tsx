import { createRoot } from 'react-dom/client'
import { Component, ReactNode } from 'react'

import App from './App.tsx'
import { ErrorFallback } from './ErrorFallback.tsx'
import { LanguageProvider } from './contexts/LanguageContext.tsx'

import "./main.css"
import "./styles/theme.css"
import "./index.css"

// Simple ErrorBoundary implementation
class ErrorBoundary extends Component<
  { children: ReactNode },
  { hasError: boolean; error: Error | null }
> {
  constructor(props: { children: ReactNode }) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: any) {
    console.error('Error caught by boundary:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />
    }
    return this.props.children
  }
}

createRoot(document.getElementById('root')!).render(
  <ErrorBoundary>
    <LanguageProvider>
      <App />
    </LanguageProvider>
  </ErrorBoundary>
)
