import { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="app">
      <header>
        <h1>React Demo</h1>
        <p>A tiny React + Vite + TypeScript app</p>
      </header>

      <main>
        <button onClick={() => setCount((c) => c + 1)}>
          You clicked {count} time{count === 1 ? '' : 's'}
        </button>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR.
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
