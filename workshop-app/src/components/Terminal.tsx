import { useEffect, useRef, useState } from 'react'
import { Terminal as XTerm } from '@xterm/xterm'
import { FitAddon } from '@xterm/addon-fit'
import '@xterm/xterm/css/xterm.css'
import { Button, Label, Flex, FlexItem } from '@patternfly/react-core'
import { SyncAltIcon, TerminalIcon } from '@patternfly/react-icons'
import { useLanguage } from '@/contexts/LanguageContext'

type ConnectionStatus = 'connected' | 'connecting' | 'disconnected'

export function Terminal() {
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
        background: '#1e1e1e',
        foreground: '#d4d4d4',
        cursor: '#d4d4d4',
        cursorAccent: '#1e1e1e',
        selectionBackground: '#424242',
        black: '#000000',
        red: '#c9190b',
        green: '#3e8635',
        yellow: '#f0ab00',
        blue: '#0066cc',
        magenta: '#a30078',
        cyan: '#009596',
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
    
    setTimeout(() => {
      fitAddon.fit()
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

    const pasteFromClipboard = async () => {
      try {
        if (navigator.permissions && navigator.permissions.query) {
          const permissionStatus = await navigator.permissions.query({ 
            name: 'clipboard-read' as PermissionName 
          })
          
          if (permissionStatus.state === 'denied') {
            console.warn('Clipboard access denied. Please allow clipboard access in browser settings.')
            return
          }
        }
        
        const text = await navigator.clipboard.readText()
        if (text && wsRef.current?.readyState === WebSocket.OPEN) {
          wsRef.current.send(text)
        }
      } catch (err) {
        console.error('Failed to read clipboard:', err)
        console.warn('Tip: Click inside the terminal and try Ctrl+Shift+V again, or use middle-click to paste.')
      }
    }

    const handleKeyDownCapture = (event: KeyboardEvent) => {
      if (!terminalRef.current?.contains(document.activeElement) && 
          document.activeElement !== terminalRef.current) {
        return
      }

      if (event.ctrlKey && !event.shiftKey && event.key.toLowerCase() === 't') {
        event.preventDefault()
        event.stopPropagation()
        if (wsRef.current?.readyState === WebSocket.OPEN) {
          wsRef.current.send('\x14')
        }
        return
      }

      if (event.ctrlKey && !event.shiftKey && event.key.toLowerCase() === 'w') {
        event.preventDefault()
        event.stopPropagation()
        if (wsRef.current?.readyState === WebSocket.OPEN) {
          wsRef.current.send('\x17')
        }
        return
      }

      if (event.ctrlKey && !event.shiftKey && event.key.toLowerCase() === 'n') {
        event.preventDefault()
        event.stopPropagation()
        if (wsRef.current?.readyState === WebSocket.OPEN) {
          wsRef.current.send('\x0e')
        }
        return
      }

      if (event.ctrlKey && event.shiftKey && event.key.toLowerCase() === 't') {
        event.preventDefault()
        event.stopPropagation()
        return
      }

      if (event.ctrlKey && event.shiftKey && event.key.toLowerCase() === 'v') {
        event.preventDefault()
        event.stopPropagation()
        pasteFromClipboard().catch(console.error)
        return
      }

      if (event.ctrlKey && !event.shiftKey && 
          (event.key === '\\' || event.code === 'Backslash' || event.keyCode === 220)) {
        event.preventDefault()
        event.stopPropagation()
        if (wsRef.current?.readyState === WebSocket.OPEN) {
          wsRef.current.send('\x1c')
        }
        return
      }
    }

    document.addEventListener('keydown', handleKeyDownCapture, { capture: true })

    term.attachCustomKeyEventHandler((event: KeyboardEvent) => {
      if (event.ctrlKey && event.shiftKey && (event.key === 'v' || event.key === 'V') && event.type === 'keydown') {
        event.preventDefault()
        event.stopPropagation()
        pasteFromClipboard().catch(console.error)
        return false
      }
      
      if (event.ctrlKey && !event.shiftKey && event.key === 'v' && event.type === 'keydown') {
        event.preventDefault()
        event.stopPropagation()
        if (wsRef.current?.readyState === WebSocket.OPEN) {
          wsRef.current.send('\x16')
        }
        return false
      }
      
      return true
    })

    const handlePaste = (event: ClipboardEvent) => {
      event.preventDefault()
      const text = event.clipboardData?.getData('text')
      if (text && wsRef.current?.readyState === WebSocket.OPEN) {
        wsRef.current.send(text)
      }
    }

    const handleMouseDown = (event: MouseEvent) => {
      if (event.button === 1) {
        event.preventDefault()
        event.stopPropagation()
        pasteFromClipboard().catch(console.error)
        return false
      }
    }

    const handleAuxClick = (event: MouseEvent) => {
      if (event.button === 1) {
        event.preventDefault()
        event.stopPropagation()
        return false
      }
    }

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

  const getStatusLabel = () => {
    switch (status) {
      case 'connected':
        return <Label color="green" isCompact>{t.connected}</Label>
      case 'connecting':
        return <Label color="orange" isCompact>{t.connecting}</Label>
      case 'disconnected':
        return <Label color="red" isCompact>{t.disconnected}</Label>
    }
  }

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div className="terminal-header">
        <Flex alignItems={{ default: 'alignItemsCenter' }}>
          <FlexItem>
            <span className="terminal-header__title">
              <TerminalIcon />
              {t.terminal}
            </span>
          </FlexItem>
        </Flex>
        <Flex alignItems={{ default: 'alignItemsCenter' }} className="terminal-header__actions">
          <FlexItem>{getStatusLabel()}</FlexItem>
          {status === 'disconnected' && (
            <FlexItem>
              <Button
                variant="plain"
                onClick={handleReconnect}
                aria-label={t.reconnect}
                className="terminal-action-btn"
              >
                <SyncAltIcon />
              </Button>
            </FlexItem>
          )}
        </Flex>
      </div>
      <div 
        ref={terminalRef} 
        className="terminal-container"
        style={{ flex: 1, overflow: 'hidden' }}
      />
    </div>
  )
}
