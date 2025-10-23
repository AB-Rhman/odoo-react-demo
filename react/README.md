# React Demo (Vite + TypeScript)

A tiny demo React application scaffolded with Vite and TypeScript, ready to run locally or in Docker with a production-grade Nginx setup.

## Features

- Vite dev server for instant HMR
- Strict TypeScript config
- Production build via `vite build`
- Best-practice Docker image (multi-stage build, Nginx static serve, SPA routing)

## Getting started

### Prerequisites
- Node.js 18+ (recommended 20)
- npm 9+

### Install dependencies
```bash
npm install
```

### Run in development
```bash
npm run dev
```
- The dev server runs on http://localhost:5173

### Production build
```bash
npm run build
```
- Output goes to the `dist/` folder.

### Preview production build (locally)
```bash
npm run preview
```
- Serves the compiled app at http://localhost:5173

## Docker

This project includes a multi-stage Dockerfile that builds the app and serves it with Nginx.

### Build the image
```bash
docker build -t react-demo:latest .
```

### Run the container
```bash
docker run --rm -it -p 8080:80 react-demo:latest
```
- Open http://localhost:8080

### Notes on best practices
- Multi-stage builds keep the runtime image small and secure.
- Static files are served by Nginx for performance and simplicity.
- SPA routing is handled using `try_files` to fall back to `index.html`.
- `.dockerignore` is configured to exclude dev-only files and speed up builds.

## Project structure

```
.
├── Dockerfile
├── index.html
├── nginx.conf
├── package.json
├── src
│   ├── App.css
│   ├── App.tsx
│   ├── index.css
│   └── main.tsx
├── tsconfig.json
├── tsconfig.node.json
├── vite.config.ts
└── README.md
```

## Customization tips
- Edit `src/App.tsx` to change the UI. HMR will update instantly in dev.
- Add assets under `public/` (create the folder) or import them directly in components.
- For strict reproducible installs in Docker, commit a `package-lock.json` and uncomment its COPY line, then replace `npm install` with `npm ci` in the Dockerfile.
