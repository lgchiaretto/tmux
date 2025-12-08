interface ErrorFallbackProps {
  error: Error | null
}

export function ErrorFallback({ error }: ErrorFallbackProps) {
  return (
    <div className="h-screen w-screen flex items-center justify-center bg-background p-8">
      <div className="max-w-md text-center">
        <h1 className="text-2xl font-bold text-destructive mb-4">Algo deu errado</h1>
        <p className="text-muted-foreground mb-4">
          Ocorreu um erro inesperado. Por favor, tente recarregar a pagina.
        </p>
        {error && (
          <pre className="text-left bg-muted p-4 rounded-md text-sm overflow-auto max-h-48">
            {error.message}
          </pre>
        )}
        <button
          onClick={() => window.location.reload()}
          className="mt-4 px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90"
        >
          Recarregar Pagina
        </button>
      </div>
    </div>
  )
}
