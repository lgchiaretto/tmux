const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const { spawn } = require('node-pty');
const path = require('path');
const fs = require('fs');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server, path: '/terminal' });

const PORT = process.env.PORT || 8080;
const GUIDES_DIR = process.env.GUIDES_DIR || '/app/guides';
const DEFAULT_LANG = process.env.DEFAULT_LANG || 'pt';

// Enable detailed debug logging
console.log('[DEBUG] Server starting with configuration:');
console.log('[DEBUG] PORT:', PORT);
console.log('[DEBUG] GUIDES_DIR:', GUIDES_DIR);
console.log('[DEBUG] USE_TMUX:', process.env.USE_TMUX);
console.log('[DEBUG] DEFAULT_LANG:', DEFAULT_LANG);
console.log('[DEBUG] HOME:', process.env.HOME);

app.use(express.static('dist'));
app.use(express.json());

// Get available languages
app.get('/api/languages', (req, res) => {
  try {
    if (!fs.existsSync(GUIDES_DIR)) {
      return res.json(['pt', 'en']);
    }
    
    const dirs = fs.readdirSync(GUIDES_DIR, { withFileTypes: true })
      .filter(dirent => dirent.isDirectory())
      .map(dirent => dirent.name);
    
    // If no language dirs, assume files are in root (default to pt)
    if (dirs.length === 0) {
      return res.json(['pt']);
    }
    
    res.json(dirs);
  } catch (error) {
    console.error('Error reading languages:', error);
    res.json(['pt', 'en']);
  }
});

// Get guides for a specific language
app.get('/api/guides', (req, res) => {
  try {
    const lang = req.query.lang || DEFAULT_LANG;
    let guidesPath = path.join(GUIDES_DIR, lang);
    
    // Fallback to root guides dir if language dir doesn't exist
    if (!fs.existsSync(guidesPath)) {
      guidesPath = GUIDES_DIR;
    }
    
    if (!fs.existsSync(guidesPath)) {
      return res.json([]);
    }
    
    const files = fs.readdirSync(guidesPath)
      .filter(file => file.endsWith('.md'))
      .sort();
    
    res.json(files);
  } catch (error) {
    console.error('Error reading guides directory:', error);
    res.status(500).json({ error: 'Failed to read guides' });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/guides/:filename', (req, res) => {
  try {
    const filename = req.params.filename;
    const lang = req.query.lang || DEFAULT_LANG;
    
    if (!filename.endsWith('.md')) {
      return res.status(400).send('Invalid file type');
    }
    
    let guidesPath = path.join(GUIDES_DIR, lang);
    
    // Fallback to root guides dir if language dir doesn't exist
    if (!fs.existsSync(guidesPath)) {
      guidesPath = GUIDES_DIR;
    }
    
    const filepath = path.join(guidesPath, filename);
    
    if (!filepath.startsWith(GUIDES_DIR)) {
      return res.status(400).send('Invalid file path');
    }
    
    if (!fs.existsSync(filepath)) {
      return res.status(404).send('Guide not found');
    }
    
    const content = fs.readFileSync(filepath, 'utf-8');
    res.type('text/markdown').send(content);
  } catch (error) {
    console.error('Error reading guide file:', error);
    res.status(500).send('Failed to read guide');
  }
});

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

wss.on('connection', (ws) => {
  const startTime = Date.now();
  console.log('[DEBUG] New terminal connection at', new Date().toISOString());
  
  // Check if tmux should be used (via env var)
  const useTmux = process.env.USE_TMUX === 'true';
  const shell = useTmux ? '/usr/local/bin/tmux' : (process.env.SHELL || '/bin/bash');
  const shellArgs = useTmux ? ['new-session', '-A', '-s', 'workshop', '/bin/bash', '-l'] : [];
  
  console.log('[DEBUG] Configuration:', { useTmux, shell, shellArgs, timeElapsed: `${Date.now() - startTime}ms` });
  
  // Configure environment
  const env = { ...process.env };
  
  // Set HOME
  if (!env.HOME) {
    env.HOME = '/home/default';
  }

  console.log('[DEBUG] Starting PTY with shell:', shell, ', args:', JSON.stringify(shellArgs), ', cwd:', env.HOME);
  const spawnStartTime = Date.now();
  
  const ptyProcess = spawn(shell, shellArgs, {
    name: 'xterm-256color',
    cols: 120,
    rows: 40,
    cwd: env.HOME,
    env: env,
  });
  
  console.log('[DEBUG] PTY spawned successfully, took', `${Date.now() - spawnStartTime}ms`);

  // Configure initial environment
  const containerName = process.env.HOSTNAME || 'workshop';
  
  console.log('[DEBUG] Setting up initial configuration, useTmux:', useTmux);
  
  if (!useTmux) {
    // Only for bash (not tmux) - fast configuration
    setTimeout(() => {
      console.log('[DEBUG] Sending bash configuration commands');
      // Configure PS1 to show container name
      ptyProcess.write(`export PS1='\\[\\033[01;32m\\]${containerName}\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ '\n`);
    }, 100);
  }

  ptyProcess.onData((data) => {
    try {
      ws.send(data);
    } catch (err) {
      console.error('Error sending data to client:', err);
    }
  });

  ws.on('message', (message) => {
    try {
      // Convert Buffer to string
      let data;
      if (typeof message === 'string') {
        data = message;
      } else if (Buffer.isBuffer(message)) {
        data = message.toString('utf8');
      } else if (message instanceof ArrayBuffer) {
        data = Buffer.from(message).toString('utf8');
      } else {
        console.error('Unexpected message type:', typeof message);
        return;
      }
      
      // Try to parse as JSON for resize commands
      try {
        const parsed = JSON.parse(data);
        if (parsed && parsed.type === 'resize' && parsed.cols && parsed.rows) {
          ptyProcess.resize(parsed.cols, parsed.rows);
          return;
        }
      } catch (e) {
        // Not JSON, continue as normal text
      }
      
      // Write only if valid non-empty string
      if (typeof data === 'string' && data.length > 0) {
        ptyProcess.write(data);
      }
    } catch (err) {
      console.error('Error handling message:', err);
    }
  });

  ws.on('close', () => {
    console.log('[DEBUG] Terminal connection closed at', new Date().toISOString());
    ptyProcess.kill();
  });

  ptyProcess.onExit(() => {
    console.log('[DEBUG] PTY process exited');
    try {
      ws.close();
    } catch (err) {
      console.error('Error closing websocket:', err);
    }
  });
});

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Guides directory: ${GUIDES_DIR}`);
  console.log(`Default language: ${DEFAULT_LANG}`);
});
