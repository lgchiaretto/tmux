import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import rehypeHighlight from 'rehype-highlight'
import 'highlight.js/styles/github-dark.css'
import { Button } from '@patternfly/react-core'
import { CheckIcon, CopyIcon } from '@patternfly/react-icons'
import { useState, ReactNode } from 'react'
import { copyToClipboard } from '@/lib/clipboard'
import { useLanguage } from '@/contexts/LanguageContext'

interface MarkdownViewerProps {
  content: string
}

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
        variant={copied ? 'primary' : 'secondary'}
        size="sm"
        onClick={handleCopy}
        className="copy-button"
        style={copied ? { 
          backgroundColor: 'var(--pf-t--global--color--status--success--default)' 
        } : {
          backgroundColor: 'var(--workshop-green)',
          color: 'white'
        }}
      >
        {copied ? (
          <>
            <CheckIcon style={{ marginRight: '0.25rem' }} />
            {t.copied}
          </>
        ) : (
          <>
            <CopyIcon style={{ marginRight: '0.25rem' }} />
            {t.copy}
          </>
        )}
      </Button>
    </div>
  )
}

export function MarkdownViewer({ content }: MarkdownViewerProps) {
  return (
    <div className="markdown-content">
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
