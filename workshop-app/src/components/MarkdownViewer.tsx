import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import rehypeHighlight from 'rehype-highlight'
import 'highlight.js/styles/github-dark.css'
import { Button } from './ui/button'
import { Check, CopySimple } from '@phosphor-icons/react'
import { useState, ReactNode } from 'react'
import { copyToClipboard } from '@/lib/clipboard'
import { useLanguage } from '@/contexts/LanguageContext'

interface MarkdownViewerProps {
  content: string
}

// Helper function to extract text content from React children
function extractTextContent(children: ReactNode): string {
  if (typeof children === 'string') {
    return children
  }
  if (typeof children === 'number') {
    return String(children)
  }
  if (Array.isArray(children)) {
    return children.map(extractTextContent).join('')
  }
  if (children && typeof children === 'object' && 'props' in children) {
    return extractTextContent((children as any).props?.children)
  }
  return ''
}

function CodeBlock({ children, className, rawText }: { children: ReactNode; className?: string; rawText: string }) {
  const { t } = useLanguage()
  const [copied, setCopied] = useState(false)

  const handleCopy = async () => {
    await copyToClipboard(rawText)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <div className="code-block-wrapper">
      <pre className={className}>
        <code>{children}</code>
      </pre>
      <Button
        size="sm"
        onClick={handleCopy}
        className="copy-button h-7 text-xs"
        style={copied ? {
          backgroundColor: 'var(--success)',
          color: 'var(--success-foreground)',
        } : {
          backgroundColor: 'var(--accent)',
          color: 'var(--accent-foreground)',
        }}
      >
        {copied ? (
          <>
            <Check size={14} weight="bold" className="mr-1.5" />
            {t.copied}
          </>
        ) : (
          <>
            <CopySimple size={14} weight="bold" className="mr-1.5" />
            {t.copy}
          </>
        )}
      </Button>
    </div>
  )
}

export function MarkdownViewer({ content }: MarkdownViewerProps) {
  return (
    <div className="markdown-content prose prose-slate max-w-none">
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        rehypePlugins={[rehypeHighlight]}
        components={{
          code({ node, className, children, ...props }) {
            const match = /language-(\w+)/.exec(className || '')
            const isInline = !match

            if (isInline) {
              return (
                <code className={className} {...props}>
                  {children}
                </code>
              )
            }

            // Extract raw text for copy functionality
            const rawText = extractTextContent(children).replace(/\n$/, '')

            return (
              <CodeBlock className={className} rawText={rawText}>
                {children}
              </CodeBlock>
            )
          },
        }}
      >
        {content}
      </ReactMarkdown>
    </div>
  )
}
