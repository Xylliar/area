/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  images: {
    // Service icons are SVGs served by the application server, the browser loads them directly.
    unoptimized: true,
  },
};

export default nextConfig;
