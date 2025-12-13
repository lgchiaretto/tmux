import { 
  EmptyState, 
  EmptyStateBody, 
  EmptyStateActions, 
  Button,
  Content
} from '@patternfly/react-core'
import { ExclamationCircleIcon } from '@patternfly/react-icons'

interface ErrorFallbackProps {
  error: Error | null
}

export function ErrorFallback({ error }: ErrorFallbackProps) {
  return (
    <div style={{ 
      height: '100vh', 
      width: '100vw', 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center',
      padding: '2rem'
    }}>
      <EmptyState 
        titleText="Algo deu errado"
        icon={ExclamationCircleIcon}
        headingLevel="h1"
        status="danger"
      >
        <EmptyStateBody>
          <Content>
            <p>Ocorreu um erro inesperado. Por favor, tente recarregar a página.</p>
            {error && (
              <pre style={{ 
                marginTop: '1rem', 
                textAlign: 'left', 
                backgroundColor: 'var(--pf-t--global--background--color--secondary--default)',
                padding: '1rem',
                borderRadius: 'var(--pf-t--global--border--radius--small)',
                overflow: 'auto',
                maxHeight: '200px'
              }}>
                {error.message}
              </pre>
            )}
          </Content>
        </EmptyStateBody>
        <EmptyStateActions>
          <Button variant="primary" onClick={() => window.location.reload()}>
            Recarregar Página
          </Button>
        </EmptyStateActions>
      </EmptyState>
    </div>
  )
}
