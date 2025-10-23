import React from 'react'

const App = () => {
  const goToOdoo = () => {
    window.location.href = '/'
  }

  return (
    <div style={{
      height: '100vh',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      background: '#f2f2f2'
    }}>
      <h1 style={{ color: '#714b67' }}>👋 Welcome to React + Odoo Demo</h1>
      <p>This React app is served through Nginx alongside Odoo.</p>
      <button
        onClick={goToOdoo}
        style={{
          padding: '10px 20px',
          borderRadius: '8px',
          border: 'none',
          background: '#714b67',
          color: 'white',
          fontSize: '16px',
          cursor: 'pointer',
          marginTop: '20px'
        }}
      >
        Go to Odoo
      </button>
    </div>
  )
}

export default App
