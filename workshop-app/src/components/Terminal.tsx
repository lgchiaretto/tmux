import { useEffect, useRef, useState } from 'react'
import { Terminal as XTerm } from '@xterm/xterm'
import { FitAddon } from '@xterm/addon-fit'
import '@xterm/xterm/css/xterm.css'
import { Button } from './ui/button'
import { Badge } from './ui/badge'
import { Trash, ArrowClockwise, Terminal as TerminalIcon } from '@phosphor-icons/react'
import { cn } from '@/lib/utils'
import { useLanguage } from '@/contexts/LanguageContext'

interface TerminalProps {
  className?: string
}

type ConnectionStatus = 'connected' | 'connecting' | 'disconnected'

export function Terminal({ className }: TerminalProps) {
  const { t } = useLanguage()
  const terminalRef = useRef<HTMLDivElement>(null)
  const xtermRef = useRef<XTerm | null>(null)
  const fitAddonRef = useRef<FitAddon | null>(null)
  const wsRef = useRef<WebSocket | null>(null)
  const [status, setStatus] = useState<ConnectionStatus>('connecting')
  const reconnectTimeoutRef = useRef<NodeJS.Timeout | undefined>(undefined)

  const connect = () => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      return
    }

    setStatus('connecting')
    
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
    const wsUrl = `${protocol}//${window.location.host}/terminal`
    
    const ws = new WebSocket(wsUrl)
    wsRef.current = ws

    ws.onopen = () => {
      setStatus('connected')
      if (xtermRef.current) {
        xtermRef.current.write('\r\n\x1b[32m✓ ' + t.connectedMessage + '\x1b[0m\r\n')
        
        // Send terminal size immediately
        if (fitAddonRef.current) {
          fitAddonRef.current.fit()
        }
        if (ws.readyState === WebSocket.OPEN && xtermRef.current) {
          ws.send(JSON.stringify({
            type: 'resize',
            cols: xtermRef.current.cols,
            rows: xtermRef.current.rows,
          }))
        }
      }
    }

    ws.onmessage = (event) => {
      if (xtermRef.current) {
        xtermRef.current.write(event.data)
      }
    }

    ws.onerror = () => {
      setStatus('disconnected')
    }

    ws.onclose = () => {
      setStatus('disconnected')
      if (xtermRef.current) {
        xtermRef.current.write('\r\n\x1b[31m✗ ' + t.disconnectedMessage + '\x1b[0m\r\n')
      }
      
      reconnectTimeoutRef.current = setTimeout(() => {
        connect()
      }, 2000)
    }
  }

  useEffect(() => {
    if (!terminalRef.current) return

    const term = new XTerm({
      cursorBlink: true,
      fontSize: 13,
      fontFamily: "'Red Hat Mono', 'JetBrains Mono', Consolas, monospace",
      lineHeight: 1.4,
      rightClickSelectsWord: false,
      theme: {
        background: '#191919',
        foreground: '#f0f0f0',
        cursor: '#f0f0f0',
        cursorAccent: '#191919',
        selectionBackground: '#424242',
        black: '#000000',
        red: '#ee0000',
        green: '#41af46',
        yellow: '#e18114',
        blue: '#5c9fd7',
        magenta: '#a0439c',
        cyan: '#00a0a2',
        white: '#c7c7c7',
        brightBlack: '#5d5d5d',
        brightRed: '#ff6d67',
        brightGreen: '#5ff967',
        brightYellow: '#fefb67',
        brightBlue: '#7aa6d4',
        brightMagenta: '#ff76ff',
        brightCyan: '#4db8b8',
        brightWhite: '#ffffff',
      },
    })

    const fitAddon = new FitAddon()
    term.loadAddon(fitAddon)
    term.open(terminalRef.current)
    
    // Small delay to ensure DOM is ready
    setTimeout(() => {
      fitAddon.fit()
      // Send initial size to server
      if (wsRef.current?.readyState === WebSocket.OPEN) {
        wsRef.current.send(JSON.stringify({
          type: 'resize',
          cols: term.cols,
          rows: term.rows,
        }))
      }
    }, 100)

    xtermRef.current = term
    fitAddonRef.current = fitAddon

    term.onData((data) => {
      if (wsRef.current?.readyState === WebSocket.OPEN) {
        wsRef.current.send(data)
      }
    })

    // Helper function to paste from clipboard
    // Chrome requires clipboard access during user gesture (synchronous context)
    // Firefox is more permissive and allows async clipboard access
    const pasteFromClipboard = async () => {
      try {
        // Request clipboard permissions explicitly (Chrome requirement)
        if (navigator.permissions && navigator.permissions.query) {
          const permissionStatus = await navigator.permissions.query({ 
            name: 'clipboard-read' as PermissionName 
          })
          
          if (permissionStatus.state === 'denied') {
            console.warn('Clipboard access denied. Please allow clipboard access in browser settings.')
            // Fallback: show a notification or use document.execCommand as fallback
            return
          }
        }
        
        // Try modern Clipboard API first
        const text = await navigator.clipboard.readText()
        if (text && wsRef.current?.readyState === WebSocket.OPEN) {
          wsRef.current.send(text)
        }
      } catch (err) {
        console.error('Failed to read clipboard:', err)
        // In Chrome, if clipboard API fails, user needs to grant permission
        // Show a helpful message
        console.warn('Tip: Click inside the terminal and try Ctrl+Shift+V again, or use middle-click to paste.')
      }
    }

    // Intercept browser shortcuts at the document level during capture phase
    // This runs BEFORE the browser can handle the shortcut
    const handleKeyDownCapture = (event: KeyboardEvent) => {
      // Only intercept when terminal has focus
      if (!terminalRef.current?.contains(document.activeElement) && 
          document.activeElement !== terminalRef.current) {
        return
      }

      // Ctrl+T - New tmux window (prevent browser new tab)
      if (event.ctrlKey && !event.shiftKey && event.key.toLowerCase() === 't') {
        event.preventDefault()
        event.stopPropagation()
        // Send Ctrl+T to terminal
        if (wsRef.current?.readyState === WebSocket.OPEN) {
          wsRef.current.send('\x14') // Ctrl+T
        }
        return
      }

      // Ctrl+W - Close tmux pane (prevent browser close tab)
      if (event.ctrlKey && !event.shiftKey && event.key.toLowerCase() === 'w') {
        event.preventDefault()
        event.stopPropagation()
        // Send Ctrl+W to terminal
        if (wsRef.current?.readyState === WebSocket.OPEN) {
          wsRef.current.send('\x17') // Ctrl+W
        }
        return
      }

      // Ctrl+N - (prevent browser new window)
      if (event.ctrlKey && !event.shiftKey && event.key.toLowerCase() === 'n') {
        event.preventDefault()
        event.stopPropagation()
        if (wsRef.current?.readyState === WebSocket.OPEN) {
          wsRef.current.send('\x0e') // Ctrl+N
        }
        return
      }

      // Ctrl+Shift+T - (prevent browser reopen tab)
      if (event.ctrlKey && event.shiftKey && event.key.toLowerCase() === 't') {
        event.preventDefault()
        event.stopPropagation()
        return
      }

      // Ctrl+Shift+V - paste from browser clipboard (useful for external content)
      if (event.ctrlKey && event.shiftKey && event.key.toLowerCase() === 'v') {
        event.preventDefault()
        event.stopPropagation()
        // Call async function immediately in user gesture context
        pasteFromClipboard().catch(console.error)
        return
      }

      // Ctrl+\ - Split pane horizontally (tmux vertical split)
      // Chrome and Firefox handle backslash differently:
      // - Firefox: key='\\', code='Backslash', keyCode=220
      // - Chrome: key='\\', code='Backslash', keyCode=220
      // Check multiple properties to ensure maximum compatibility
      if (event.ctrlKey && !event.shiftKey && 
          (event.key === '\\' || event.code === 'Backslash' || event.keyCode === 220)) {
        event.preventDefault()
        event.stopPropagation()
        // Send Ctrl+\ (0x1c) to terminal for tmux split
        if (wsRef.current?.readyState === WebSocket.OPEN) {
          wsRef.current.send('\x1c') // Ctrl+\ = ASCII 28 (0x1c)
        }
        return
      }
    }

    // Add listener with capture: true to intercept before browser
    document.addEventListener('keydown', handleKeyDownCapture, { capture: true })

    // Handle custom key events for paste
    term.attachCustomKeyEventHandler((event: KeyboardEvent) => {
      // Handle Ctrl+Shift+V FIRST - paste from browser clipboard
      // Must check this before Ctrl+V since shiftKey is also set
      if (event.ctrlKey && event.shiftKey && (event.key === 'v' || event.key === 'V') && event.type === 'keydown') {
        event.preventDefault()
        event.stopPropagation()
        pasteFromClipboard().catch(console.error)
        return false // Prevent xterm from handling
      }
      
      // Handle Ctrl+V - send to tmux so it can paste from its buffer
      if (event.ctrlKey && !event.shiftKey && event.key === 'v' && event.type === 'keydown') {
        event.preventDefault()
        event.stopPropagation()
        // Send Ctrl+V to terminal/tmux so it can handle paste-buffer
        if (wsRef.current?.readyState === WebSocket.OPEN) {
          wsRef.current.send('\x16') // Ctrl+V character
        }
        return false // Prevent default xterm handling
      }
      
      return true // Let xterm handle other keys normally
    })

    // Prevent default paste behavior and handle manually to avoid duplication
    const handlePaste = (event: ClipboardEvent) => {
      event.preventDefault()
      const text = event.clipboardData?.getData('text')
      if (text && wsRef.current?.readyState === WebSocket.OPEN) {
        wsRef.current.send(text)
      }
    }

    // Intercept middle mouse button click to prevent X11 primary selection paste
    // This ensures only the system clipboard is used for paste operations
    const handleMouseDown = (event: MouseEvent) => {
      // Middle mouse button is button 1
      if (event.button === 1) {
        event.preventDefault()
        event.stopPropagation()
        // Paste from system clipboard instead of X11 primary selection
        pasteFromClipboard().catch(console.error)
        return false
      }
    }

    // Prevent auxclick (middle click) from triggering any default behavior
    const handleAuxClick = (event: MouseEvent) => {
      if (event.button === 1) {
        event.preventDefault()
        event.stopPropagation()
        return false
      }
    }

    // Also capture mouseup to fully prevent middle-click paste
    const handleMouseUp = (event: MouseEvent) => {
      if (event.button === 1) {
        event.preventDefault()
        event.stopPropagation()
        return false
      }
    }

    terminalRef.current.addEventListener('paste', handlePaste)
    terminalRef.current.addEventListener('mousedown', handleMouseDown, { capture: true })
    terminalRef.current.addEventListener('mouseup', handleMouseUp, { capture: true })
    terminalRef.current.addEventListener('auxclick', handleAuxClick, { capture: true })

    // Connect immediately without delay
    connect()

    const handleResize = () => {
      fitAddon.fit()
      if (wsRef.current?.readyState === WebSocket.OPEN) {
        wsRef.current.send(JSON.stringify({
          type: 'resize',
          cols: term.cols,
          rows: term.rows,
        }))
      }
    }

    // Observe terminal container size changes
    const resizeObserver = new ResizeObserver(() => {
      handleResize()
    })
    
    if (terminalRef.current) {
      resizeObserver.observe(terminalRef.current)
    }

    window.addEventListener('resize', handleResize)

    return () => {
      document.removeEventListener('keydown', handleKeyDownCapture, { capture: true })
      if (terminalRef.current) {
        terminalRef.current.removeEventListener('paste', handlePaste)
        terminalRef.current.removeEventListener('mousedown', handleMouseDown, { capture: true })
        terminalRef.current.removeEventListener('mouseup', handleMouseUp, { capture: true })
        terminalRef.current.removeEventListener('auxclick', handleAuxClick, { capture: true })
      }
      resizeObserver.disconnect()
      window.removeEventListener('resize', handleResize)
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current)
      }
      term.dispose()
      wsRef.current?.close()
    }
  }, [])

  const handleClear = () => {
    xtermRef.current?.clear()
  }

  const handleReconnect = () => {
    if (wsRef.current) {
      wsRef.current.close()
    }
    connect()
  }

  const getStatusBadge = () => {
    switch (status) {
      case 'connected':
        return (
          <Badge variant="outline" className="border-success/30 bg-success/10 text-success text-xs font-medium">
            <div className="w-1.5 h-1.5 rounded-full bg-success mr-1.5" />
            {t.connected}
          </Badge>
        )
      case 'connecting':
        return (
          <Badge variant="outline" className="border-warning/30 bg-warning/10 text-warning text-xs font-medium">
            <div className="w-1.5 h-1.5 rounded-full bg-warning mr-1.5 animate-pulse" />
            {t.connecting}
          </Badge>
        )
      case 'disconnected':
        return (
          <Badge variant="outline" className="border-destructive/30 bg-destructive/10 text-destructive text-xs font-medium">
            <div className="w-1.5 h-1.5 rounded-full bg-destructive mr-1.5" />
            {t.disconnected}
          </Badge>
        )
    }
  }

  return (
    <div className={className}>
      <div className="h-full flex flex-col overflow-hidden">
        <div className="flex items-center justify-between px-4 py-2 bg-[var(--toolbar-bg)] border-b border-border">
          <div className="flex items-center gap-2">
            <TerminalIcon size={16} weight="bold" className="text-[var(--toolbar-fg)]" />
            <span className="text-sm font-medium text-foreground">{t.terminal}</span>
          </div>
          <div className="flex items-center gap-3">
            {getStatusBadge()}
            <div className="flex items-center gap-1">
              {status === 'disconnected' && (
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={handleReconnect}
                  className="h-7 px-2 text-xs hover:bg-accent/10 hover:text-accent"
                  title={t.reconnect}
                >
                  <ArrowClockwise size={14} weight="bold" />
                </Button>
              )}
              <Button
                size="sm"
                variant="ghost"
                onClick={handleClear}
                className="h-7 px-2 text-xs hover:bg-accent/10 hover:text-accent"
                title={t.clearTerminal}
              >
                <Trash size={14} weight="bold" />
              </Button>
            </div>
          </div>
        </div>
        <div ref={terminalRef} className="flex-1 p-2 overflow-hidden bg-[var(--terminal-bg)]" />
      </div>
    </div>
  )
}
