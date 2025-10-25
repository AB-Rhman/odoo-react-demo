import { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  const goBackToOdoo = async () => {
    // Try to clear any Home Action if the redirect module is installed.
    // If the route doesn't exist (module removed), just go to /web.
    try {
      await fetch('/react_redirect/disable', {
        method: 'GET',
        credentials: 'include',
        redirect: 'manual',
      })
    } catch (_) {
      // ignore
    } finally {
      window.location.href = '/web'
    }
  }

  return (
    <div className="app">
      <header>
        <h1>React Demo</h1>
        <p>A tiny React + Vite + TypeScript app</p>
        <div className="toolbar">
          <button className="btn-secondary" onClick={goBackToOdoo}>Back to Odoo</button>
        </div>
      </header>

      <main>
  <button onClick={() => setCount((c: number) => c + 1)}>
          You clicked {count} time{count === 1 ? '' : 's'}
        </button>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMRR.
        </p>
        <ul>
          <li>Fast dev server (Vite)</li>
          <li>TypeScript strict mode</li>
          <li>Ready for Docker</li>
        </ul>
      </main>

      <footer>
        <small>Built on {new Date().toLocaleDateString()}</small>
      </footer>
    </div>
  )
}

export default App
