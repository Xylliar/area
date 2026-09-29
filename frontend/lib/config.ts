// Application server URL as seen by the browser (links, images, redirections).
export const PUBLIC_API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080'

// Web client URL as seen by the browser.
export const BASE_URL = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:8081'

// Application server URL for fetch calls. Server-side code (middleware, route handlers, server
// components) runs inside the web client container, where the server has another address.
export const API_URL = typeof window === 'undefined'
  ? process.env.INTERNAL_API_URL || PUBLIC_API_URL
  : PUBLIC_API_URL
